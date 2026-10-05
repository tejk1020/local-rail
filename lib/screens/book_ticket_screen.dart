import 'package:flutter/material.dart';

import '../services/booking_service.dart';
import '../services/fare_service.dart';
import '../services/razorpay_service.dart';
import '../services/demo_payment_service.dart';

class BookTicketScreen extends StatefulWidget {
  const BookTicketScreen({super.key});

  @override
  State<BookTicketScreen> createState() => _BookTicketScreenState();
}

class _BookTicketScreenState extends State<BookTicketScreen> {
  final BookingService _bookingService = BookingService();
  final RazorpayService _razorpayService = RazorpayService();
  final DemoPaymentService _demoPaymentService = DemoPaymentService();

  String? _pendingBookingId;

// ============================================================
// BOOKING VARIABLES
// ============================================================

  String? _source;
  String? _destination;
  String? _via;

  String _journeyType = 'one_way';

  DateTime _journeyDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  int _passengerCount = 1;

  bool _isBooking = false;

  final List<TextEditingController> _passengerNameControllers = [
    TextEditingController(),
  ];

// ============================================================
// MUMBAI LOCAL RAILWAY LINES
// ============================================================

  final Map<String, List<String>> _railwayLines = {
// ----------------------------------------------------------
// CENTRAL LINE
// ----------------------------------------------------------

    'Central': [
      'CSMT',
      'Masjid',
      'Sandhurst Road',
      'Byculla',
      'Chinchpokli',
      'Currey Road',
      'Parel',
      'Dadar',
      'Matunga',
      'Sion',
      'Kurla',
      'Vidyavihar',
      'Ghatkopar',
      'Vikhroli',
      'Kanjur Marg',
      'Bhandup',
      'Nahur',
      'Mulund',
      'Thane',
      'Kalwa',
      'Mumbra',
      'Diva Junction',
      'Kopar',
      'Dombivli',
      'Thakurli',
      'Kalyan Junction',
    ],

// ----------------------------------------------------------
// KALYAN - KARJAT
// ----------------------------------------------------------

    'Kalyan-Karjat': [
      'Kalyan Junction',
      'Vithalwadi',
      'Ulhasnagar',
      'Ambernath',
      'Badlapur',
      'Vangani',
      'Shelu',
      'Neral',
      'Bhivpuri Road',
      'Karjat',
    ],

// ----------------------------------------------------------
// KALYAN - KASARA
// ----------------------------------------------------------

    'Kalyan-Kasara': [
      'Kalyan Junction',
      'Shahad',
      'Ambivli',
      'Titwala',
      'Khadavli',
      'Vasind',
      'Asangaon',
      'Atgaon',
      'Thansit',
      'Khardi',
      'Oombermali',
      'Kasara',
    ],

// ----------------------------------------------------------
// KARJAT - KHOPOLI
// ----------------------------------------------------------

    'Karjat-Khopoli': [
      'Karjat',
      'Palasdari',
      'Kelavli',
      'Dolavli',
      'Lowjee',
      'Khopoli',
    ],

// ----------------------------------------------------------
// HARBOUR LINE - CSMT TO PANVEL
// ----------------------------------------------------------

    'Harbour': [
      'CSMT',
      'Masjid',
      'Sandhurst Road',
      'Dockyard Road',
      'Reay Road',
      'Cotton Green',
      'Sewri',
      'Wadala Road',
      'Guru Tegh Bahadur Nagar',
      'Chunabhatti',
      'Kurla',
      'Tilak Nagar',
      'Chembur',
      'Govandi',
      'Mankhurd',
      'Vashi',
      'Sanpada',
      'Juinagar',
      'Nerul',
      'Seawoods Darave',
      'Belapur CBD',
      'Kharghar',
      'Mansarovar',
      'Khandeshwar',
      'Panvel',
    ],

// ----------------------------------------------------------
// HARBOUR WESTERN BRANCH
// ----------------------------------------------------------

    'Harbour-Western': [
      'Wadala Road',
      'King Circle',
      'Mahim Junction',
      'Bandra',
      'Khar Road',
      'Santacruz',
      'Vile Parle',
      'Andheri',
    ],

// ----------------------------------------------------------
// TRANS-HARBOUR
// ----------------------------------------------------------

    'Trans-Harbour': [
      'Thane',
      'Airoli',
      'Rabale',
      'Ghansoli',
      'Koparkhairane',
      'Turbhe',
      'Sanpada',
      'Vashi',
    ],

// ----------------------------------------------------------
// TRANS-HARBOUR PANVEL BRANCH
// ----------------------------------------------------------

    'Trans-Harbour-Panvel': [
      'Turbhe',
      'Juinagar',
      'Nerul',
      'Seawoods Darave',
      'Belapur CBD',
      'Kharghar',
      'Mansarovar',
      'Khandeshwar',
      'Panvel',
    ],

// ----------------------------------------------------------
// URAN LINE
// ----------------------------------------------------------

    'Uran': [
      'Nerul',
      'Seawoods Darave',
      'Belapur CBD',
      'Belapur',
      'Bamandongri',
      'Kharkopar',
      'Gavan',
      'Ranjanpada',
      'Nhava Sheva',
      'Dronagiri',
      'Uran',
    ],

// ----------------------------------------------------------
// WESTERN LINE
// ----------------------------------------------------------

    'Western': [
      'Churchgate',
      'Marine Lines',
      'Charni Road',
      'Grant Road',
      'Mumbai Central',
      'Mahalaxmi',
      'Lower Parel',
      'Prabhadevi',
      'Dadar',
      'Matunga Road',
      'Mahim Junction',
      'Bandra',
      'Khar Road',
      'Santacruz',
      'Vile Parle',
      'Andheri',
      'Jogeshwari',
      'Ram Mandir',
      'Goregaon',
      'Malad',
      'Kandivali',
      'Borivali',
      'Dahisar',
      'Mira Road',
      'Bhayandar',
      'Naigaon',
      'Vasai Road',
      'Nalasopara',
      'Virar',
    ],
  };

// ============================================================
// REALISTIC INTERCHANGE / CHANGE STATIONS
// ============================================================

