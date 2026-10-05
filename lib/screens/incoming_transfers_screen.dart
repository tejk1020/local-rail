import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/ticket_transfer_service.dart';

class IncomingTransfersScreen extends StatefulWidget {
  const IncomingTransfersScreen({
    super.key,
  });

  @override
  State<IncomingTransfersScreen> createState() =>
      _IncomingTransfersScreenState();
}

class _IncomingTransfersScreenState
    extends State<IncomingTransfersScreen> {
  final TicketTransferService _transferService =
  TicketTransferService();

  final Set<String> _processingTransfers = {};

  // ============================================================
  // ACCEPT TRANSFER
  // ============================================================

  Future<void> _acceptTransfer(
      Map<String, dynamic> transfer,
      ) async {
    final String transferId = _getTransferId(transfer);

    if (transferId.isEmpty ||
        _processingTransfers.contains(transferId)) {
      return;
    }

    final bool? confirmed =
    await _showAcceptConfirmation();

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _processingTransfers.add(transferId);
    });

    try {
      await _transferService.acceptTransfer(
        transferId: transferId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ticket transfer accepted successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _cleanErrorMessage(e),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingTransfers.remove(transferId);
        });
      }
    }
  }

  // ============================================================
  // REJECT TRANSFER
  // ============================================================

  Future<void> _rejectTransfer(
      Map<String, dynamic> transfer,
      ) async {
    final String transferId = _getTransferId(transfer);

    if (transferId.isEmpty ||
        _processingTransfers.contains(transferId)) {
      return;
    }

    final bool? confirmed =
    await _showRejectConfirmation();

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _processingTransfers.add(transferId);
    });

    try {
      await _transferService.rejectTransfer(
        transferId: transferId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ticket transfer rejected.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _cleanErrorMessage(e),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingTransfers.remove(transferId);
        });
      }
    }
  }

  // ============================================================
  // ACCEPT CONFIRMATION
  // ============================================================

  Future<bool?> _showAcceptConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Accept Transfer?',
          ),
          content: const Text(
            'This ticket will be transferred to your account. '
                'The original owner will no longer own this ticket.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'CANCEL',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'ACCEPT',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // REJECT CONFIRMATION
  // ============================================================

  Future<bool?> _showRejectConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Reject Transfer?',
          ),
          content: const Text(
            'Are you sure you want to reject this ticket transfer?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'CANCEL',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'REJECT',
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LOAD TICKET + SENDER DETAILS
  // ============================================================

  Future<Map<String, dynamic>?> _loadTransferDetails(
      Map<String, dynamic> transfer,
      ) async {
    final String ticketId =
    (transfer['ticketId'] ?? '').toString();

    if (ticketId.isEmpty) {
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>>
    ticketSnapshot =
    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(ticketId)
        .get();

    if (!ticketSnapshot.exists) {
      return null;
    }

    final Map<String, dynamic> ticketData =
    ticketSnapshot.data()!;

    String senderName = 'Passenger';

    final String fromUserId =
    (transfer['fromUserId'] ?? '').toString();

    if (fromUserId.isNotEmpty) {
      final DocumentSnapshot<Map<String, dynamic>>
      userSnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(fromUserId)
          .get();

      if (userSnapshot.exists) {
        final Map<String, dynamic> userData =
        userSnapshot.data()!;

        senderName =
            (userData['name'] ?? 'Passenger')
                .toString();
      }
    }

    return {
      'ticket': ticketData,
      'senderName': senderName,
    };
  }

  // ============================================================
  // TRANSFER ID
  // ============================================================

  String _getTransferId(
      Map<String, dynamic> transfer,
      ) {
    final dynamic transferId =
    transfer['transferId'];

    if (transferId != null &&
        transferId.toString().trim().isNotEmpty) {
      return transferId.toString();
    }

    final dynamic documentId =
    transfer['documentId'];

    if (documentId != null &&
        documentId.toString().trim().isNotEmpty) {
      return documentId.toString();
    }

    return '';
  }

  // ============================================================
  // STATUS
  // ============================================================

  String _getStatus(
      Map<String, dynamic> transfer,
      ) {
    return (transfer['status'] ?? 'unknown')
        .toString()
        .toLowerCase();
  }

  // ============================================================
  // CHECK EXPIRATION
  // ============================================================

  bool _isExpired(
      Map<String, dynamic> transfer,
      ) {
    final dynamic value =
    transfer['expiresAt'];

    if (value is Timestamp) {
      return value.toDate().isBefore(
        DateTime.now(),
      );
    }

    return false;
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(
      dynamic value,
      ) {
    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }

    if (date == null) {
      return 'Today';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // FORMAT EXPIRATION
  // ============================================================

  String _formatExpiration(
      Map<String, dynamic> transfer,
      ) {
    final dynamic value =
    transfer['expiresAt'];

    if (value is! Timestamp) {
      return 'Expiration unavailable';
    }

    final DateTime date =
    value.toDate();

    final String hour =
    date.hour.toString().padLeft(2, '0');

    final String minute =
    date.minute.toString().padLeft(2, '0');

    final String day =
    date.day.toString().padLeft(2, '0');

    final String month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year} at $hour:$minute';
  }

  // ============================================================
  // CLEAN ERROR
  // ============================================================

  String _cleanErrorMessage(
      Object error,
      ) {
    final String message =
    error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Incoming Transfers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<
          List<Map<String, dynamic>>>(
        stream:
        _transferService.getIncomingTransfers(),
        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(
              snapshot.error.toString(),
            );
          }

          final List<
              Map<String, dynamic>>
          transfers =
              snapshot.data ??
                  <Map<String, dynamic>>[];

          if (transfers.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: transfers.length,
              itemBuilder: (
                  context,
                  index,
                  ) {
                return _buildTransferCard(
                  transfers[index],
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // TRANSFER CARD
  // ============================================================

  Widget _buildTransferCard(
      Map<String, dynamic> transfer,
      ) {
    final String status =
    _getStatus(transfer);

    final bool expired =
        status == 'pending' &&
            _isExpired(transfer);

    final bool isPending =
        status == 'pending' &&
            !expired;

    final bool isAccepted =
        status == 'accepted';

    final bool isRejected =
        status == 'rejected';

    final bool isExpiredStatus =
        status == 'expired';

    final String transferId =
    _getTransferId(transfer);

    final bool isProcessing =
    _processingTransfers.contains(
      transferId,
    );

    return FutureBuilder<
        Map<String, dynamic>?>(
      future: _loadTransferDetails(
        transfer,
      ),
      builder: (
          context,
          detailsSnapshot,
          ) {
        if (detailsSnapshot.connectionState ==
            ConnectionState.waiting) {
          return Card(
            margin: const EdgeInsets.only(
              bottom: 16,
            ),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final Map<String, dynamic>?
        details =
            detailsSnapshot.data;

        final Map<String, dynamic>
        ticket =
            details?['ticket']
            as Map<String, dynamic>? ??
                <String, dynamic>{};

        final String senderName =
        (details?['senderName'] ??
            'Passenger')
            .toString();

        final String source =
        (ticket['source'] ?? '')
            .toString();

        final String destination =
        (ticket['destination'] ?? '')
            .toString();

        final String via =
        (ticket['via'] ?? '')
            .toString();

        final double fare =
        _toDouble(ticket['fare']);

        final String journeyType =
        (ticket['journeyType'] ?? '')
            .toString();

        final String journeyDate =
        _formatDate(
          ticket['journeyDate'],
        );

        return Card(
          margin: const EdgeInsets.only(
            bottom: 16,
          ),
          elevation: 3,
          clipBehavior:
          Clip.antiAlias,
          child: Padding(
            padding:
            const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------
                // HEADER
                // ------------------------------------------------

                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration:
                      BoxDecoration(
                        color:
                        Colors.indigo
                            .withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),
                      child: const Icon(
                        Icons.train,
                        color:
                        Colors.indigo,
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          const Text(
                            'Ticket Transfer',
                            style:
                            TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            'From $senderName',
                            style:
                            TextStyle(
                              color: Colors
                                  .grey
                                  .shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildStatusChip(
                      status: expired
                          ? 'expired'
                          : status,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                const Divider(),

                const SizedBox(height: 18),

                // ------------------------------------------------
                // ROUTE
                // ------------------------------------------------

                if (source.isNotEmpty &&
                    destination.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              'FROM',
                              style:
                              TextStyle(
                                color: Colors
                                    .grey
                                    .shade600,
                                fontSize: 11,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              source,
                              style:
                              const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Padding(
                        padding:
                        EdgeInsets
                            .symmetric(
                          horizontal: 8,
                        ),
                        child: Icon(
                          Icons
                              .arrow_forward,
                          color:
                          Colors.indigo,
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .end,
                          children: [
                            Text(
                              'TO',
                              style:
                              TextStyle(
                                color: Colors
                                    .grey
                                    .shade600,
                                fontSize: 11,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              destination,
                              textAlign:
                              TextAlign.end,
                              style:
                              const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 18),

                // ------------------------------------------------
                // VIA
                // ------------------------------------------------

                if (via.isNotEmpty)
                  _buildDetailRow(
                    icon:
                    Icons.alt_route,
                    title: 'Via',
                    value: via,
                  ),

                // ------------------------------------------------
                // JOURNEY DATE
                // ------------------------------------------------

                _buildDetailRow(
                  icon:
                  Icons.calendar_today_outlined,
                  title: 'Journey',
                  value: journeyDate,
                ),

                const SizedBox(height: 10),

                // ------------------------------------------------
                // JOURNEY TYPE
                // ------------------------------------------------

                if (journeyType.isNotEmpty)
                  _buildDetailRow(
                    icon:
                    Icons.swap_horiz,
                    title: 'Type',
                    value:
                    _formatJourneyType(
                      journeyType,
                    ),
                  ),

                const SizedBox(height: 10),

                // ------------------------------------------------
                // FARE
                // ------------------------------------------------

                _buildDetailRow(
                  icon:
                  Icons.currency_rupee,
                  title: 'Fare',
                  value:
                  '₹${fare.toStringAsFixed(2)}',
                ),

                const SizedBox(height: 14),

                // ------------------------------------------------
                // EXPIRATION
                // ------------------------------------------------

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(12),
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.orange.shade50,
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .schedule_outlined,
                        size: 19,
                        color: Colors
                            .orange
                            .shade800,
                      ),
                      const SizedBox(
                        width: 9,
                      ),
                      Expanded(
                        child: Text(
                          'Transfer expires: '
                              '${_formatExpiration(transfer)}',
                          style:
                          TextStyle(
                            color: Colors
                                .orange
                                .shade900,
                            fontSize: 12,
                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ------------------------------------------------
                // STATUS MESSAGE
                // ------------------------------------------------

                if (isAccepted)
                  _buildResultMessage(
                    icon:
                    Icons.check_circle,
                    title:
                    'Transfer Accepted',
                    message:
                    'This ticket now belongs to your account.',
                    color: Colors.green,
                  ),

                if (isRejected)
                  _buildResultMessage(
                    icon: Icons.cancel,
                    title:
                    'Transfer Rejected',
                    message:
                    'The ticket remains with the original owner.',
                    color: Colors.grey,
                  ),

                if (isExpiredStatus ||
                    expired)
                  _buildResultMessage(
                    icon:
                    Icons.timer_off_outlined,
                    title:
                    'Transfer Expired',
                    message:
                    'This transfer can no longer be accepted.',
                    color: Colors.red,
                  ),

                // ------------------------------------------------
                // ACTION BUTTONS
                // ------------------------------------------------

                if (isPending &&
                    !expired) ...[
                  const SizedBox(
                    height: 18,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                        OutlinedButton.icon(
                          onPressed:
                          isProcessing
                              ? null
                              : () =>
                              _rejectTransfer(
                                transfer,
                              ),
                          icon:
                          const Icon(
                            Icons.close,
                          ),
                          label:
                          const Text(
                            'Reject',
                          ),
                          style:
                          OutlinedButton
                              .styleFrom(
                            foregroundColor:
                            Colors.red,
                            side: BorderSide(
                              color: Colors
                                  .red
                                  .shade300,
                            ),
                            minimumSize:
                            const Size(
                              0,
                              48,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child:
                        FilledButton.icon(
                          onPressed:
                          isProcessing
                              ? null
                              : () =>
                              _acceptTransfer(
                                transfer,
                              ),
                          icon: isProcessing
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2,
                              color:
                              Colors.white,
                            ),
                          )
                              : const Icon(
                            Icons.check,
                          ),
                          label: Text(
                            isProcessing
                                ? 'Processing...'
                                : 'Accept',
                          ),
                          style:
                          FilledButton
                              .styleFrom(
                            backgroundColor:
                            Colors.green,
                            minimumSize:
                            const Size(
                              0,
                              48,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 2,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: Colors.indigo,
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 70,
            child: Text(
              title,
              style: TextStyle(
                color:
                Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONVERT TO DOUBLE
  // ============================================================

  double _toDouble(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  // ============================================================
  // JOURNEY TYPE
  // ============================================================

  String _formatJourneyType(
      String type,
      ) {
    switch (type.toLowerCase()) {
      case 'one_way':
        return 'One Way';

      case 'return':
        return 'Return';

      case 'round_trip':
        return 'Round Trip';

      default:
        if (type.isEmpty) {
          return 'Not specified';
        }

        return type
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) {
            if (word.isEmpty) {
              return word;
            }

            return word[0].toUpperCase() +
                word.substring(1);
          },
        )
            .join(' ');
    }
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _buildStatusChip({
    required String status,
  }) {
    late Color backgroundColor;
    late Color foregroundColor;
    late IconData icon;
    late String label;

    switch (status) {
      case 'accepted':
        backgroundColor =
            Colors.green.shade50;
        foregroundColor =
            Colors.green.shade800;
        icon = Icons.check_circle;
        label = 'Accepted';
        break;

      case 'rejected':
        backgroundColor =
            Colors.grey.shade200;
        foregroundColor =
            Colors.grey.shade800;
        icon = Icons.cancel;
        label = 'Rejected';
        break;

      case 'expired':
        backgroundColor =
            Colors.red.shade50;
        foregroundColor =
            Colors.red.shade800;
        icon =
            Icons.timer_off_outlined;
        label = 'Expired';
        break;

      default:
        backgroundColor =
            Colors.orange.shade50;
        foregroundColor =
            Colors.orange.shade800;
        icon = Icons.schedule;
        label = 'Pending';
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: foregroundColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
              FontWeight.bold,
              color:
              foregroundColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESULT MESSAGE
  // ============================================================

  Widget _buildResultMessage({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    color:
                    color.withValues(
                      alpha: 0.9,
                    ),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration:
              BoxDecoration(
                color:
                Colors.indigo
                    .withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .move_to_inbox_outlined,
                size: 48,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No Incoming Transfers',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Tickets transferred to your account '
                  'will appear here.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
      String error,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load transfers',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              error,
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}