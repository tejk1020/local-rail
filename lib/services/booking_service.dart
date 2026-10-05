import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking_model.dart';
import '../models/ticket_model.dart';

class BookingService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // CREATE BOOKING
  // ============================================================

  Future<String> createBooking({
    required String source,
    required String destination,
    String? via,
    required String journeyType,
    required DateTime journeyDate,
    required int passengerCount,
    required double totalFare,
    required List<String> passengerNames,
  }) async {
    final User? currentUser =
        _auth.currentUser;

    if (currentUser == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    // ------------------------------------------------------------
    // VALIDATE SOURCE
    // ------------------------------------------------------------

    if (source.trim().isEmpty) {
      throw Exception(
        'Source station is required.',
      );
    }

    // ------------------------------------------------------------
    // VALIDATE DESTINATION
    // ------------------------------------------------------------

    if (destination.trim().isEmpty) {
      throw Exception(
        'Destination station is required.',
      );
    }

    // ------------------------------------------------------------
    // SOURCE AND DESTINATION
    // ------------------------------------------------------------

    if (source.trim().toLowerCase() ==
        destination.trim().toLowerCase()) {
      throw Exception(
        'Source and destination cannot be the same.',
      );
    }

    // ------------------------------------------------------------
    // PASSENGER COUNT
    // ------------------------------------------------------------

    if (passengerCount < 1) {
      throw Exception(
        'Passenger count must be at least 1.',
      );
    }

    // ------------------------------------------------------------
    // PASSENGER DETAILS
    // ------------------------------------------------------------

    if (passengerNames.length !=
        passengerCount) {
      throw Exception(
        'Passenger details are incomplete.',
      );
    }

    // ------------------------------------------------------------
    // JOURNEY TYPE
    // ------------------------------------------------------------

    if (journeyType != 'one_way' &&
        journeyType != 'return') {
      throw Exception(
        'Invalid journey type.',
      );
    }

    // ============================================================
    // NORMALIZE JOURNEY DATE
    // ============================================================
    //
    // IMPORTANT:
    //
    // A journey date is a DATE, not a time.
    //
    // Using DateTime.now() directly can cause an IST date
    // to appear as the previous date after UTC conversion.
    //
    // Example:
    //
    // 13/09/2026 05:00 IST
    //          ↓
    // 12/09/2026 23:30 UTC
    //
    // To avoid this, store the date at noon local time.
    //
    // 13/09/2026 12:00 IST
    //          ↓
    // 13/09/2026 06:30 UTC
    //
    // Therefore the calendar date remains 13/09/2026.
    // ============================================================

    final DateTime normalizedJourneyDate =
    DateTime(
      journeyDate.year,
      journeyDate.month,
      journeyDate.day,
      12,
      0,
      0,
    );

    // ============================================================
    // CREATE BOOKING ID
    // ============================================================

    final DocumentReference<
        Map<String, dynamic>>
    bookingReference =
    _firestore
        .collection('bookings')
        .doc();

    final String bookingId =
        bookingReference.id;

    // ============================================================
    // BOOKING MODEL
    // ============================================================

    final BookingModel booking =
    BookingModel(
      bookingId: bookingId,
      userId: currentUser.uid,

      source: source,
      destination: destination,
      via: via,

      journeyType: journeyType,

      // IMPORTANT:
      // Use normalized date.
      journeyDate:
      normalizedJourneyDate,

      passengerCount:
      passengerCount,

      totalFare:
      totalFare,

      // Payment will be changed after
      // Razorpay succeeds.
      paymentStatus:
      'pending',

      // Booking exists but payment
      // is not completed yet.
      bookingStatus:
      'active',

      createdAt:
      DateTime.now(),
    );

    // ============================================================
    // FIRESTORE BATCH
    // ============================================================

    final WriteBatch batch =
    _firestore.batch();

    // ============================================================
    // SAVE BOOKING
    // ============================================================

    batch.set(
      bookingReference,
      {
        ...booking.toMap(),

        // IMPORTANT:
        // Store normalized journey date.
        'journeyDate':
        Timestamp.fromDate(
          normalizedJourneyDate,
        ),

        'createdAt':
        FieldValue.serverTimestamp(),
      },
    );

    // ============================================================
    // CALCULATE INDIVIDUAL TICKET FARE
    // ============================================================

    final double individualFare =
        totalFare / passengerCount;

    // ============================================================
    // CREATE SEPARATE TICKET FOR EVERY PASSENGER
    // ============================================================

    for (int i = 0;
    i < passengerCount;
    i++) {
      final DocumentReference<
          Map<String, dynamic>>
      ticketReference =
      _firestore
          .collection('tickets')
          .doc();

      final String ticketId =
          ticketReference.id;

      // ----------------------------------------------------------
      // TEMPORARY QR TOKEN
      // ----------------------------------------------------------
      //
      // This is kept exactly as your existing booking flow.
      // Transfer tokens are handled separately by
      // TicketTransferService.
      // ----------------------------------------------------------

      final String qrToken =
          '${ticketId}_'
          '${DateTime.now().microsecondsSinceEpoch}_'
          '$i';

      // ==========================================================
      // TICKET MODEL
      // ==========================================================

      final TicketModel ticket =
      TicketModel(
        ticketId: ticketId,

        bookingId:
        bookingId,

        ownerId:
        currentUser.uid,

        passengerName:
        passengerNames[i],

        source:
        source,

        destination:
        destination,

        via:
        via,

        // Mumbai Local project scope.
        // Passenger does not select a train
        // during booking.
        trainName:
        'Mumbai Local',

        trainNumber:
        '',

        fare:
        individualFare,

        journeyType:
        journeyType,

        // --------------------------------------------------------
        // PAYMENT IS CURRENTLY PENDING
        // --------------------------------------------------------
        //
        // Razorpay verification will change this
        // to "valid" after successful payment.
        // --------------------------------------------------------

        status:
        'pending_payment',

        qrToken:
        qrToken,

        // IMPORTANT:
        // Use normalized date.
        journeyDate:
        normalizedJourneyDate,

        createdAt:
        DateTime.now(),
      );

      // ==========================================================
      // SAVE TICKET
      // ==========================================================

      batch.set(
        ticketReference,
        {
          ...ticket.toMap(),

          // IMPORTANT:
          // Store normalized journey date.
          'journeyDate':
          Timestamp.fromDate(
            normalizedJourneyDate,
          ),

          'createdAt':
          FieldValue.serverTimestamp(),
        },
      );
    }

    // ============================================================
    // COMMIT BOOKING + ALL TICKETS TOGETHER
    // ============================================================

    await batch.commit();

    return bookingId;
  }

  // ============================================================
  // GET MY BOOKINGS
  // ============================================================

  Stream<List<BookingModel>>
  getMyBookings() {
    final User? currentUser =
        _auth.currentUser;

    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('bookings')
        .where(
      'userId',
      isEqualTo:
      currentUser.uid,
    )
        .orderBy(
      'createdAt',
      descending: true,
    )
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs
            .map(
              (doc) {
            return BookingModel.fromMap(
              doc.data(),
            );
          },
        )
            .toList();
      },
    );
  }

  // ============================================================
  // GET MY VALID TICKETS
  // ============================================================

  Stream<List<TicketModel>>
  getMyTickets() {
    final User? currentUser =
        _auth.currentUser;

    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('tickets')
        .where(
      'ownerId',
      isEqualTo:
      currentUser.uid,
    )
        .where(
      'status',
      isEqualTo: 'valid',
    )
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs
            .map(
              (doc) {
            return TicketModel.fromMap(
              doc.data(),
            );
          },
        )
            .toList();
      },
    );
  }

  // ============================================================
  // GET TICKET BY ID
  // ============================================================

  Future<TicketModel?>
  getTicketById(
      String ticketId,
      ) async {
    final DocumentSnapshot<
        Map<String, dynamic>>
    document =
    await _firestore
        .collection('tickets')
        .doc(ticketId)
        .get();

    if (!document.exists ||
        document.data() == null) {
      return null;
    }

    return TicketModel.fromMap(
      document.data()!,
    );
  }
}