  final Set<String> _interchangeStations = {
    'CSMT',
    'Dadar',
    'Kurla',
    'Wadala Road',
    'Mahim Junction',
    'Bandra',
    'Andheri',
    'Thane',
    'Vashi',
    'Sanpada',
    'Turbhe',
    'Juinagar',
    'Nerul',
    'Seawoods Darave',
    'Belapur CBD',
    'Kalyan Junction',
    'Diva Junction',
  };

// ============================================================
// INIT
// ============================================================

  @override
  void initState() {
    super.initState();

    _razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
    );
  }

// ============================================================
// DISPOSE
// ============================================================

  @override
  void dispose() {
    for (final controller in _passengerNameControllers) {
      controller.dispose();
    }

    _razorpayService.dispose();

    super.dispose();
  }

// ============================================================
// ALL STATIONS
// ============================================================

  List<String> get _allStations {
    final Set<String> stations = {};

    for (final line in _railwayLines.values) {
      stations.addAll(line);
    }

    final List<String> sortedStations = stations.toList();

    sortedStations.sort();

    return sortedStations;
  }


// ============================================================
// SHOW STATION SEARCH
// ============================================================

  Future<void> _showStationSearch({
    required bool isSource,
  }) async {
    final String? selectedStation = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => StationSearchScreen(
          stations: _allStations,
          title: isSource
              ? 'Select Source Station'
              : 'Select Destination Station',
        ),
      ),
    );

    if (!mounted || selectedStation == null) {
      return;
    }

    setState(() {
      if (isSource) {
        _source = selectedStation;

        if (_destination == selectedStation) {
          _destination = null;
          _via = null;
        }
      } else {
        _destination = selectedStation;

        if (_source == selectedStation) {
          _source = null;
          _via = null;
        }
      }

      _updateViaOptions();
    });
  }

