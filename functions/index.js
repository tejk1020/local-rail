const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions");
const {
  getFirestore,
  FieldValue,
} = require("firebase-admin/firestore");
const {initializeApp} = require("firebase-admin/app");
const Razorpay = require("razorpay");
const crypto = require("crypto");

// ============================================================
// IMPORTANT
// ============================================================
//
// Flutter uses REAL Firebase Firestore.
//
// Firebase Functions Emulator normally sets
// FIRESTORE_EMULATOR_HOST automatically.
//
// We intentionally remove it so the local Functions Emulator
// reads/writes the REAL Firebase Firestore project.
//
// Razorpay remains in TEST MODE.
// ============================================================

delete process.env.FIRESTORE_EMULATOR_HOST;

// Initialize Firebase Admin.
initializeApp();

// ============================================================
// GLOBAL OPTIONS
// ============================================================

setGlobalOptions({
  maxInstances: 10,
});

// ============================================================
// HELPER: GET FIRESTORE
// ============================================================

function getDb() {
  return getFirestore();
}

// ============================================================
// HELPER: GET RAZORPAY
// ============================================================

function getRazorpay() {
  const keyId = process.env.RAZORPAY_KEY_ID;
  const keySecret = process.env.RAZORPAY_KEY_SECRET;

  if (!keyId || !keySecret) {
    throw new HttpsError(
        "failed-precondition",
        "Razorpay configuration is missing.",
    );
  }

  return new Razorpay({
    key_id: keyId,
    key_secret: keySecret,
  });
}

// ============================================================
// HELPER: VALIDATE BOOKING ID
// ============================================================

function validateBookingId(bookingId) {
  if (
    typeof bookingId !== "string" ||
    bookingId.trim().isEmpty
  ) {
    throw new HttpsError(
        "invalid-argument",
        "Booking ID is required.",
    );
  }

  return bookingId.trim();
}

// ============================================================
// CREATE RAZORPAY ORDER
// ============================================================

exports.createRazorpayOrder = onCall(async (request) => {
  // ----------------------------------------------------------
  // AUTHENTICATION
  // ----------------------------------------------------------

  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "You must be logged in.",
    );
  }

  // ----------------------------------------------------------
  // BOOKING ID
  // ----------------------------------------------------------

  const data = request.data || {};
  const bookingId = validateBookingId(data.bookingId);

  // ----------------------------------------------------------
  // FIRESTORE
  // ----------------------------------------------------------

  const db = getDb();

  const bookingRef = db
      .collection("bookings")
      .doc(bookingId);

  const bookingSnapshot = await bookingRef.get();

  // ----------------------------------------------------------
  // BOOKING MUST EXIST
  // ----------------------------------------------------------

  if (!bookingSnapshot.exists) {
    console.error(
        "Booking not found:",
        bookingId,
        "User:",
        request.auth.uid,
    );

    throw new HttpsError(
        "not-found",
        "Booking not found.",
    );
  }

  const booking = bookingSnapshot.data() || {};

  // ----------------------------------------------------------
  // VERIFY OWNERSHIP
  // ----------------------------------------------------------

  if (booking.userId !== request.auth.uid) {
    throw new HttpsError(
        "permission-denied",
        "You do not own this booking.",
    );
  }

  // ----------------------------------------------------------
  // PREVENT PAYING AN ALREADY PAID BOOKING
  // ----------------------------------------------------------

  if (booking.paymentStatus === "paid") {
    throw new HttpsError(
        "failed-precondition",
        "This booking is already paid.",
    );
  }

  // ----------------------------------------------------------
  // VALIDATE FARE
  // ----------------------------------------------------------

  const totalFare = Number(booking.totalFare);

  if (
    !Number.isFinite(totalFare) ||
    totalFare <= 0
  ) {
    throw new HttpsError(
        "invalid-argument",
        "Invalid booking fare.",
    );
  }

  const amountInPaise = Math.round(totalFare * 100);

  // ----------------------------------------------------------
  // RAZORPAY
  // ----------------------------------------------------------

  const razorpay = getRazorpay();

  let order;

  try {
    order = await razorpay.orders.create({
      amount: amountInPaise,
      currency: "INR",
      receipt: bookingId,
      notes: {
        bookingId: bookingId,
        userId: request.auth.uid,
      },
    });
  } catch (error) {
    console.error(
        "Razorpay order creation failed:",
        error,
    );

    throw new HttpsError(
        "internal",
        "Unable to create Razorpay order.",
    );
  }

  // ----------------------------------------------------------
  // SAVE RAZORPAY ORDER ID
  // ----------------------------------------------------------

  await bookingRef.update({
    razorpayOrderId: order.id,
    paymentStatus: "pending",
    updatedAt: FieldValue.serverTimestamp(),
  });

  // ----------------------------------------------------------
  // RETURN ORDER INFORMATION TO FLUTTER
  // ----------------------------------------------------------

  return {
    orderId: order.id,
    amount: amountInPaise,
    currency: "INR",
    keyId: process.env.RAZORPAY_KEY_ID,
  };
});

