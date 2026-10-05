import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/ticket_transfer_service.dart';

class OutgoingTransfersScreen extends StatefulWidget {
  const OutgoingTransfersScreen({
    super.key,
  });

  @override
  State<OutgoingTransfersScreen> createState() =>
      _OutgoingTransfersScreenState();
}

class _OutgoingTransfersScreenState
    extends State<OutgoingTransfersScreen> {
  final TicketTransferService _transferService =
  TicketTransferService();

  Timer? _timer;

  String? _processingTransferId;

  @override
  void initState() {
    super.initState();

    // Refresh the countdown every second.
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Not available';
    }

    final DateTime date =
    timestamp.toDate();

    final String day =
    date.day.toString().padLeft(2, '0');

    final String month =
    date.month.toString().padLeft(2, '0');

    final String year =
    date.year.toString();

    return '$day/$month/$year';
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Not available';
    }

    final DateTime date =
    timestamp.toDate();

    final int hour =
    date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final String minute =
    date.minute.toString().padLeft(2, '0');

    final String period =
    date.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // FORMAT REMAINING TIME
  // ============================================================

  String _formatRemainingTime(
      Duration duration,
      ) {
    final int minutes =
        duration.inMinutes;

    final int seconds =
        duration.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // STATUS TEXT
  // ============================================================

  String _statusText(
      String status,
      ) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';

      case 'accepted':
        return 'Accepted';

      case 'rejected':
        return 'Rejected';

      case 'reverted':
        return 'Reverted';

      case 'cancelled':
        return 'Cancelled';

      case 'expired':
        return 'Expired';

      case 'revert_expired':
        return 'Revert Window Expired';

      default:
        return status;
    }
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(
      String status,
      ) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;

      case 'accepted':
        return Colors.green;

      case 'reverted':
        return Colors.blue;

      case 'rejected':
      case 'cancelled':
      case 'expired':
      case 'revert_expired':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // REVERT TRANSFER
  // ============================================================

  Future<void> _revertTransfer(
      Map<String, dynamic> transfer,
      ) async {
    final String transferId =
    (transfer['documentId'] ?? '')
        .toString();

    if (transferId.isEmpty) {
      return;
    }

    // ----------------------------------------------------------
    // CONFIRMATION DIALOG
    // ----------------------------------------------------------

    final bool? confirmed =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Revert Transfer?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'This will return the ticket to you '
                'and invalidate the recipient\'s ownership. '
                'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Keep Transfer',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Revert Transfer',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    // ----------------------------------------------------------
    // PROCESS
    // ----------------------------------------------------------

    setState(() {
      _processingTransferId =
          transferId;
    });

    try {
      await _transferService
          .revertTransfer(
        transferId: transferId,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Ticket transfer reverted successfully.',
          ),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      String message =
      e.toString();

      if (message.startsWith(
        'Exception: ',
      )) {
        message =
            message.substring(
              'Exception: '.length,
            );
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
          SnackBarBehavior.floating,
          backgroundColor:
          Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingTransferId =
          null;
        });
      }
    }
  }

  // ============================================================
  // BUILD TRANSFER CARD
  // ============================================================

  Widget _buildTransferCard(
      Map<String, dynamic> transfer,
      ) {
    final String transferId =
    (transfer['documentId'] ?? '')
        .toString();

    final String status =
    (transfer['status'] ?? '')
        .toString()
        .toLowerCase();

    final String recipientName =
    (transfer['toName'] ??
        'Passenger')
        .toString();

    final String recipientEmail =
    (transfer['toEmail'] ?? '')
        .toString();

    final String recipientPhone =
    (transfer['toPhone'] ?? '')
        .toString();

    final String ticketId =
    (transfer['ticketId'] ?? '')
        .toString();

    final String bookingId =
    (transfer['bookingId'] ?? '')
        .toString();

    final Timestamp? createdAt =
    transfer['createdAt']
    as Timestamp?;

    final Timestamp? acceptedAt =
    transfer['acceptedAt']
    as Timestamp?;

    final Color statusColor =
    _statusColor(status);

    final bool canRevert =
    _transferService
        .canRevertTransfer(
      transfer,
    );

    final Duration remaining =
    canRevert
        ? _transferService
        .getRemainingRevertTime(
      transfer,
    )
        : Duration.zero;

    final bool processing =
        _processingTransferId ==
            transferId;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration:
                  BoxDecoration(
                    color: Colors
                        .indigo.shade50,
                    borderRadius:
                    BorderRadius
                        .circular(12),
                  ),
                  child: const Icon(
                    Icons
                        .swap_horiz_rounded,
                    color:
                    Colors.indigo,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                const Expanded(
                  child: Text(
                    'Ticket Transfer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration:
                  BoxDecoration(
                    color: statusColor
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(20),
                  ),
                  child: Text(
                    _statusText(status),
                    style: TextStyle(
                      color:
                      statusColor,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            // ==================================================
            // RECIPIENT
            // ==================================================

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(
                12,
              ),
              decoration:
              BoxDecoration(
                color:
                Colors.grey.shade50,
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRANSFERRED TO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                      FontWeight.bold,
                      color: Colors
                          .grey.shade600,
                      letterSpacing:
                      1,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    recipientName,
                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  if (recipientEmail
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      recipientEmail,
                      style:
                      TextStyle(
                        fontSize: 12,
                        color: Colors
                            .grey.shade600,
                      ),
                    ),
                  ],

                  if (recipientPhone
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      recipientPhone,
                      style:
                      TextStyle(
                        fontSize: 12,
                        color: Colors
                            .grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // TICKET INFORMATION
            // ==================================================

            _infoRow(
              Icons.confirmation_number_outlined,
              'Ticket ID',
              ticketId,
            ),

            const SizedBox(
              height: 10,
            ),

            _infoRow(
              Icons.book_outlined,
              'Booking ID',
              bookingId,
            ),

            if (createdAt != null) ...[
              const SizedBox(
                height: 10,
              ),
              _infoRow(
                Icons.calendar_today_outlined,
                'Transferred',
                '${_formatDate(createdAt)} '
                    'at ${_formatTime(createdAt)}',
              ),
            ],

            if (status == 'accepted' &&
                acceptedAt != null) ...[
              const SizedBox(
                height: 10,
              ),
              _infoRow(
                Icons.check_circle_outline,
                'Accepted',
                '${_formatDate(acceptedAt)} '
                    'at ${_formatTime(acceptedAt)}',
              ),
            ],

            // ==================================================
            // REVERT WINDOW
            // ==================================================

            if (canRevert) ...[
              const SizedBox(
                height: 16,
              ),

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(
                  14,
                ),
                decoration:
                BoxDecoration(
                  color:
                  Colors.orange.shade50,
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                  border: Border.all(
                    color:
                    Colors.orange.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons
                              .timer_outlined,
                          color:
                          Colors.orange
                              .shade800,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        const Expanded(
                          child: Text(
                            'Revert window active',
                            style:
                            TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),

                        Text(
                          _formatRemainingTime(
                            remaining,
                          ),
                          style:
                          TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            color: Colors
                                .orange
                                .shade900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      'You can return this ticket to yourself '
                          'within the remaining time.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors
                            .orange.shade900,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    SizedBox(
                      width:
                      double.infinity,
                      height: 46,
                      child:
                      OutlinedButton.icon(
                        onPressed:
                        processing
                            ? null
                            : () {
                          _revertTransfer(
                            transfer,
                          );
                        },
                        icon: processing
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2,
                          ),
                        )
                            : const Icon(
                          Icons
                              .undo_rounded,
                        ),
                        label: Text(
                          processing
                              ? 'Reverting...'
                              : 'Revert Transfer',
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ==================================================
            // REVERT EXPIRED
            // ==================================================

            if (status ==
                'accepted' &&
                !canRevert) ...[
              const SizedBox(
                height: 14,
              ),

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(
                  12,
                ),
                decoration:
                BoxDecoration(
                  color:
                  Colors.grey.shade100,
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons
                          .timer_off_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        'The 10-minute revert window has expired.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: Colors.indigo,
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color:
                  Colors.grey.shade600,
                ),
              ),

              const SizedBox(
                height: 2,
              ),

              Text(
                value.isEmpty
                    ? 'Not available'
                    : value,
                style:
                const TextStyle(
                  fontSize: 13,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(32),
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
                Colors.indigo.shade50,
                shape:
                BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .swap_horiz_rounded,
                size: 46,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'No Transfers Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Tickets that you transfer to '
                  'other registered passengers '
                  'will appear here.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 13,
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
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Outgoing Transfers',
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<
          List<Map<String, dynamic>>>(
        stream:
        _transferService
            .getOutgoingTransfers(),
        builder:
            (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  24,
                ),
                child: Text(
                  'Unable to load transfers.\n\n'
                      '${snapshot.error}',
                  textAlign:
                  TextAlign.center,
                ),
              ),
            );
          }

          final List<
              Map<String, dynamic>>
          transfers =
              snapshot.data ?? [];

          if (transfers.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Firestore stream automatically
              // refreshes the screen.
              await Future<void>.delayed(
                const Duration(
                  milliseconds: 300,
                ),
              );
            },
            child: ListView(
              padding:
              const EdgeInsets.all(16),
              children: [
                // ==================================================
                // INFO
                // ==================================================

                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(
                    14,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.indigo.shade50,
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons
                            .info_outline,
                        color:
                        Colors.indigo,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          'After a transfer is accepted, '
                              'you have 10 minutes to revert it. '
                              'The ticket will return to your account.',
                          style:
                          TextStyle(
                            fontSize: 12,
                            color:
                            Colors.indigo,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                // ==================================================
                // TRANSFERS
                // ==================================================

                ...transfers.map(
                  _buildTransferCard,
                ),

                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}