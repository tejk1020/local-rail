import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DemoPaymentService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<void> completeDemoPayment({
    required String bookingId,
    required String paymentId,
  }) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'You are not logged in. Please login again.',
      );
    }

    final String uid = user.uid;

    if (bookingId.trim().isEmpty) {
      throw Exception(
        'Booking ID is missing.',
      );
    }

    final DocumentReference<Map<String, dynamic>> bookingRef =
    _firestore
        .collection('bookings')
        .doc(bookingId);

    final DocumentSnapshot<Map<String, dynamic>>
    bookingSnapshot =
    await bookingRef.get();

    if (!bookingSnapshot.exists) {
      throw Exception(
        'Booking not found.',
      );
    }

    final Map<String, dynamic> bookingData =
        bookingSnapshot.data() ?? {};

    final String bookingUserId =
    (bookingData['userId'] ?? '').toString();

    if (bookingUserId != uid) {
      throw Exception(
        'You do not have permission to complete this booking.',
      );
    }

    final QuerySnapshot<Map<String, dynamic>>
    ticketSnapshot =
    await _firestore
        .collection('tickets')
        .where(
      'bookingId',
      isEqualTo: bookingId,
    )
        .where(
      'ownerId',
      isEqualTo: uid,
    )
        .get();

    if (ticketSnapshot.docs.isEmpty) {
      throw Exception(
        'No tickets were found for this booking.',
      );
    }

    final WriteBatch batch =
    _firestore.batch();

    batch.update(
      bookingRef,
      <String, dynamic>{
        'paymentStatus': 'paid',
        'bookingStatus': 'active',
        'paymentId': paymentId,
        'paymentMode': 'demo',
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );

    for (final ticketDoc in ticketSnapshot.docs) {
      batch.update(
        ticketDoc.reference,
        <String, dynamic>{
          'status': 'valid',
          'paymentMode': 'demo',
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }
}