// ============================================================
// VERIFY RAZORPAY PAYMENT
// ============================================================

exports.verifyRazorpayPayment = onCall(async (request) => {
  // ----------------------------------------------------------
  // AUTHENTICATION
  // ----------------------------------------------------------

  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "You must be logged in.",
    );
  }

  const data = request.data || {};

  const bookingId =
    typeof data.bookingId === "string" ?
      data.bookingId.trim() :
      "";

  const razorpayOrderId =
    typeof data.razorpayOrderId === "string" ?
      data.razorpayOrderId.trim() :
      "";

  const razorpayPaymentId =
    typeof data.razorpayPaymentId === "string" ?
      data.razorpayPaymentId.trim() :
      "";

  const razorpaySignature =
    typeof data.razorpaySignature === "string" ?
      data.razorpaySignature.trim() :
      "";

  // ----------------------------------------------------------
  // VALIDATE PAYMENT DATA
  // ----------------------------------------------------------

  if (
    !bookingId ||
    !razorpayOrderId ||
    !razorpayPaymentId ||
    !razorpaySignature
  ) {
    throw new HttpsError(
        "invalid-argument",
        "Payment verification details are incomplete.",
    );
  }

  // ----------------------------------------------------------
  // FIRESTORE
  // ----------------------------------------------------------

  const db = getDb();

  const bookingRef = db
      .collection("bookings")
      .doc(bookingId);

  const bookingSnapshot = await bookingRef.get();

  // ----------------------------------------------------------
  // BOOKING MUST EXIST
  // ----------------------------------------------------------

  if (!bookingSnapshot.exists) {
    console.error(
        "Verification booking not found:",
        bookingId,
    );

    throw new HttpsError(
        "not-found",
        "Booking not found.",
    );
  }

  const booking = bookingSnapshot.data() || {};

  // ----------------------------------------------------------
  // VERIFY OWNERSHIP
  // ----------------------------------------------------------

  if (booking.userId !== request.auth.uid) {
    throw new HttpsError(
        "permission-denied",
        "You do not own this booking.",
    );
  }

  // ----------------------------------------------------------
  // IDEMPOTENCY
  // ----------------------------------------------------------
  //
  // If the payment was already successfully verified,
  // don't process the tickets again.
  // ----------------------------------------------------------

  if (
    booking.paymentStatus === "paid" &&
    booking.razorpayPaymentId === razorpayPaymentId
  ) {
    return {
      success: true,
      message: "Payment was already verified.",
      bookingId: bookingId,
    };
  }

  // ----------------------------------------------------------
  // VERIFY ORDER ID
  // ----------------------------------------------------------

  if (booking.razorpayOrderId !== razorpayOrderId) {
    throw new HttpsError(
        "failed-precondition",
        "Razorpay order does not match this booking.",
    );
  }

  // ----------------------------------------------------------
  // RAZORPAY SECRET
  // ----------------------------------------------------------

  const keySecret = process.env.RAZORPAY_KEY_SECRET;

  if (!keySecret) {
    throw new HttpsError(
        "failed-precondition",
        "Razorpay secret is missing.",
    );
  }

  // ----------------------------------------------------------
  // GENERATE EXPECTED SIGNATURE
  // ----------------------------------------------------------

  const expectedSignature = crypto
      .createHmac("sha256", keySecret)
      .update(
          `${razorpayOrderId}|${razorpayPaymentId}`,
      )
      .digest("hex");

  // ----------------------------------------------------------
  // TIMING-SAFE SIGNATURE COMPARISON
  // ----------------------------------------------------------

  let signatureIsValid = false;

  try {
    const expectedBuffer =
      Buffer.from(expectedSignature, "utf8");

    const receivedBuffer =
      Buffer.from(razorpaySignature, "utf8");

    if (
      expectedBuffer.length === receivedBuffer.length
    ) {
      signatureIsValid = crypto.timingSafeEqual(
          expectedBuffer,
          receivedBuffer,
      );
    }
  } catch (error) {
    signatureIsValid = false;
  }

  if (!signatureIsValid) {
    console.error(
        "Invalid Razorpay signature for booking:",
        bookingId,
    );

    throw new HttpsError(
        "permission-denied",
        "Invalid Razorpay payment signature.",
    );
  }

  // ----------------------------------------------------------
  // VERIFY PAYMENT DIRECTLY WITH RAZORPAY
  // ----------------------------------------------------------

  const razorpay = getRazorpay();

  let payment;

  try {
    payment = await razorpay.payments.fetch(
        razorpayPaymentId,
    );
  } catch (error) {
    console.error(
        "Unable to fetch Razorpay payment:",
        error,
    );

    throw new HttpsError(
        "internal",
        "Unable to verify payment with Razorpay.",
    );
  }

  // ----------------------------------------------------------
  // VERIFY PAYMENT ORDER ID
  // ----------------------------------------------------------

  if (payment.order_id !== razorpayOrderId) {
    throw new HttpsError(
        "failed-precondition",
        "Payment does not belong to this Razorpay order.",
    );
  }

  // ----------------------------------------------------------
  // VERIFY PAYMENT AMOUNT
  // ----------------------------------------------------------

  const expectedAmount =
    Math.round(Number(booking.totalFare) * 100);

  const paidAmount =
    Number(payment.amount);

  if (
    !Number.isFinite(expectedAmount) ||
    expectedAmount <= 0 ||
    paidAmount !== expectedAmount
  ) {
    console.error(
        "Payment amount mismatch.",
        {
          bookingId,
          expectedAmount,
          paidAmount,
        },
    );

    throw new HttpsError(
        "failed-precondition",
        "Payment amount does not match the booking amount.",
    );
  }

  // ----------------------------------------------------------
  // PAYMENT MUST BE CAPTURED
  // ----------------------------------------------------------

  if (payment.status !== "captured") {
    throw new HttpsError(
        "failed-precondition",
        `Payment is not captured. Current status: ${payment.status}`,
    );
  }

  // ----------------------------------------------------------
  // UPDATE BOOKING + TICKETS
  // ----------------------------------------------------------

  const batch = db.batch();

  batch.update(bookingRef, {
    paymentStatus: "paid",
    bookingStatus: "active",
    razorpayPaymentId: razorpayPaymentId,
    razorpaySignature: razorpaySignature,
    paymentMode: "razorpay",
    paidAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  // ----------------------------------------------------------
  // GET TICKETS FOR THIS BOOKING
  // ----------------------------------------------------------

  const ticketSnapshot = await db
      .collection("tickets")
      .where(
          "bookingId",
          "==",
          bookingId,
      )
      .where(
          "ownerId",
          "==",
          request.auth.uid,
      )
      .get();

  if (ticketSnapshot.empty) {
    throw new HttpsError(
        "not-found",
        "No tickets were found for this booking.",
    );
  }

  // ----------------------------------------------------------
  // MARK ALL BOOKING TICKETS AS VALID
  // ----------------------------------------------------------

  ticketSnapshot.docs.forEach((ticketDoc) => {
    batch.update(ticketDoc.ref, {
      status: "valid",
      paymentMode: "razorpay",
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  // ----------------------------------------------------------
  // COMMIT EVERYTHING TO FIRESTORE
  // ----------------------------------------------------------

  await batch.commit();

  // ----------------------------------------------------------
  // SUCCESS
  // ----------------------------------------------------------

  console.log(
      "Razorpay payment verified successfully:",
      {
        bookingId,
        orderId: razorpayOrderId,
        paymentId: razorpayPaymentId,
      },
  );

  return {
    success: true,
    message: "Payment verified successfully.",
    bookingId: bookingId,
  };
});