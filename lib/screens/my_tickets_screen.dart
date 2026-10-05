import 'package:flutter/material.dart';

import '../models/ticket_model.dart';
import '../services/booking_service.dart';
import 'ticket_details_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final BookingService _bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tickets',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<TicketModel>>(
        stream: _bookingService.getMyTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(
              snapshot.error.toString(),
            );
          }

          final tickets =
              snapshot.data ?? <TicketModel>[];

          if (tickets.isEmpty) {
            return _buildEmptyState();
          }

          final groups =
          _groupTicketsByBooking(tickets);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return _buildBookingCard(
                  groups[index],
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // GROUP TICKETS FROM THE SAME BOOKING
  // ============================================================

  List<List<TicketModel>> _groupTicketsByBooking(
      List<TicketModel> tickets,
      ) {
    final Map<String, List<TicketModel>> grouped =
    <String, List<TicketModel>>{};

    for (final ticket in tickets) {
      final String key = ticket.bookingId.isEmpty
          ? ticket.ticketId
          : ticket.bookingId;

      grouped.putIfAbsent(
        key,
            () => <TicketModel>[],
      );

      grouped[key]!.add(ticket);
    }

    final List<List<TicketModel>> groups =
    grouped.values.toList();

    // ----------------------------------------------------------
    // SORT INDIVIDUAL TICKETS
    // ----------------------------------------------------------
    //
    // Newest ticket first inside each booking.
    //
    // This also makes Ticket 1 / Ticket 2 ordering consistent.
    // ----------------------------------------------------------

    for (final group in groups) {
      group.sort((a, b) {
        final DateTime aDate =
            a.createdAt ?? DateTime(2000);

        final DateTime bDate =
            b.createdAt ?? DateTime(2000);

        return bDate.compareTo(aDate);
      });
    }

    // ----------------------------------------------------------
    // SORT BOOKINGS
    // ----------------------------------------------------------
    //
    // The booking whose newest ticket was created most recently
    // appears first.
    //
    // IMPORTANT:
    // We use createdAt here instead of journeyDate because all
    // tickets can have the same journey date (Today).
    // ----------------------------------------------------------

    groups.sort((a, b) {
      final DateTime aDate =
          a.first.createdAt ?? DateTime(2000);

      final DateTime bDate =
          b.first.createdAt ?? DateTime(2000);

      return bDate.compareTo(aDate);
    });

    return groups;
  }

  // ============================================================
  // BOOKING CARD
  // ============================================================

  Widget _buildBookingCard(
      List<TicketModel> tickets,
      ) {
    final TicketModel firstTicket =
        tickets.first;

    final bool isValidToday = tickets.every(
      _isValidForToday,
    );

    final double totalFare =
    tickets.fold<double>(
      0,
          (sum, ticket) => sum + ticket.fare,
    );

    final int passengerCount =
        tickets.length;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            _showTicketsForBooking(tickets),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                    padding:
                    const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isValidToday
                          ? Colors.green.withValues(
                        alpha: 0.10,
                      )
                          : Colors.red.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons
                          .confirmation_number_outlined,
                      color: isValidToday
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'Mumbai Local Ticket',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),

                  _statusBadge(
                    isValidToday,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // ROUTE
              // ------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: _station(
                      'From',
                      firstTicket.source,
                    ),
                  ),

                  const Padding(
                    padding:
                    EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.indigo,
                    ),
                  ),

                  Expanded(
                    child: _station(
                      'To',
                      firstTicket.destination,
                      right: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Divider(),

              const SizedBox(height: 10),

              // ------------------------------------------------
              // PASSENGERS + TOTAL FARE
              // ------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: _info(
                      Icons.people_outline,
                      'Passengers',
                      '$passengerCount',
                    ),
                  ),

                  Expanded(
                    child: _info(
                      Icons.currency_rupee,
                      'Total Fare',
                      '₹${totalFare.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------
              // JOURNEY + TRAIN
              // ------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: _info(
                      Icons
                          .calendar_today_outlined,
                      'Journey',
                      _formatDate(
                        firstTicket.journeyDate,
                      ),
                    ),
                  ),

                  Expanded(
                    child: _info(
                      Icons.train_outlined,
                      'Train',
                      firstTicket
                          .trainNumber
                          .isEmpty
                          ? firstTicket.trainName
                          : firstTicket.trainNumber,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // TRAVEL STATUS
              // ------------------------------------------------

              _travelStatusRow(
                isValidToday,
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // VIEW INDIVIDUAL TICKETS
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo
                      .withValues(alpha: 0.08),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.qr_code_2,
                      color: Colors.indigo,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        passengerCount == 1
                            ? 'View Ticket & QR'
                            : 'View $passengerCount Tickets & QR',
                        style: TextStyle(
                          color:
                          Colors.indigo.shade700,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right,
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SHOW INDIVIDUAL TICKETS
  // ============================================================

  void _showTicketsForBooking(
      List<TicketModel> tickets,
      ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              20,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.grey.shade400,
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Your Tickets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${tickets.length} individual ticket'
                      '${tickets.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color:
                    Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 16),

                ...List.generate(
                  tickets.length,
                      (index) {
                    final TicketModel ticket =
                    tickets[index];

                    return Card(
                      margin:
                      const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                          Colors.indigo
                              .withValues(
                            alpha: 0.10,
                          ),
                          child: Text(
                            '${index + 1}',
                            style:
                            const TextStyle(
                              color:
                              Colors.indigo,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),

                        title: Text(
                          'Ticket ${index + 1}',
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        subtitle: Text(
                          '${ticket.source} → '
                              '${ticket.destination}\n'
                              '₹${ticket.fare.toStringAsFixed(2)}',
                        ),

                        trailing:
                        const Icon(
                          Icons.qr_code_2,
                          color:
                          Colors.indigo,
                        ),

                        onTap: () {
                          Navigator.pop(
                            sheetContext,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TicketDetailsScreen(
                                    ticket: ticket,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // VALIDITY
  // ============================================================

  bool _isValidForToday(
      TicketModel ticket,
      ) {
    if (ticket.status.toLowerCase() !=
        'valid') {
      return false;
    }

    final DateTime? journeyDate =
        ticket.journeyDate;

    if (journeyDate == null) {
      return true;
    }

    final DateTime now = DateTime.now();

    return journeyDate.year == now.year &&
        journeyDate.month == now.month &&
        journeyDate.day == now.day;
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(
      bool isValid,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isValid
            ? Colors.green.withValues(
          alpha: 0.10,
        )
            : Colors.red.withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        isValid ? 'VALID' : 'INVALID',
        style: TextStyle(
          fontSize: 11,
          fontWeight:
          FontWeight.bold,
          color: isValid
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
      ),
    );
  }

  // ============================================================
  // TRAVEL STATUS
  // ============================================================

  Widget _travelStatusRow(
      bool isValid,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid
            ? Colors.green.withValues(
          alpha: 0.08,
        )
            : Colors.red.withValues(
          alpha: 0.08,
        ),
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: isValid
              ? Colors.green.withValues(
            alpha: 0.25,
          )
              : Colors.red.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid
                ? Icons.check_circle
                : Icons.cancel,
            size: 22,
            color: isValid
                ? Colors.green
                : Colors.red,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              isValid
                  ? 'Valid for travel today'
                  : 'Not valid for travel today',
              style: TextStyle(
                fontWeight:
                FontWeight.w600,
                color: isValid
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATION
  // ============================================================

  Widget _station(
      String title,
      String station, {
        bool right = false,
      }) {
    return Column(
      crossAxisAlignment: right
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          station,
          maxLines: 2,
          overflow:
          TextOverflow.ellipsis,
          textAlign: right
              ? TextAlign.end
              : TextAlign.start,
          style: const TextStyle(
            fontSize: 15,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFORMATION FIELD
  // ============================================================

  Widget _info(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.indigo,
        ),

        const SizedBox(width: 7),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color:
                  Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
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
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons
                  .confirmation_number_outlined,
              size: 80,
              color:
              Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            const Text(
              'No Tickets Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Your purchased Mumbai Local tickets '
                  'will appear here after successful payment.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
                fontSize: 14,
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
              'Unable to load tickets',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              textAlign:
              TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () =>
                  setState(() {}),
              icon: const Icon(
                Icons.refresh,
              ),
              label:
              const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(
      DateTime? date,
      ) {
    if (date == null) {
      return 'Today';
    }

    final String day =
    date.day
        .toString()
        .padLeft(2, '0');

    final String month =
    date.month
        .toString()
        .padLeft(2, '0');

    final String year =
    date.year.toString();

    return '$day/$month/$year';
  }
}