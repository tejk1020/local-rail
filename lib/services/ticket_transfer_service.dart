import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ticket_model.dart';

class TicketTransferService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // REVERT WINDOW
  // ============================================================
  //
  // After a transfer is accepted, the original sender has
  // 10 minutes to revert the transfer.
  //
  // After 10 minutes, the transfer cannot be reverted.
  // ============================================================

  static const Duration _revertWindow =
  Duration(minutes: 10);

  // ============================================================
  // CURRENT USER
  // ============================================================

  String get _currentUserId {
    final User? user =
        _auth.currentUser;

    if (user == null) {
      throw Exception(
        'You must be logged in to transfer a ticket.',
      );
    }

    return user.uid;
  }

  // ============================================================
  // NORMALIZE EMAIL
  // ============================================================

  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  // ============================================================
  // NORMALIZE PHONE
  // ============================================================

  String _normalizePhone(String phone) {
    String value =
    phone.trim();

    // Remove spaces, hyphens and brackets.
    value = value.replaceAll(
      RegExp(r'[\s\-\(\)]'),
      '',
    );

    // Convert +91XXXXXXXXXX to XXXXXXXXXX.
    if (value.startsWith('+91') &&
        value.length == 13) {
      value =
          value.substring(3);
    }

    // Convert 91XXXXXXXXXX to XXXXXXXXXX.
    if (value.startsWith('91') &&
        value.length == 12) {
      value =
          value.substring(2);
    }

    return value;
  }

  // ============================================================
  // CHECK TODAY
  // ============================================================

  bool _isToday(DateTime? date) {
    if (date == null) {
      return false;
    }

    final DateTime now =
    DateTime.now();

    return date.year ==
        now.year &&
        date.month ==
            now.month &&
        date.day ==
            now.day;
  }

  // ============================================================
  // GENERATE SECURE TOKEN
  // ============================================================

  String _generateSecureToken() {
    final Random random =
    Random.secure();

    final List<int> bytes =
    List<int>.generate(
      32,
          (_) => random.nextInt(256),
    );

    return base64UrlEncode(bytes);
  }

  // ============================================================
  // HASH TOKEN
  // ============================================================

  String _hashToken(String token) {
    final List<int> bytes =
    utf8.encode(token);

    final Digest digest =
    sha256.convert(bytes);

    return digest.toString();
  }

  // ============================================================
  // FIND USER BY EMAIL
  // ============================================================

  Future<QueryDocumentSnapshot<
      Map<String, dynamic>>?>
  _findUserByEmail(
      String email,
      ) async {
    final QuerySnapshot<
        Map<String, dynamic>> result =
    await _firestore
        .collection('users')
        .where(
      'email',
      isEqualTo:
      _normalizeEmail(email),
    )
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return null;
    }

    return result.docs.first;
  }

  // ============================================================
  // FIND USER BY PHONE
  // ============================================================

  Future<QueryDocumentSnapshot<
      Map<String, dynamic>>?>
  _findUserByPhone(
      String phone,
      ) async {
    final String normalizedPhone =
    _normalizePhone(phone);

    final QuerySnapshot<
        Map<String, dynamic>> result =
    await _firestore
        .collection('users')
        .where(
      'phone',
      isEqualTo:
      normalizedPhone,
    )
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return null;
    }

    return result.docs.first;
  }

  // ============================================================
  // FIND RECIPIENT
  // ============================================================

  Future<Map<String, dynamic>>
  findRegisteredRecipient({
    String? email,
    String? phone,
  }) async {
    if ((email == null ||
        email.trim().isEmpty) &&
        (phone == null ||
            phone.trim().isEmpty)) {
      throw Exception(
        'Please enter an email ID or mobile number.',
      );
    }

    QueryDocumentSnapshot<
        Map<String, dynamic>>? recipient;

    if (email != null &&
        email.trim().isNotEmpty) {
      recipient =
      await _findUserByEmail(
        email,
      );
    } else if (phone != null &&
        phone.trim().isNotEmpty) {
      recipient =
      await _findUserByPhone(
        phone,
      );
    }

    if (recipient == null) {
      throw Exception(
        'This recipient is not registered in Smart Local Train.',
      );
    }

    final Map<String, dynamic> data =
    recipient.data();

    return {
      'uid': recipient.id,
      'name':
      data['name'] ??
          'Passenger',
      'email':
      data['email'] ??
          '',
      'phone':
      data['phone'] ??
          '',
    };
  }

  // ============================================================
  // CREATE TRANSFER
  // ============================================================

  Future<Map<String, dynamic>>
  createTransfer({
    required TicketModel ticket,
    String? recipientEmail,
    String? recipientPhone,
  }) async {
    final String currentUserId =
        _currentUserId;

    // ----------------------------------------------------------
    // CHECK OWNER
    // ----------------------------------------------------------

    if (ticket.ownerId !=
        currentUserId) {
      throw Exception(
        'You are not the current owner of this ticket.',
      );
    }

    // ----------------------------------------------------------
    // CHECK TICKET STATUS
    // ----------------------------------------------------------

    if (ticket.status
        .toLowerCase() !=
        'valid') {
      throw Exception(
        'Only a valid ticket can be transferred.',
      );
    }

    // ----------------------------------------------------------
    // CHECK JOURNEY DATE
    // ----------------------------------------------------------

    if (!_isToday(
      ticket.journeyDate,
    )) {
      throw Exception(
        'Only today\'s ticket can be transferred.',
      );
    }

    // ----------------------------------------------------------
    // FIND RECIPIENT
    // ----------------------------------------------------------

    final Map<String, dynamic>
    recipient =
    await findRegisteredRecipient(
      email: recipientEmail,
      phone: recipientPhone,
    );

    final String recipientId =
    recipient['uid'] as String;

    // ----------------------------------------------------------
    // PREVENT SELF TRANSFER
    // ----------------------------------------------------------

    if (recipientId ==
        currentUserId) {
      throw Exception(
        'You cannot transfer a ticket to yourself.',
      );
    }

    // ----------------------------------------------------------
    // CHECK EXISTING TRANSFERS
    // ----------------------------------------------------------

    final QuerySnapshot<
        Map<String, dynamic>> existing =
    await _firestore
        .collection(
      'ticket_transfers',
    )
        .where(
      'ticketId',
      isEqualTo:
      ticket.ticketId,
    )
        .limit(20)
        .get();

    for (final doc
    in existing.docs) {
      final Map<String, dynamic>
      data =
      doc.data();

      if (data['status'] ==
          'pending') {
        throw Exception(
          'This ticket already has a pending transfer.',
        );
      }
    }

    // ----------------------------------------------------------
    // GENERATE ONE-TIME TOKEN
    // ----------------------------------------------------------

    final String rawToken =
    _generateSecureToken();

    final String tokenHash =
    _hashToken(rawToken);

    // ----------------------------------------------------------
    // EXPIRATION
    // ----------------------------------------------------------
    //
    // Ticket is valid only today.
    // Transfer token therefore expires at the
    // end of today.
    // ----------------------------------------------------------

    final DateTime now =
    DateTime.now();

    final DateTime expiresAt =
    DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    );

    // ----------------------------------------------------------
    // TRANSFER DOCUMENT
    // ----------------------------------------------------------

    final DocumentReference<
        Map<String, dynamic>>
    transferRef =
    _firestore
        .collection(
      'ticket_transfers',
    )
        .doc();

    final String deliveryMethod =
    recipientEmail != null &&
        recipientEmail
            .trim()
            .isNotEmpty
        ? 'email'
        : 'sms';

    await transferRef.set({
      'transferId':
      transferRef.id,

      'ticketId':
      ticket.ticketId,

      'bookingId':
      ticket.bookingId,

      'fromUserId':
      currentUserId,

      'toUserId':
      recipientId,

      'toName':
      recipient['name'],

      'toEmail':
      recipient['email'],

      'toPhone':
      recipient['phone'],

      'deliveryMethod':
      deliveryMethod,

      'status':
      'pending',

      // NEVER store raw token.
      'tokenHash':
      tokenHash,

      'createdAt':
      FieldValue.serverTimestamp(),

      'expiresAt':
      Timestamp.fromDate(
        expiresAt,
      ),

      'acceptedAt':
      null,

      'rejectedAt':
      null,

      'cancelledAt':
      null,

      // Added for revert support.
      'revertedAt':
      null,
    });

    // ----------------------------------------------------------
    // RETURN INFORMATION REQUIRED BY DELIVERY LAYER
    // ----------------------------------------------------------

    return {
      'transferId':
      transferRef.id,

      'token':
      rawToken,

      'recipientId':
      recipientId,

      'recipientName':
      recipient['name'],

      'recipientEmail':
      recipient['email'],

      'recipientPhone':
      recipient['phone'],

      'deliveryMethod':
      deliveryMethod,

      'expiresAt':
      expiresAt,
    };
  }

  // ============================================================
  // GET TRANSFER
  // ============================================================

  Future<DocumentSnapshot<
      Map<String, dynamic>>>
  getTransfer(
      String transferId,
      ) async {
    return _firestore
        .collection(
      'ticket_transfers',
    )
        .doc(transferId)
        .get();
  }

  // ============================================================
  // ACCEPT TRANSFER
  // ============================================================
  //
  // The recipient accepts the transfer.
  //
  // Firestore transaction performs the complete operation
  // atomically:
  //
  // 1. Verify transfer exists.
  // 2. Verify current user is the recipient.
  // 3. Verify transfer is pending.
  // 4. Verify transfer has not expired.
  // 5. Verify ticket exists.
  // 6. Verify ticket still belongs to sender.
  // 7. Verify ticket is valid.
  // 8. Verify journey date is today.
  // 9. Verify booking ID matches.
  // 10. Change ticket owner.
  // 11. Mark transfer as accepted.
  //
  // This prevents two devices from successfully accepting
  // the same transfer at the same time.
  // ============================================================

  Future<void> acceptTransfer({
    required String transferId,
  }) async {
    final String currentUserId =
        _currentUserId;

    final DocumentReference<
        Map<String, dynamic>>
    transferRef =
    _firestore
        .collection(
      'ticket_transfers',
    )
        .doc(transferId);

    final String result =
    await _firestore
        .runTransaction<String>(
          (transaction) async {
        // ------------------------------------------------------
        // GET TRANSFER
        // ------------------------------------------------------

        final DocumentSnapshot<
            Map<String, dynamic>>
        transferSnapshot =
        await transaction.get(
          transferRef,
        );

        if (!transferSnapshot.exists) {
          throw Exception(
            'This transfer request no longer exists.',
          );
        }

        final Map<String, dynamic>
        transferData =
        transferSnapshot.data()!;

        // ------------------------------------------------------
        // CHECK RECIPIENT
        // ------------------------------------------------------

        if (transferData[
        'toUserId'] !=
            currentUserId) {
          throw Exception(
            'You are not authorized to accept this transfer.',
          );
        }

        // ------------------------------------------------------
        // CHECK STATUS
        // ------------------------------------------------------

        final String status =
        (transferData['status'] ??
            '')
            .toString()
            .toLowerCase();

        if (status !=
            'pending') {
          throw Exception(
            'This transfer is no longer pending.',
          );
        }

        // ------------------------------------------------------
        // CHECK EXPIRATION
        // ------------------------------------------------------

        final Timestamp? expiresAt =
        transferData[
        'expiresAt'] as Timestamp?;

        if (expiresAt == null) {
          throw Exception(
            'This transfer has no valid expiration time.',
          );
        }

        final DateTime now =
        DateTime.now();

        if (expiresAt
            .toDate()
            .isBefore(now)) {
          transaction.update(
            transferRef,
            {
              'status':
              'expired',
            },
          );

          return 'expired';
        }

        // ------------------------------------------------------
        // GET TICKET
        // ------------------------------------------------------

        final String ticketId =
        (transferData[
        'ticketId'] ??
            '')
            .toString();

        if (ticketId.isEmpty) {
          throw Exception(
            'Invalid transfer: ticket ID is missing.',
          );
        }

        final DocumentReference<
            Map<String, dynamic>>
        ticketRef =
        _firestore
            .collection('tickets')
            .doc(ticketId);

        final DocumentSnapshot<
            Map<String, dynamic>>
        ticketSnapshot =
        await transaction.get(
          ticketRef,
        );

        if (!ticketSnapshot.exists) {
          throw Exception(
            'The ticket associated with this transfer '
                'no longer exists.',
          );
        }

        final Map<String, dynamic>
        ticketData =
        ticketSnapshot.data()!;

        // ------------------------------------------------------
        // VERIFY CURRENT OWNER
        // ------------------------------------------------------

        final String fromUserId =
        (transferData[
        'fromUserId'] ??
            '')
            .toString();

        final String currentOwnerId =
        (ticketData[
        'ownerId'] ??
            '')
            .toString();

        if (currentOwnerId !=
            fromUserId) {
          throw Exception(
            'This ticket is no longer owned by the sender.',
          );
        }

        // ------------------------------------------------------
        // VERIFY TICKET STATUS
        // ------------------------------------------------------

        final String ticketStatus =
        (ticketData['status'] ??
            '')
            .toString()
            .toLowerCase();

        if (ticketStatus !=
            'valid') {
          throw Exception(
            'Only a valid ticket can be accepted.',
          );
        }

        // ------------------------------------------------------
        // VERIFY JOURNEY DATE
        // ------------------------------------------------------

        DateTime? journeyDate;

        final dynamic journeyDateValue =
        ticketData[
        'journeyDate'];

        if (journeyDateValue
        is Timestamp) {
          journeyDate =
              journeyDateValue.toDate();
        } else if (journeyDateValue
        is DateTime) {
          journeyDate =
              journeyDateValue;
        }

        if (!_isToday(
          journeyDate,
        )) {
          throw Exception(
            'This ticket is not valid for today.',
          );
        }

        // ------------------------------------------------------
        // VERIFY BOOKING ID
        // ------------------------------------------------------

        final String transferBookingId =
        (transferData[
        'bookingId'] ??
            '')
            .toString();

        final String ticketBookingId =
        (ticketData[
        'bookingId'] ??
            '')
            .toString();

        if (transferBookingId
            .isNotEmpty &&
            ticketBookingId !=
                transferBookingId) {
          throw Exception(
            'The transfer and ticket do not match.',
          );
        }

        // ------------------------------------------------------
        // CHANGE ONLY THIS TICKET OWNER
        // ------------------------------------------------------

        transaction.update(
          ticketRef,
          {
            'ownerId':
            currentUserId,
          },
        );

        // ------------------------------------------------------
        // MARK TRANSFER ACCEPTED
        // ------------------------------------------------------

        transaction.update(
          transferRef,
          {
            'status':
            'accepted',

            'acceptedAt':
            FieldValue.serverTimestamp(),

            // Make sure a previous revert timestamp
            // cannot remain on a reused document.
            'revertedAt':
            null,
          },
        );

        return 'accepted';
      },
    );

    // ----------------------------------------------------------
    // HANDLE EXPIRATION
    // ----------------------------------------------------------

    if (result ==
        'expired') {
      throw Exception(
        'This transfer has expired and can no longer be accepted.',
      );
    }
  }

  // ============================================================
  // REJECT TRANSFER
  // ============================================================
  //
  // The recipient rejects the transfer.
  //
  // IMPORTANT:
  // Rejecting a transfer does NOT change ticket ownership.
  // The ticket remains with the original owner.
  // ============================================================

  Future<void> rejectTransfer({
    required String transferId,
  }) async {
    final String currentUserId =
        _currentUserId;

    final DocumentReference<
        Map<String, dynamic>>
    transferRef =
    _firestore
        .collection(
      'ticket_transfers',
    )
        .doc(transferId);

    final String result =
    await _firestore
        .runTransaction<String>(
          (transaction) async {
        // ------------------------------------------------------
        // GET TRANSFER
        // ------------------------------------------------------

        final DocumentSnapshot<
            Map<String, dynamic>>
        transferSnapshot =
        await transaction.get(
          transferRef,
        );

        if (!transferSnapshot.exists) {
          throw Exception(
            'This transfer request no longer exists.',
          );
        }

        final Map<String, dynamic>
        transferData =
        transferSnapshot.data()!;

        // ------------------------------------------------------
        // CHECK RECIPIENT
        // ------------------------------------------------------

        if (transferData[
        'toUserId'] !=
            currentUserId) {
          throw Exception(
            'You are not authorized to reject this transfer.',
          );
        }

        // ------------------------------------------------------
        // CHECK STATUS
        // ------------------------------------------------------

        final String status =
        (transferData['status'] ??
            '')
            .toString()
            .toLowerCase();

        if (status !=
            'pending') {
          throw Exception(
            'This transfer is no longer pending.',
          );
        }

        // ------------------------------------------------------
        // CHECK EXPIRATION
        // ------------------------------------------------------

        final Timestamp? expiresAt =
        transferData[
        'expiresAt'] as Timestamp?;

        if (expiresAt != null &&
            expiresAt
                .toDate()
                .isBefore(
              DateTime.now(),
            )) {
          transaction.update(
            transferRef,
            {
              'status':
              'expired',
            },
          );

          return 'expired';
        }

        // ------------------------------------------------------
        // MARK TRANSFER REJECTED
        // ------------------------------------------------------

        transaction.update(
          transferRef,
          {
            'status':
            'rejected',

            'rejectedAt':
            FieldValue.serverTimestamp(),
          },
        );

        return 'rejected';
      },
    );

    // ----------------------------------------------------------
    // HANDLE EXPIRATION
    // ----------------------------------------------------------

    if (result ==
        'expired') {
      throw Exception(
        'This transfer has already expired.',
      );
    }
  }

  // ============================================================
  // REVERT ACCEPTED TRANSFER
  // ============================================================
  //
  // OPTION A:
  //
  // The original sender can revert an ACCEPTED transfer
  // within 10 minutes of acceptance.
  //
  // Example:
  //
  // 10:00 - Sender transfers ticket
  // 10:02 - Receiver accepts
  // 10:02 - 10-minute revert window starts
  // 10:12 - Revert is no longer allowed
  //
  // Firestore transaction:
  //
  // 1. Verify transfer exists.
  // 2. Verify current user is original sender.
  // 3. Verify status is accepted.
  // 4. Verify acceptedAt exists.
  // 5. Verify 10-minute window.
  // 6. Verify ticket exists.
  // 7. Verify ticket currently belongs to receiver.
  // 8. Verify ticket is still valid.
  // 9. Verify journey date is today.
  // 10. Return ownership to original sender.
  // 11. Mark transfer as reverted.
  //
  // This affects ONLY the transferred ticket.
  // Other tickets in the same booking are untouched.
  // ============================================================

  Future<void> revertTransfer({
    required String transferId,
  }) async {
    final String currentUserId =
        _currentUserId;

    final DocumentReference<
        Map<String, dynamic>>
    transferRef =
    _firestore
        .collection(
      'ticket_transfers',
    )
        .doc(transferId);

    final String result =
    await _firestore
        .runTransaction<String>(
          (transaction) async {
        // ------------------------------------------------------
        // GET TRANSFER
        // ------------------------------------------------------

        final DocumentSnapshot<
            Map<String, dynamic>>
        transferSnapshot =
        await transaction.get(
          transferRef,
        );

        if (!transferSnapshot.exists) {
          throw Exception(
            'This transfer request no longer exists.',
          );
        }

        final Map<String, dynamic>
        transferData =
        transferSnapshot.data()!;

        // ------------------------------------------------------
        // VERIFY ORIGINAL SENDER
        // ------------------------------------------------------

        final String fromUserId =
        (transferData[
        'fromUserId'] ??
            '')
            .toString();

        if (fromUserId !=
            currentUserId) {
          throw Exception(
            'Only the original sender can revert this transfer.',
          );
        }

        // ------------------------------------------------------
        // VERIFY STATUS
        // ------------------------------------------------------

        final String status =
        (transferData['status'] ??
            '')
            .toString()
            .toLowerCase();

        if (status !=
            'accepted') {
          throw Exception(
            'Only an accepted transfer can be reverted.',
          );
        }

        // ------------------------------------------------------
        // GET ACCEPTED TIME
        // ------------------------------------------------------

        final Timestamp? acceptedAt =
        transferData[
        'acceptedAt'] as Timestamp?;

        if (acceptedAt == null) {
          throw Exception(
            'The acceptance time for this transfer is missing.',
          );
        }

        final DateTime acceptedDate =
        acceptedAt.toDate();

        final DateTime now =
        DateTime.now();

        // ------------------------------------------------------
        // CHECK 10-MINUTE REVERT WINDOW
        // ------------------------------------------------------

        final Duration elapsed =
        now.difference(
          acceptedDate,
        );

        if (elapsed >
            _revertWindow) {
          transaction.update(
            transferRef,
            {
              'status':
              'revert_expired',
            },
          );

          return 'revert_expired';
        }

        // ------------------------------------------------------
        // GET TICKET ID
        // ------------------------------------------------------

        final String ticketId =
        (transferData[
        'ticketId'] ??
            '')
            .toString();

        if (ticketId.isEmpty) {
          throw Exception(
            'Invalid transfer: ticket ID is missing.',
          );
        }

        // ------------------------------------------------------
        // GET RECEIVER ID
        // ------------------------------------------------------

        final String toUserId =
        (transferData[
        'toUserId'] ??
            '')
            .toString();

        if (toUserId.isEmpty) {
          throw Exception(
            'Invalid transfer: recipient ID is missing.',
          );
        }

        // ------------------------------------------------------
        // GET TICKET
        // ------------------------------------------------------

        final DocumentReference<
            Map<String, dynamic>>
        ticketRef =
        _firestore
            .collection('tickets')
            .doc(ticketId);

        final DocumentSnapshot<
            Map<String, dynamic>>
        ticketSnapshot =
        await transaction.get(
          ticketRef,
        );

        if (!ticketSnapshot.exists) {
          throw Exception(
            'The ticket associated with this transfer '
                'no longer exists.',
          );
        }

        final Map<String, dynamic>
        ticketData =
        ticketSnapshot.data()!;

        // ------------------------------------------------------
        // VERIFY CURRENT TICKET OWNER
        // ------------------------------------------------------
        //
        // The ticket MUST currently belong to the receiver.
        //
        // If ownership has changed by another valid operation,
        // we stop the revert instead of overwriting it.
        // ------------------------------------------------------

        final String currentOwnerId =
        (ticketData[
        'ownerId'] ??
            '')
            .toString();

        if (currentOwnerId !=
            toUserId) {
          throw Exception(
            'This ticket is no longer owned by the recipient.',
          );
        }

        // ------------------------------------------------------
        // VERIFY TICKET STATUS
        // ------------------------------------------------------

        final String ticketStatus =
        (ticketData['status'] ??
            '')
            .toString()
            .toLowerCase();

        if (ticketStatus !=
            'valid') {
          throw Exception(
            'This ticket can no longer be reverted.',
          );
        }

        // ------------------------------------------------------
        // VERIFY JOURNEY DATE
        // ------------------------------------------------------

        DateTime? journeyDate;

        final dynamic journeyDateValue =
        ticketData[
        'journeyDate'];

        if (journeyDateValue
        is Timestamp) {
          journeyDate =
              journeyDateValue.toDate();
        } else if (journeyDateValue
        is DateTime) {
          journeyDate =
              journeyDateValue;
        }

        if (!_isToday(
          journeyDate,
        )) {
          throw Exception(
            'This ticket is no longer valid for today.',
          );
        }

        // ------------------------------------------------------
        // VERIFY BOOKING ID
        // ------------------------------------------------------

        final String transferBookingId =
        (transferData[
        'bookingId'] ??
            '')
            .toString();

        final String ticketBookingId =
        (ticketData[
        'bookingId'] ??
            '')
            .toString();

        if (transferBookingId
            .isNotEmpty &&
            ticketBookingId !=
                transferBookingId) {
          throw Exception(
            'The transfer and ticket do not match.',
          );
        }

        // ------------------------------------------------------
        // RETURN TICKET TO ORIGINAL OWNER
        // ------------------------------------------------------

        transaction.update(
          ticketRef,
          {
            'ownerId':
            fromUserId,
          },
        );

        // ------------------------------------------------------
        // MARK TRANSFER REVERTED
        // ------------------------------------------------------

        transaction.update(
          transferRef,
          {
            'status':
            'reverted',

            'revertedAt':
            FieldValue.serverTimestamp(),
          },
        );

        return 'reverted';
      },
    );

    // ----------------------------------------------------------
    // HANDLE REVERT WINDOW EXPIRATION
    // ----------------------------------------------------------

    if (result ==
        'revert_expired') {
      throw Exception(
        'The 10-minute revert window has expired.',
      );
    }
  }

  // ============================================================
  // CHECK WHETHER TRANSFER CAN BE REVERTED
  // ============================================================
  //
  // This method is used by the UI to decide whether the
  // "Revert Transfer" button should be displayed.
  //
  // Returns TRUE only when:
  //
  // - transfer belongs to current user
  // - status is accepted
  // - acceptedAt exists
  // - less than 10 minutes have passed
  // ============================================================

  bool canRevertTransfer(
      Map<String, dynamic> transfer,
      ) {
    final String currentUserId =
        _currentUserId;

    final String fromUserId =
    (transfer['fromUserId'] ??
        '')
        .toString();

    final String status =
    (transfer['status'] ??
        '')
        .toString()
        .toLowerCase();

    if (fromUserId !=
        currentUserId) {
      return false;
    }

    if (status !=
        'accepted') {
      return false;
    }

    final dynamic acceptedAtValue =
    transfer['acceptedAt'];

    if (acceptedAtValue
    is! Timestamp) {
      return false;
    }

    final DateTime acceptedAt =
    acceptedAtValue.toDate();

    final DateTime now =
    DateTime.now();

    final Duration elapsed =
    now.difference(
      acceptedAt,
    );

    return elapsed <=
        _revertWindow;
  }

  // ============================================================
  // GET REMAINING REVERT TIME
  // ============================================================
  //
  // Returns how much time is left in the 10-minute window.
  //
  // Returns Duration.zero if the window has expired.
  // ============================================================

  Duration getRemainingRevertTime(
      Map<String, dynamic> transfer,
      ) {
    final dynamic acceptedAtValue =
    transfer['acceptedAt'];

    if (acceptedAtValue
    is! Timestamp) {
      return Duration.zero;
    }

    final DateTime acceptedAt =
    acceptedAtValue.toDate();

    final DateTime revertDeadline =
    acceptedAt.add(
      _revertWindow,
    );

    final DateTime now =
    DateTime.now();

    final Duration remaining =
    revertDeadline
        .difference(now);

    if (remaining.isNegative) {
      return Duration.zero;
    }

    return remaining;
  }

  // ============================================================
  // GET OUTGOING TRANSFERS
  // ============================================================

  Stream<
      List<Map<String, dynamic>>>
  getOutgoingTransfers() {
    final String userId =
        _currentUserId;

    return _firestore
        .collection(
      'ticket_transfers',
    )
        .where(
      'fromUserId',
      isEqualTo: userId,
    )
        .snapshots()
        .map(
          (snapshot) {
        final List<
            Map<String, dynamic>>
        transfers =
        snapshot.docs
            .map(
              (doc) {
            final Map<String, dynamic>
            data =
            doc.data();

            return {
              ...data,
              'documentId':
              doc.id,
            };
          },
        )
            .toList();

        transfers.sort(
              (a, b) {
            final Timestamp? aTime =
            a['createdAt']
            as Timestamp?;

            final Timestamp? bTime =
            b['createdAt']
            as Timestamp?;

            return (bTime
                ?.millisecondsSinceEpoch ??
                0)
                .compareTo(
              aTime?.millisecondsSinceEpoch ??
                  0,
            );
          },
        );

        return transfers;
      },
    );
  }

  // ============================================================
  // GET INCOMING TRANSFERS
  // ============================================================

  Stream<
      List<Map<String, dynamic>>>
  getIncomingTransfers() {
    final String userId =
        _currentUserId;

    return _firestore
        .collection(
      'ticket_transfers',
    )
        .where(
      'toUserId',
      isEqualTo: userId,
    )
        .snapshots()
        .map(
          (snapshot) {
        final List<
            Map<String, dynamic>>
        transfers =
        snapshot.docs
            .map(
              (doc) {
            final Map<String, dynamic>
            data =
            doc.data();

            return {
              ...data,
              'documentId':
              doc.id,
            };
          },
        )
            .toList();

        transfers.sort(
              (a, b) {
            final Timestamp? aTime =
            a['createdAt']
            as Timestamp?;

            final Timestamp? bTime =
            b['createdAt']
            as Timestamp?;

            return (bTime
                ?.millisecondsSinceEpoch ??
                0)
                .compareTo(
              aTime?.millisecondsSinceEpoch ??
                  0,
            );
          },
        );

        return transfers;
      },
    );
  }
}