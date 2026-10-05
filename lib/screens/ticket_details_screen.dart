import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/ticket_model.dart';
import 'ticket_transfer_screen.dart';

class TicketDetailsScreen extends StatelessWidget {
  final TicketModel ticket;

  const TicketDetailsScreen({
    super.key,
    required this.ticket,
  });

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not available';
    }

    final String day =
    date.day.toString().padLeft(2, '0');

    final String month =
    date.month.toString().padLeft(2, '0');

    final String year =
    date.year.toString();

    return '$day/$month/$year';
  }

  // ============================================================
  // JOURNEY TYPE
  // ============================================================

  String _journeyTypeText() {
    switch (ticket.journeyType) {
      case 'return':
        return 'Return Journey';

      case 'one_way':
      default:
        return 'One Way';
    }
  }

  // ============================================================
  // VALIDITY
  // ============================================================

  bool get _isValid {
    if (ticket.status.toLowerCase() != 'valid') {
      return false;
    }

    final DateTime? journeyDate =
        ticket.journeyDate;

    if (journeyDate == null) {
      return false;
    }

    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final DateTime ticketDate = DateTime(
      journeyDate.year,
      journeyDate.month,
      journeyDate.day,
    );

    return ticketDate == today;
  }

  // ============================================================
  // QR DATA
  // ============================================================

  String get _qrData {
    // QR contains only the secure ticket token.
    // It does NOT contain complete ticket information.
    return ticket.qrToken;
  }

  // ============================================================
  // OPEN TRANSFER SCREEN
  // ============================================================

  void _openTransferScreen(BuildContext context) {
    if (!_isValid) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketTransferScreen(
          ticket: ticket,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool valid = _isValid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Ticket',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ==================================================
              // STATUS
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: valid
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius:
                  BorderRadius.circular(14),
                  border: Border.all(
                    color: valid
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      valid
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: valid
                          ? Colors.green
                          : Colors.red,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            valid
                                ? 'VALID TICKET'
                                : 'INVALID TICKET',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.bold,
                              color: valid
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            valid
                                ? 'Valid for travel today'
                                : 'Not valid for travel today',
                            style: TextStyle(
                              fontSize: 12,
                              color: valid
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // MAIN TICKET CARD
              // ==================================================

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // --------------------------------------------
                    // HEADER
                    // --------------------------------------------

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      color: Colors.indigo,
                      child: const Row(
                        children: [
                          Icon(
                            Icons.train,
                            color: Colors.white,
                            size: 32,
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mumbai Local',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 3),

                                Text(
                                  'Suburban Railway Ticket',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --------------------------------------------
                    // JOURNEY
                    // --------------------------------------------

                    Padding(
                      padding:
                      const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _stationWidget(
                                  label: 'FROM',
                                  station:
                                  ticket.source,
                                  alignment:
                                  CrossAxisAlignment.start,
                                ),
                              ),

                              Padding(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  horizontal: 12,
                                ),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration:
                                  BoxDecoration(
                                    color: Colors
                                        .indigo.shade50,
                                    shape:
                                    BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color:
                                    Colors.indigo,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: _stationWidget(
                                  label: 'TO',
                                  station:
                                  ticket.destination,
                                  alignment:
                                  CrossAxisAlignment.end,
                                ),
                              ),
                            ],
                          ),

                          if (ticket.via != null &&
                              ticket.via!
                                  .trim()
                                  .isNotEmpty) ...[
                            const SizedBox(height: 12),

                            Text(
                              'Via ${ticket.via}',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                Colors.grey.shade600,
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          const Divider(),

                          const SizedBox(height: 14),

                          // --------------------------------------
                          // DETAILS
                          // --------------------------------------

                          _detailRow(
                            Icons.person_outline,
                            'Passenger',
                            ticket.passengerName,
                          ),

                          const SizedBox(height: 14),

                          _detailRow(
                            Icons.calendar_today_outlined,
                            'Journey Date',
                            _formatDate(
                              ticket.journeyDate,
                            ),
                          ),

                          const SizedBox(height: 14),

                          _detailRow(
                            Icons.confirmation_number_outlined,
                            'Journey Type',
                            _journeyTypeText(),
                          ),

                          const SizedBox(height: 14),

                          _detailRow(
                            Icons.currency_rupee,
                            'Fare',
                            '₹${ticket.fare.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),

                    // --------------------------------------------
                    // QR SECTION
                    // --------------------------------------------

                    Container(
                      width: double.infinity,
                      padding:
                      const EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                          top: BorderSide(
                            color:
                            Colors.grey.shade200,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.qr_code_2,
                            size: 28,
                            color: Colors.indigo,
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Ticket Verification QR',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            valid
                                ? 'Show this QR code to the ticket checker'
                                : 'This ticket is currently invalid',
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                              color:
                              Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // --------------------------------------
                          // QR CODE
                          // --------------------------------------

                          Container(
                            width: 230,
                            height: 230,
                            padding:
                            const EdgeInsets.all(14),
                            decoration:
                            BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(
                                16,
                              ),
                              border: Border.all(
                                color:
                                Colors.grey.shade300,
                              ),
                            ),
                            child: _qrData.isEmpty
                                ? const Center(
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                                children: [
                                  Icon(
                                    Icons
                                        .error_outline,
                                    color: Colors.red,
                                    size: 40,
                                  ),

                                  SizedBox(
                                    height: 8,
                                  ),

                                  Text(
                                    'QR unavailable',
                                    style:
                                    TextStyle(
                                      color:
                                      Colors.red,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : QrImageView(
                              data: _qrData,
                              version:
                              QrVersions.auto,
                              size: 200,
                              gapless: true,
                              errorCorrectionLevel:
                              QrErrorCorrectLevel
                                  .M,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // --------------------------------------
                          // SECURITY NOTE
                          // --------------------------------------

                          Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.all(12),
                            decoration:
                            BoxDecoration(
                              color:
                              Colors.indigo.shade50,
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),
                            child: const Row(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Icon(
                                  Icons
                                      .security_outlined,
                                  size: 20,
                                  color:
                                  Colors.indigo,
                                ),

                                SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    'This QR contains a secure '
                                        'ticket token. Do not share '
                                        'screenshots of your ticket '
                                        'with unknown persons.',
                                    style: TextStyle(
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // TICKET IDENTIFIERS
              // ==================================================

              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _identifierRow(
                        'Ticket ID',
                        ticket.ticketId,
                      ),

                      const SizedBox(height: 12),

                      _identifierRow(
                        'Booking ID',
                        ticket.bookingId,
                      ),
                    ],
                  ),
                ),
              ),

              // ==================================================
              // TRANSFER BUTTON
              // ==================================================
              //
              // IMPORTANT:
              // This entire section is shown ONLY when
              // the ticket is valid for TODAY.
              //
              // Tomorrow, valid becomes false and this
              // button will completely disappear.
              // ==================================================

              if (valid) ...[
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () {
                      _openTransferScreen(context);
                    },
                    icon: const Icon(
                      Icons.swap_horiz,
                    ),
                    label: const Text(
                      'Transfer This Ticket',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ==================================================
              // INFORMATION
              // ==================================================

              Text(
                valid
                    ? 'Keep this ticket available during your journey.'
                    : 'This ticket has expired and cannot be transferred.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: valid
                      ? Colors.grey.shade600
                      : Colors.red.shade600,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STATION WIDGET
  // ============================================================

  Widget _stationWidget({
    required String label,
    required String station,
    required CrossAxisAlignment alignment,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          station,
          textAlign:
          alignment == CrossAxisAlignment.end
              ? TextAlign.end
              : TextAlign.start,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius:
            BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.indigo,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
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
  // IDENTIFIER ROW
  // ============================================================

  Widget _identifierRow(
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 3),

              SelectableText(
                value.isEmpty
                    ? 'Not available'
                    : value,
                style: const TextStyle(
                  fontSize: 12,
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
}