// ============================================================
// BUILD STATION SEARCH FIELD
// ============================================================

  Widget _buildStationSearchField({
    required String title,
    required String? value,
    required IconData icon,
    required bool isSource,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        _showStationSearch(
          isSource: isSource,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.indigo,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? 'Search station',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: value == null
                          ? Colors.grey.shade500
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.search,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

// ============================================================
// FIND ROUTE USING BFS
// ============================================================

  List<String> _findRoute(
      String source,
      String destination,
      ) {
    if (source == destination) {
      return [source];
    }

    final Map<String, Set<String>> graph = {};

// ----------------------------------------------------------
// Build graph from railway lines
// ----------------------------------------------------------

    for (final stations in _railwayLines.values) {
      for (int i = 0; i < stations.length - 1; i++) {
        final String current = stations[i];
        final String next = stations[i + 1];

        graph.putIfAbsent(
          current,
              () => <String>{},
        );

        graph.putIfAbsent(
          next,
              () => <String>{},
        );

        graph[current]!.add(next);
        graph[next]!.add(current);
      }
    }

    if (!graph.containsKey(source) ||
        !graph.containsKey(destination)) {
      return [];
    }

    final List<String> queue = [source];

    final Map<String, String?> previous = {
      source: null,
    };

    while (queue.isNotEmpty) {
      final String current = queue.removeAt(0);

      if (current == destination) {
        break;
      }

      for (final String neighbour
      in graph[current] ?? <String>{}) {
        if (!previous.containsKey(neighbour)) {
          previous[neighbour] = current;
          queue.add(neighbour);
        }
      }
    }

    if (!previous.containsKey(destination)) {
      return [];
    }

    final List<String> route = [];

    String? current = destination;

    while (current != null) {
      route.add(current);
      current = previous[current];
    }

    return route.reversed.toList();
  }

// ============================================================
// GET VIA OPTIONS
// ============================================================

  List<String> get _viaOptions {
    if (_source == null || _destination == null) {
      return [];
    }

    final List<String> route =
    _findRoute(_source!, _destination!);

    if (route.isEmpty) {
      return [];
    }

    return route
        .where(
          (station) =>
      _interchangeStations.contains(station) &&
          station != _source &&
          station != _destination,
    )
        .toList();
  }

// ============================================================
// UPDATE VIA
// ============================================================

  void _updateViaOptions() {
    if (_source == null || _destination == null) {
      _via = null;
      return;
    }

    final List<String> options = _viaOptions;

    if (_via != null && !options.contains(_via)) {
      _via = null;
    }
  }

// ============================================================
// BUILD VIA OPTIONS
// ============================================================

  Widget _buildViaOptions() {
    final List<String> options = _viaOptions;

    if (_source == null || _destination == null) {
      return const SizedBox.shrink();
    }

    if (options.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No major interchange station is required for this route.',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Via / Change Station',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        RadioGroup<String>(
          groupValue: _via,
          onChanged: (value) {
            setState(() {
              _via = value;
            });
          },
          child: Column(
            children: [
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: '',
                title: const Text(
                  'No change / direct route',
                ),
                subtitle: const Text(
                  'Use the direct route',
                ),
              ),
              ...options.map(
                    (station) {
                  return RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: station,
                    title: Text(station),
                    subtitle: const Text(
                      'Major interchange station',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

// ============================================================
// BUILD JOURNEY TYPE
// ============================================================

  Widget _buildJourneyType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Journey Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: RadioGroup<String>(
            groupValue: _journeyType,
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _journeyType = value;
              });
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'one_way',
                  title: const Text('One Way'),
                  subtitle: const Text(
                    'Single journey',
                  ),
                ),
                RadioListTile<String>(
                  value: 'return',
                  title: const Text('Return'),
                  subtitle: const Text(
                    'Same-day return journey',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

// ============================================================
// PASSENGER COUNT
// ============================================================

  void _updatePassengerCount(int count) {
    if (count < 1 || count > 6) {
      return;
    }

    setState(() {
      _passengerCount = count;

      while (_passengerNameControllers.length <
          count) {
        _passengerNameControllers.add(
          TextEditingController(),
        );
      }

      while (_passengerNameControllers.length >
          count) {
        _passengerNameControllers.last.dispose();
        _passengerNameControllers.removeLast();
      }
    });
  }

// ============================================================
// BUILD PASSENGER DETAILS
// ============================================================

  Widget _buildPassengerDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Passenger Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        ...List.generate(
          _passengerCount,
              (index) {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: TextField(
                controller:
                _passengerNameControllers[index],
                textCapitalization:
                TextCapitalization.words,
                decoration: InputDecoration(
                  labelText:
                  'Passenger ${index + 1} Name',
                  hintText: 'Enter passenger name',
                  prefixIcon: const Icon(
                    Icons.person_outline,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

// ============================================================
// GET CURRENT ROUTE
// ============================================================

  List<String> get _currentRoute {
    if (_source == null || _destination == null) {
      return [];
    }

    return _findRoute(
      _source!,
      _destination!,
    );
  }

// ============================================================
// ONE WAY FARE
// ============================================================

  double _calculateOneWayFare(
      List<String> route,
      ) {
    if (route.length < 2) {
      return 0;
    }

    return FareService.calculateOneWayFare(
      route: route,
    );
  }

// ============================================================
// TOTAL FARE
// ============================================================

  double _calculateTotalFare(
      List<String> route,
      ) {
    if (route.length < 2) {
      return 0;
    }

    return FareService.calculateTotalFare(
      route: route,
      passengerCount: _passengerCount,
      journeyType: _journeyType,
    );
  }

// ============================================================
// DISTANCE TEXT
// ============================================================

  String _getDistanceText(
      List<String> route,
      ) {
    if (route.length < 2) {
      return '--';
    }

    return FareService.getDistanceText(
      route: route,
    );
  }

// ============================================================
// SELECT DATE
// ============================================================

  Future<void> _selectJourneyDate() async {
    final DateTime today = DateTime.now();

    setState(() {
      _journeyDate = DateTime(
        today.year,
        today.month,
        today.day,
      );
    });

    _showMessage(
      'Tickets can only be booked for today.',
    );
  }

// ============================================================
// FORMAT DATE
// ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

// ============================================================
// VALIDATE BOOKING
// ============================================================

  bool _validateBooking() {
    if (_source == null) {
      _showMessage(
        'Please select the source station.',
      );
      return false;
    }

    if (_destination == null) {
      _showMessage(
        'Please select the destination station.',
      );
      return false;
    }

    if (_source == _destination) {
      _showMessage(
        'Source and destination cannot be the same.',
      );
      return false;
    }

    final List<String> route = _currentRoute;

    if (route.isEmpty) {
      _showMessage(
        'No route found between these stations.',
      );
      return false;
    }

    for (int i = 0;
    i < _passengerNameControllers.length;
    i++) {
      if (_passengerNameControllers[i]
          .text
          .trim()
          .isEmpty) {
        _showMessage(
          'Please enter the name of Passenger ${i + 1}.',
        );
        return false;
      }
    }

    return true;
  }

// ============================================================
// SHOW MESSAGE
// ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

// ============================================================
// SHOW REVIEW
// ============================================================

  Future<void> _showReview() async {
    if (!_validateBooking()) {
      return;
    }

    final List<String> route = _currentRoute;

    final double totalFare =
    _calculateTotalFare(route);

    final String? selectedVia =
    _via == null || _via!.isEmpty
        ? null
        : _via;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight:
              MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
// ------------------------------------------------
// HEADER
// ------------------------------------------------

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Review Ticket',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const Divider(),

                  const SizedBox(height: 12),

// ------------------------------------------------
// ROUTE
// ------------------------------------------------

                  _buildReviewRow(
                    'From',
                    _source!,
                    Icons.trip_origin,
                  ),

                  _buildReviewRow(
                    'To',
                    _destination!,
                    Icons.location_on,
                  ),

                  _buildReviewRow(
                    'Via',
                    selectedVia ?? 'Direct',
                    Icons.alt_route,
                  ),

                  _buildReviewRow(
                    'Journey',
                    _journeyType == 'one_way'
                        ? 'One Way'
                        : 'Return',
                    Icons.swap_horiz,
                  ),

                  _buildReviewRow(
                    'Journey Date',
                    _formatDate(_journeyDate),
                    Icons.calendar_today,
                  ),

                  _buildReviewRow(
                    'Distance',
                    _getDistanceText(route),
                    Icons.straighten,
                  ),

                  _buildReviewRow(
                    'Passengers',
                    '$_passengerCount',
                    Icons.people,
                  ),

                  const SizedBox(height: 12),

// ------------------------------------------------
// ROUTE
// ------------------------------------------------

                  const Text(
                    'Route',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                    child: Text(
                      route.join(' → '),
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

// ------------------------------------------------
// PASSENGERS
// ------------------------------------------------

                  const Text(
                    'Passengers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ...List.generate(
                    _passengerNameControllers.length,
                        (index) {
                      return ListTile(
                        contentPadding:
                        EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor:
                          Colors.indigo.shade50,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          _passengerNameControllers[index]
                              .text
                              .trim(),
                        ),
                      );
                    },
                  ),

                  const Divider(),

// ------------------------------------------------
// TOTAL FARE
// ------------------------------------------------

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Fare',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${totalFare.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

// ------------------------------------------------
// PAYMENT INFO
// ------------------------------------------------

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius:
                      BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.shade200,
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You will be redirected to Razorpay Test Mode to complete your payment. '
                                'Your ticket becomes valid only after successful payment verification.',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

// ------------------------------------------------
// CONFIRM BUTTON
// ------------------------------------------------

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _isBooking
                          ? null
                          : () async {
                        Navigator.pop(context);
                        await _createBooking();
                      },
                      icon: _isBooking
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(
                        Icons.payment,
                      ),
                      label: Text(
                        _isBooking
                            ? 'Processing Payment...'
                            : 'Pay ₹${totalFare.toStringAsFixed(0)}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// ============================================================
// REVIEW ROW
// ============================================================

  Widget _buildReviewRow(
      String title,
      String value,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.indigo,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

// ============================================================
// CREATE BOOKING
// ============================================================

  Future<void> _createBooking() async {
    if (!_validateBooking()) {
      return;
    }

    final List<String> route = _currentRoute;

    final double totalFare =
    _calculateTotalFare(route);

    final List<String> passengerNames =
    _passengerNameControllers
        .map(
          (controller) => controller.text.trim(),
    )
        .toList();

    setState(() {
      _isBooking = true;
    });

    try {
      final String bookingId =
      await _bookingService.createBooking(
        source: _source!,
        destination: _destination!,
        via: _via == null || _via!.isEmpty
            ? null
            : _via,
        journeyType: _journeyType,
        journeyDate: _journeyDate,
        passengerCount: _passengerCount,
        totalFare: totalFare,
        passengerNames: passengerNames,
      );

      if (!mounted) {
        return;
      }

      _pendingBookingId = bookingId;

      await _razorpayService.startPayment(
        bookingId: bookingId,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isBooking = false;
      });

      _showMessage(
        'Payment could not be started: ${e.toString()}',
      );
    }
  }

// ============================================================
// PAYMENT SUCCESS
// ============================================================

  Future<void> _handlePaymentSuccess(
      String paymentId,
      String orderId,
      String signature,
      ) async {
    final String? bookingId = _pendingBookingId;

    if (bookingId == null) {
      _showMessage(
        'Booking ID is missing for payment verification.',
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isBooking = true;
      });
    }

    final bool isDemoPayment =
        _razorpayService.lastPaymentWasDemo;

    bool verified;

    try {
      if (isDemoPayment) {
        await _demoPaymentService.completeDemoPayment(
          bookingId: bookingId,
          paymentId: paymentId,
        );
        verified = true;
      } else {
        verified = await _razorpayService.verifyPayment(
          bookingId: bookingId,
          paymentId: paymentId,
          orderId: orderId,
          signature: signature,
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isBooking = false;
      });

      _showMessage(
        'Payment processing failed: ${e.toString()}',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isBooking = false;
    });

    if (!verified) {
      _showMessage(
        'Payment received but verification failed.',
      );
      return;
    }

    await _showPaymentSuccessDialog(
      bookingId,
      paymentId,
      isDemoPayment: isDemoPayment,
    );
  }

// ============================================================
// PAYMENT ERROR
// ============================================================

  Future<void> _handlePaymentError(
      String message,
      ) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isBooking = false;
    });

    _showMessage(message);
  }

// ============================================================
// PAYMENT SUCCESS DIALOG
// ============================================================

  Future<void> _showPaymentSuccessDialog(
      String bookingId,
      String paymentId, {
        required bool isDemoPayment,
      }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Text('Payment Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Mumbai Local train ticket has been booked successfully.',
              ),
              const SizedBox(height: 16),
              Text(
                'Booking ID:',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                bookingId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Payment ID:',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                paymentId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isDemoPayment
                      ? 'Demo payment completed. Your ticket is now valid for this college-project demonstration.'
                      : 'Payment verified successfully. Your ticket is now valid.',
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

// ============================================================
// PASSENGER COUNTER
// ============================================================

  Widget _buildPassengerCounter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Passengers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Maximum 6 passengers',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _passengerCount > 1
                ? () {
              _updatePassengerCount(
                _passengerCount - 1,
              );
            }
                : null,
            icon: const Icon(
              Icons.remove_circle_outline,
            ),
          ),

          Text(
            '$_passengerCount',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          IconButton(
            onPressed: _passengerCount < 6
                ? () {
              _updatePassengerCount(
                _passengerCount + 1,
              );
            }
                : null,
            icon: const Icon(
              Icons.add_circle_outline,
            ),
          ),
        ],
      ),
    );
  }

// ============================================================
// DATE CARD
// ============================================================

  Widget _buildDateCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _selectJourneyDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month,
              color: Colors.indigo,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Journey Date',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_journeyDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Today only',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.indigo,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.lock_outline,
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

// ============================================================
// FARE CARD
// ============================================================

  Widget _buildFareCard() {
    final List<String> route = _currentRoute;

    if (route.length < 2) {
      return const SizedBox.shrink();
    }

    final double oneWayFare =
    _calculateOneWayFare(route);

    final double totalFare =
    _calculateTotalFare(route);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade700,
            Colors.indigo.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Text(
                'Fare Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Distance',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              Text(
                _getDistanceText(route),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'One-way fare / passenger',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              Text(
                '₹${oneWayFare.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_passengerCount passenger'
                    '${_passengerCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              Text(
                '₹${totalFare.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// ============================================================
// MAIN UI
// ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book Local Train Ticket',
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
// --------------------------------------------------
// HEADER
// --------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.train,
                      size: 36,
                      color: Colors.indigo,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mumbai Local',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight:
                              FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Book your suburban journey',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

// --------------------------------------------------
// FROM
// --------------------------------------------------

              const Text(
                'Journey',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              _buildStationSearchField(
                title: 'From',
                value: _source,
                icon: Icons.trip_origin,
                isSource: true,
              ),

              const SizedBox(height: 12),

// --------------------------------------------------
// TO
// --------------------------------------------------

              _buildStationSearchField(
                title: 'To',
                value: _destination,
                icon: Icons.location_on,
                isSource: false,
              ),

              const SizedBox(height: 16),

// --------------------------------------------------
// VIA
// --------------------------------------------------

              _buildViaOptions(),

              if (_source != null &&
                  _destination != null)
                const SizedBox(height: 16),

// --------------------------------------------------
// JOURNEY TYPE
// --------------------------------------------------

              _buildJourneyType(),

              const SizedBox(height: 16),

// --------------------------------------------------
// DATE
// --------------------------------------------------

              _buildDateCard(),

              const SizedBox(height: 16),

// --------------------------------------------------
// PASSENGER COUNT
// --------------------------------------------------

              _buildPassengerCounter(),

              const SizedBox(height: 16),

// --------------------------------------------------
// PASSENGER DETAILS
// --------------------------------------------------

              _buildPassengerDetails(),

              const SizedBox(height: 16),

// --------------------------------------------------
// FARE
// --------------------------------------------------

              _buildFareCard(),

              const SizedBox(height: 24),

// --------------------------------------------------
// REVIEW BUTTON
// --------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isBooking
                      ? null
                      : _showReview,
                  icon: const Icon(
                    Icons.receipt_long,
                  ),
                  label: const Text(
                    'Review & Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STATION SEARCH SCREEN
// ============================================================

class StationSearchScreen extends StatefulWidget {
  final List<String> stations;
  final String title;

  const StationSearchScreen({
    super.key,
    required this.stations,
    required this.title,
  });

  @override
  State<StationSearchScreen> createState() => _StationSearchScreenState();
}

class _StationSearchScreenState extends State<StationSearchScreen> {
  late final TextEditingController _searchController;
  List<String> _results = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchStations(String query) {
    final String searchText = query.trim().toLowerCase();

    setState(() {
      if (searchText.isEmpty) {
        _results = [];
        return;
      }

      _results = widget.stations
          .where(
            (station) =>
            station.toLowerCase().contains(searchText),
      )
          .take(20)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                autofocus: false,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search station...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _searchStations('');
                    },
                    icon: const Icon(Icons.clear),
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: _searchStations,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _results.isEmpty
                    ? Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? 'Start typing to search stations'
                        : 'No station found',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                    ),
                  ),
                )
                    : ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final String station = _results[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade50,
                        child: const Icon(
                          Icons.train,
                          color: Colors.indigo,
                        ),
                      ),
                      title: Text(
                        station,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () {
                        Navigator.of(context).pop(station);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}