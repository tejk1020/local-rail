import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LiveStation {
  final String code;
  final String name;
  final String? city;

  const LiveStation({
    required this.code,
    required this.name,
    this.city,
  });

  factory LiveStation.fromMap(
      Map<String, dynamic> map,
      ) {
    return LiveStation(
      code: _stringValue(map['code']),
      name: _stringValue(map['name']),
      city: _nullableString(map['city']),
    );
  }
}

class LiveDestination {
  final String code;
  final String name;

  const LiveDestination({
    required this.code,
    required this.name,
  });

  factory LiveDestination.fromMap(
      Map<String, dynamic> map,
      ) {
    return LiveDestination(
      code: _stringValue(map['code']),
      name: _stringValue(map['name']),
    );
  }
}

class LiveTrainSummary {
  final String number;
  final String name;
  final String destinationCode;
  final String destinationName;
  final String departure;
  final String liveType;
  final int delayMinutes;

  const LiveTrainSummary({
    required this.number,
    required this.name,
    required this.destinationCode,
    required this.destinationName,
    required this.departure,
    required this.liveType,
    required this.delayMinutes,
  });

  factory LiveTrainSummary.fromMap(
      Map<String, dynamic> map,
      ) {
    final train = _mapValue(map['train']);
    final stop = _mapValue(map['stop']);
    final live = _mapValue(map['live']);

    final destination =
    _destinationValue(
      train['destination'],
    );

    return LiveTrainSummary(
      number: _stringValue(
        train['number'] ??
            train['trainNumber'],
      ),
      name: _stringValue(
        train['name'],
        fallback: 'Mumbai Local',
      ),
      destinationCode:
      destination.code,
      destinationName:
      destination.name,
      departure:
      _stringValue(
        stop['departure'],
      ),
      liveType:
      _stringValue(
        live['type'],
      ).toLowerCase(),
      delayMinutes:
      _intValue(
        live['delayMinutes'],
      ),
    );
  }
}

class LiveRouteStop {
  final String code;
  final String name;
  final String? scheduledArrival;
  final String? scheduledDeparture;
  final String status;
  final int sequence;

  const LiveRouteStop({
    required this.code,
    required this.name,
    required this.scheduledArrival,
    required this.scheduledDeparture,
    required this.status,
    required this.sequence,
  });

  factory LiveRouteStop.fromMap(
      Map<String, dynamic> map,
      ) {
    return LiveRouteStop(
      code: _stringValue(
        map['stationCode'],
      ),
      name: _stringValue(
        map['stationName'],
        fallback:
        _stringValue(
          map['stationCode'],
        ),
      ),
      scheduledArrival:
      _nullableString(
        map['scheduledArrival'],
      ),
      scheduledDeparture:
      _nullableString(
        map['scheduledDeparture'],
      ),
      status: _stringValue(
        map['status'],
      ).toLowerCase(),
      sequence:
      _intValue(
        map['sequence'],
      ),
    );
  }

  String get displayTime {
    final value =
        scheduledArrival ??
            scheduledDeparture;

    if (value == null ||
        value.isEmpty) {
      return '--';
    }

    return _formatIsoOrTime(
      value,
    );
  }
}

class LiveTrainDetail {
  final String number;
  final String name;
  final String sourceName;
  final String destinationName;
  final String status;
  final int delayMinutes;
  final double? speedKmh;
  final double? currentLat;
  final double? currentLng;
  final String? lastUpdatedAt;
  final String? currentStationCode;
  final String? currentStationName;
  final String? nextStationCode;
  final String? nextStationName;
  final List<LiveRouteStop> route;
  final List<LatLng> geometryPoints;

  const LiveTrainDetail({
    required this.number,
    required this.name,
    required this.sourceName,
    required this.destinationName,
    required this.status,
    required this.delayMinutes,
    required this.speedKmh,
    required this.currentLat,
    required this.currentLng,
    required this.lastUpdatedAt,
    required this.currentStationCode,
    required this.currentStationName,
    required this.nextStationCode,
    required this.nextStationName,
    required this.route,
    required this.geometryPoints,
  });

  factory LiveTrainDetail.fromMap(
      Map<String, dynamic> data,
      ) {
    final train =
    _mapValue(
      data['train'],
    );

    final current =
    _mapValue(
      data['currentLocation'],
    );

    final next =
    _mapValue(
      data['nextHalt'],
    );

    final source =
    _stationValue(
      train['source'],
    );

    final destination =
    _stationValue(
      train['destination'],
    );

    final route =
    <LiveRouteStop>[];

    final rawRoute =
    data['route'];

    if (rawRoute is List) {
      for (
      final item in rawRoute
      ) {
        if (item is Map) {
          route.add(
            LiveRouteStop.fromMap(
              Map<String, dynamic>.from(
                item,
              ),
            ),
          );
        }
      }
    }

    final geometryPoints =
    <LatLng>[];

    final geometry =
    _mapValue(
      data['geometry'],
    );

    final coordinates =
    geometry['coordinates'];

    if (coordinates is List) {
      for (
      final item
      in coordinates
      ) {
        if (
        item is List &&
            item.length >= 2) {
          final lat =
          _doubleValue(
            item[0],
          );

          final lng =
          _doubleValue(
            item[1],
          );

          if (
          lat != null &&
              lng != null) {
            geometryPoints.add(
              LatLng(
                lat,
                lng,
              ),
            );
          }
        }
      }
    }

    return LiveTrainDetail(
      number: _stringValue(
        data['trainNumber'] ??
            train['number'],
      ),
      name: _stringValue(
        data['trainName'] ??
            train['name'],
        fallback:
        'Mumbai Local',
      ),
      sourceName:
      source.name,
      destinationName:
      destination.name,
      status: _stringValue(
        data['status'],
        fallback: 'scheduled',
      ),
      delayMinutes:
      _intValue(
        data['delayMinutes'],
      ),
      speedKmh:
      _doubleValue(
        current['speedKmh'],
      ),
      currentLat:
      _doubleValue(
        current['lat'],
      ),
      currentLng:
      _doubleValue(
        current['lng'],
      ),
      lastUpdatedAt:
      _nullableString(
        data['lastUpdatedAt'],
      ),
      currentStationCode:
      _nullableString(
        current['stationCode'],
      ),
      currentStationName:
      _nullableString(
        current['stationName'],
      ),
      nextStationCode:
      _nullableString(
        next['stationCode'],
      ),
      nextStationName:
      _nullableString(
        next['stationName'],
      ),
      route: route,
      geometryPoints:
      geometryPoints,
    );
  }
}

class _DestinationValue {
  final String code;
  final String name;

  const _DestinationValue({
    required this.code,
    required this.name,
  });
}

class _StationValue {
  final String code;
  final String name;

  const _StationValue({
    required this.code,
    required this.name,
  });
}

class _CachedStationSearch {
  final DateTime fetchedAt;
  final List<LiveStation> stations;

  const _CachedStationSearch({
    required this.fetchedAt,
    required this.stations,
  });
}

class LiveTrainsScreen
    extends StatefulWidget {
  const LiveTrainsScreen({
    super.key,
  });

  @override
  State<LiveTrainsScreen>
  createState() =>
      _LiveTrainsScreenState();
}

class _LiveTrainsScreenState
    extends State<LiveTrainsScreen>
    with
        SingleTickerProviderStateMixin {
  static const String
  _backendBaseUrl =
      'https://smart-local-train-backend.onrender.com';

  final TextEditingController
  _searchController =
  TextEditingController();

  Timer? _searchDebounce;
  Timer? _refreshTimer;

  final Map<
      String,
      _CachedStationSearch>
  _stationSearchCache = {};

  late AnimationController
  _blinkController;

  late Animation<double>
  _blinkAnimation;

  List<LiveStation>
  _stations = [];

  List<LiveDestination>
  _destinations = [];

  List<LiveTrainSummary>
  _trains = [];

  LiveStation?
  _selectedSource;

  LiveDestination?
  _selectedDestination;

  bool _searchingStations =
  false;

  bool _loadingDestinations =
  false;

  bool _loadingTrains =
  false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _blinkController =
    AnimationController(
      vsync: this,
      duration:
      const Duration(
        milliseconds: 700,
      ),
    )..repeat(
      reverse: true,
    );

    _blinkAnimation =
        Tween<double>(
          begin: 0.2,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent:
            _blinkController,
            curve:
            Curves.easeInOut,
          ),
        );

    _refreshTimer =
        Timer.periodic(
          const Duration(
            seconds: 60,
          ),
              (_) {
            if (!mounted) {
              return;
            }

            if (
            _selectedSource !=
                null &&
                _selectedDestination !=
                    null) {
              _refreshCurrentSelection();
            }
          },
        );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _refreshTimer?.cancel();
    _blinkController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<dynamic> _getJson(
      String path,
      ) async {
    final uri = Uri.parse(
      '$_backendBaseUrl$path',
    );

    final response =
    await http.get(
      uri,
      headers: const {
        'Accept':
        'application/json',
      },
    ).timeout(
      const Duration(
        seconds: 20,
      ),
    );

    dynamic decoded;

    try {
      decoded =
          jsonDecode(
            response.body,
          );
    } catch (_) {
      throw Exception(
        'Live train server returned an invalid response.',
      );
    }

    if (
    response.statusCode <
        200 ||
        response.statusCode >=
            300) {
      final message =
      decoded is Map
          ? _stringValue(
        decoded['error'],
        fallback:
        'Unable to load live train information.',
      )
          : 'Unable to load live train information.';

      throw Exception(
        message,
      );
    }

    return decoded;
  }

  void _onStationSearchChanged(
      String value,
      ) {
    _searchDebounce?.cancel();

    final query =
    value.trim();

    if (query.length < 2) {
      setState(() {
        _stations = [];
        _searchingStations =
        false;
        _errorMessage = null;
      });

      return;
    }

    _searchDebounce =
        Timer(
          const Duration(
            milliseconds: 800,
          ),
              () {
            _searchStations(
              query,
            );
          },
        );
  }

  Future<void> _searchStations(
      String query,
      ) async {
    if (!mounted) {
      return;
    }

    final normalized =
    query
        .trim()
        .toLowerCase();

    final cached =
    _stationSearchCache[
    normalized];

    if (
    cached != null &&
        DateTime.now()
            .difference(
          cached.fetchedAt,
        )
            .inMinutes <
            10) {
      setState(() {
        _stations =
        List<LiveStation>.from(
          cached.stations,
        );

        _searchingStations =
        false;

        _errorMessage = null;
      });

      return;
    }

    setState(() {
      _searchingStations =
      true;

      _errorMessage = null;
    });

    try {
      final data =
      await _getJson(
        '/searchMumbaiStations?q=${Uri.encodeQueryComponent(query)}',
      );

      final raw =
      data is Map
          ? data['stations']
          : null;

      final stations =
      <LiveStation>[];

      if (raw is List) {
        for (
        final item
        in raw
        ) {
          if (item is Map) {
            final station =
            LiveStation.fromMap(
              Map<String, dynamic>.from(
                item,
              ),
            );

            if (
            station.code
                .isNotEmpty &&
                station.name
                    .isNotEmpty) {
              stations.add(
                station,
              );
            }
          }
        }
      }

      _stationSearchCache[
      normalized] =
          _CachedStationSearch(
            fetchedAt:
            DateTime.now(),
            stations:
            List<LiveStation>.from(
              stations,
            ),
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _stations =
            stations;

        _searchingStations =
        false;

        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _stations = [];

        _searchingStations =
        false;

        _errorMessage =
            _cleanError(
              error,
            );
      });
    }
  }

  Future<void> _selectSource(
      LiveStation station,
      ) async {
    FocusScope.of(
      context,
    ).unfocus();

    setState(() {
      _selectedSource =
          station;

      _selectedDestination =
      null;

      _destinations = [];

      _trains = [];

      _loadingDestinations =
      true;

      _loadingTrains =
      false;

      _errorMessage = null;

      _searchController.text =
          station.name;

      _stations = [];
    });

    try {
      final data =
      await _getJson(
        '/liveTrainDestinations?code=${Uri.encodeQueryComponent(station.code)}',
      );

      final raw =
      data is Map
          ? data['destinations']
          : null;

      final destinations =
      <LiveDestination>[];

      if (raw is List) {
        for (
        final item
        in raw
        ) {
          if (item is Map) {
            final destination =
            LiveDestination.fromMap(
              Map<String, dynamic>.from(
                item,
              ),
            );

            if (
            destination.code
                .isNotEmpty &&
                destination.name
                    .isNotEmpty) {
              destinations.add(
                destination,
              );
            }
          }
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _destinations =
            destinations;

        _loadingDestinations =
        false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingDestinations =
        false;

        _errorMessage =
            _cleanError(
              error,
            );
      });
    }
  }

  Future<void> _selectDestination(
      LiveDestination destination,
      ) async {
    if (_selectedSource ==
        null) {
      return;
    }

    setState(() {
      _selectedDestination =
          destination;

      _trains = [];

      _loadingTrains =
      true;

      _errorMessage = null;
    });

    await _loadTrainsForDestination();
  }

  Future<void>
  _loadTrainsForDestination() async {
    final source =
        _selectedSource;

    final destination =
        _selectedDestination;

    if (
    source == null ||
        destination == null) {
      return;
    }

    try {
      final data =
      await _getJson(
        '/liveTrainsAtStation?code=${Uri.encodeQueryComponent(source.code)}',
      );

      final raw =
      data is Map
          ? data['trains']
          : null;

      final trains =
      <LiveTrainSummary>[];

      if (raw is List) {
        for (
        final item
        in raw
        ) {
          if (item is Map) {
            try {
              trains.add(
                LiveTrainSummary.fromMap(
                  Map<String, dynamic>.from(
                    item,
                  ),
                ),
              );
            } catch (_) {}
          }
        }
      }

      final filtered =
      trains.where(
            (train) {
          final sameCode =
              train.destinationCode
                  .toUpperCase() ==
                  destination.code
                      .toUpperCase();

          final sameName =
              train.destinationName
                  .toLowerCase() ==
                  destination.name
                      .toLowerCase();

          if (
          !sameCode &&
              !sameName) {
            return false;
          }

          if (
          train.liveType ==
              'departed' ||
              train.liveType ==
                  'completed' ||
              train.liveType ==
                  'cancelled') {
            return false;
          }

          return true;
        },
      ).toList();

      filtered.sort(
            (a, b) =>
            _departureMinutes(
              a.departure,
            ).compareTo(
              _departureMinutes(
                b.departure,
              ),
            ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _trains =
            filtered;

        _loadingTrains =
        false;

        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingTrains =
        false;

        _errorMessage =
            _cleanError(
              error,
            );
      });
    }
  }

  Future<void>
  _refreshCurrentSelection() async {
    if (
    _selectedSource ==
        null ||
        _selectedDestination ==
            null) {
      return;
    }

    await _loadTrainsForDestination();
  }

  void _goBackToSource() {
    setState(() {
      _selectedSource =
      null;

      _selectedDestination =
      null;

      _destinations = [];

      _trains = [];

      _errorMessage = null;

      _searchController
          .clear();

      _stations = [];
    });
  }

  void _goBackToDestinations() {
    setState(() {
      _selectedDestination =
      null;

      _trains = [];

      _errorMessage = null;
    });
  }

  Future<LiveTrainDetail?>
  _fetchTrainDetail(
      String trainNumber,
      ) async {
    if (
    !RegExp(
      r'^\d{5}$',
    ).hasMatch(
      trainNumber,
    )) {
      return null;
    }

    try {
      final data =
      await _getJson(
        '/liveTrain/${Uri.encodeComponent(trainNumber)}',
      );

      final raw =
      data is Map
          ? data['data']
          : null;

      if (raw is! Map) {
        return null;
      }

      return LiveTrainDetail
          .fromMap(
        Map<String, dynamic>.from(
          raw,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void>
  _showTrainDetails(
      LiveTrainSummary train,
      ) async {
    await showModalBottomSheet<
        void>(
      context: context,
      isScrollControlled:
      true,
      backgroundColor:
      Colors.white,
      builder:
          (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize:
          0.90,
          minChildSize:
          0.50,
          maxChildSize:
          0.98,
          builder:
              (
              context,
              controller,
              ) {
            return StreamBuilder<
                LiveTrainDetail?>(
              stream:
              _liveTrainStream(
                train.number,
              ),
              builder:
                  (
                  context,
                  snapshot,
                  ) {
                if (
                snapshot.connectionState ==
                    ConnectionState
                        .waiting &&
                    !snapshot
                        .hasData) {
                  return const SafeArea(
                    child: Center(
                      child:
                      CircularProgressIndicator(),
                    ),
                  );
                }

                final detail =
                    snapshot.data;

                if (detail ==
                    null) {
                  return _unavailableDetail(
                    context,
                  );
                }

                return _buildDetailSheet(
                  context,
                  controller,
                  detail,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _unavailableDetail(
      BuildContext context,
      ) {
    return SafeArea(
      child: Column(
        children: [
          _sheetHandle(),
          const SizedBox(
            height: 20,
          ),
          const Icon(
            Icons.cloud_off,
            size: 45,
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            'Live train details unavailable.',
            style:
            TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          const Padding(
            padding:
            EdgeInsets.all(20),
            child: Text(
              'The live station board is available, but detailed telemetry could not be loaded right now.',
              textAlign:
              TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(
                  context,
                ),
            child:
            const Text(
              'Close',
            ),
          ),
        ],
      ),
    );
  }

  Stream<LiveTrainDetail?>
  _liveTrainStream(
      String trainNumber,
      ) async* {
    while (true) {
      if (!mounted) {
        return;
      }

      yield await _fetchTrainDetail(
        trainNumber,
      );

      await Future.delayed(
        const Duration(
          seconds: 60,
        ),
      );
    }
  }

  Widget _buildDetailSheet(
      BuildContext context,
      ScrollController controller,
      LiveTrainDetail detail,
      ) {
    final currentIndex =
    _currentRouteIndex(
      detail,
    );

    return SafeArea(
      child: Column(
        children: [
          _sheetHandle(),

          ListTile(
            title: Text(
              '${detail.sourceName} → ${detail.destinationName}',
              style:
              const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${detail.number} • ${detail.name}',
            ),
            trailing:
            IconButton(
              icon:
              const Icon(
                Icons.close,
              ),
              onPressed: () =>
                  Navigator.pop(
                    context,
                  ),
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _infoCard(
                    'Status',
                    _displayStatus(
                      detail.status,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: _infoCard(
                    'Delay',
                    detail.delayMinutes ==
                        0
                        ? 'On time'
                        : '${detail.delayMinutes} min',
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: _infoCard(
                    'Speed',
                    detail.speedKmh ==
                        null
                        ? '--'
                        : '${detail.speedKmh!.round()} km/h',
                  ),
                ),
              ],
            ),
          ),

          if (
          detail.currentLat !=
              null &&
              detail.currentLng !=
                  null) ...[
            const SizedBox(
              height: 12,
            ),

            LiveTrainMap(
              latitude:
              detail.currentLat!,
              longitude:
              detail.currentLng!,
              routePoints:
              detail.geometryPoints,
            ),

            const SizedBox(
              height: 8,
            ),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 10,
                    color:
                    Colors.green,
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  const Text(
                    'LIVE LOCATION',
                    style:
                    TextStyle(
                      color:
                      Colors.green,
                      fontSize: 11,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    detail.lastUpdatedAt ==
                        null
                        ? 'Waiting for update'
                        : 'RailRadar updated ${_formatLiveUpdatedTime(detail.lastUpdatedAt!)}',
                    style:
                    TextStyle(
                      fontSize: 11,
                      color: Colors
                          .grey
                          .shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (
          detail.currentStationName !=
              null ||
              detail.nextStationName !=
                  null) ...[
            const SizedBox(
              height: 10,
            ),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child:
              _positionBanner(
                detail,
              ),
            ),
          ],

          const SizedBox(
            height: 12,
          ),

          const Divider(
            height: 1,
          ),

          const Padding(
            padding:
            EdgeInsets.all(16),
            child: Align(
              alignment:
              Alignment.centerLeft,
              child: Text(
                'Live Route',
                style:
                TextStyle(
                  fontSize: 17,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child:
            _routeList(
              detail,
              currentIndex,
              controller,
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeList(
      LiveTrainDetail detail,
      int? currentIndex,
      ScrollController controller,
      ) {
    if (detail.route.isEmpty) {
      return const Center(
        child: Text(
          'Route information unavailable.',
        ),
      );
    }

    return ListView.builder(
      controller:
      controller,
      padding:
      const EdgeInsets.only(
        bottom: 20,
      ),
      itemCount:
      detail.route.length,
      itemBuilder:
          (
          context,
          index,
          ) {
        final stop =
        detail.route[index];

        final isCurrent =
            currentIndex ==
                index;

        return SizedBox(
          height: 54,
          child: Row(
            children: [
              SizedBox(
                width: 45,
                child:
                Stack(
                  alignment:
                  Alignment.center,
                  children: [
                    if (
                    index <
                        detail.route.length -
                            1)
                      Positioned(
                        top: 28,
                        bottom: 0,
                        child:
                        Container(
                          width: 2,
                          color: Colors
                              .grey
                              .shade300,
                        ),
                      ),
                    if (isCurrent)
                      AnimatedBuilder(
                        animation:
                        _blinkAnimation,
                        builder:
                            (
                            context,
                            child,
                            ) {
                          return Opacity(
                            opacity:
                            _blinkAnimation
                                .value,
                            child:
                            Container(
                              width: 14,
                              height: 14,
                              decoration:
                              const BoxDecoration(
                                color: Colors
                                    .green,
                                shape: BoxShape
                                    .circle,
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        width: 8,
                        height: 8,
                        decoration:
                        BoxDecoration(
                          color: Colors
                              .grey
                              .shade400,
                          shape:
                          BoxShape
                              .circle,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        stop.name,
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        TextStyle(
                          fontWeight:
                          isCurrent
                              ? FontWeight
                              .bold
                              : FontWeight
                              .normal,
                          color:
                          isCurrent
                              ? Colors
                              .green
                              .shade700
                              : null,
                        ),
                      ),
                    ),
                    Text(
                      stop.displayTime,
                      style:
                      TextStyle(
                        fontWeight:
                        isCurrent
                            ? FontWeight
                            .bold
                            : FontWeight
                            .w600,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _positionBanner(
      LiveTrainDetail detail,
      ) {
    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        12,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.green.shade50,
        borderRadius:
        BorderRadius.circular(
          10,
        ),
        border: Border.all(
          color:
          Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.my_location,
            color:
            Colors.green,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                if (
                detail.currentStationName !=
                    null)
                  Text(
                    'Current: ${detail.currentStationName}',
                    style:
                    TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: Colors
                          .green
                          .shade800,
                    ),
                  ),
                if (
                detail.nextStationName !=
                    null)
                  Text(
                    'Next: ${detail.nextStationName}',
                    style:
                    TextStyle(
                      fontSize: 12,
                      color: Colors
                          .green
                          .shade800,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetHandle() {
    return Container(
      width: 40,
      height: 4,
      margin:
      const EdgeInsets.only(
        top: 8,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.grey.shade400,
        borderRadius:
        BorderRadius.circular(
          10,
        ),
      ),
    );
  }

  Widget _infoCard(
      String title,
      String value,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(
        10,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.grey.shade50,
        borderRadius:
        BorderRadius.circular(
          9,
        ),
        border: Border.all(
          color:
          Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style:
            TextStyle(
              fontSize: 10,
              color:
              Colors.grey.shade600,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            value,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              fontWeight:
              FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceScreen() {
    final query =
    _searchController.text
        .trim();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Padding(
          padding:
          EdgeInsets.fromLTRB(
            16,
            18,
            16,
            5,
          ),
          child: Text(
            'Search Source Station',
            style:
            TextStyle(
              fontSize: 21,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ),

        Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Text(
            'Search a Mumbai suburban station.',
            style:
            TextStyle(
              color:
              Colors.grey.shade600,
            ),
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: TextField(
            controller:
            _searchController,
            onChanged:
            _onStationSearchChanged,
            textInputAction:
            TextInputAction.search,
            decoration:
            InputDecoration(
              hintText:
              'Search station...',
              prefixIcon:
              const Icon(
                Icons.search,
              ),
              suffixIcon:
              query.isEmpty
                  ? null
                  : IconButton(
                icon:
                const Icon(
                  Icons.clear,
                ),
                onPressed:
                    () {
                  setState(
                        () {
                      _searchController
                          .clear();

                      _stations =
                      [];

                      _errorMessage =
                      null;
                    },
                  );
                },
              ),
              border:
              OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
            ),
          ),
        ),

        if (_searchingStations)
          const Expanded(
            child: Center(
              child:
              CircularProgressIndicator(),
            ),
          )
        else if (
        _errorMessage != null)
          Expanded(
            child: _errorBox(
              _errorMessage!,
              onRetry:
              query.length >= 2
                  ? () =>
                  _searchStations(
                    query,
                  )
                  : null,
            ),
          )
        else if (
          _stations.isNotEmpty)
            Expanded(
              child:
              ListView.separated(
                padding:
                const EdgeInsets.all(
                  16,
                ),
                itemCount:
                _stations.length,
                separatorBuilder:
                    (_, __) =>
                const Divider(
                  height: 1,
                ),
                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  final station =
                  _stations[index];

                  return ListTile(
                    leading:
                    const Icon(
                      Icons.train,
                      color:
                      Colors.blue,
                    ),
                    title: Text(
                      station.name,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    subtitle:
                    Text(
                      station.code,
                    ),
                    trailing:
                    const Icon(
                      Icons
                          .chevron_right,
                    ),
                    onTap:
                        () =>
                        _selectSource(
                          station,
                        ),
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text(
                  'Search for a station',
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildDestinationScreen() {
    return Column(
      children: [
        Padding(
          padding:
          const EdgeInsets.fromLTRB(
            8,
            8,
            12,
            4,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed:
                _goBackToSource,
                icon:
                const Icon(
                  Icons.arrow_back,
                ),
              ),
              Expanded(
                child: Text(
                  _selectedSource!
                      .name,
                  style:
                  const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed:
                _loadingDestinations
                    ? null
                    : () =>
                    _selectSource(
                      _selectedSource!,
                    ),
                icon:
                const Icon(
                  Icons.refresh,
                ),
              ),
            ],
          ),
        ),

        const Padding(
          padding:
          EdgeInsets.all(16),
          child: Align(
            alignment:
            Alignment.centerLeft,
            child: Text(
              'Where do you want to go?',
              style:
              TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ),

        if (_loadingDestinations)
          const Expanded(
            child: Center(
              child:
              CircularProgressIndicator(),
            ),
          )
        else if (
        _errorMessage != null)
          Expanded(
            child: _errorBox(
              _errorMessage!,
              onRetry:
                  () =>
                  _selectSource(
                    _selectedSource!,
                  ),
            ),
          )
        else if (
          _destinations.isEmpty)
            const Expanded(
              child: Center(
                child: Padding(
                  padding:
                  EdgeInsets.all(
                    24,
                  ),
                  child: Text(
                    'No live destinations are available right now.',
                    textAlign:
                    TextAlign.center,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child:
              ListView.separated(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                itemCount:
                _destinations.length,
                separatorBuilder:
                    (_, __) =>
                const SizedBox(
                  height: 8,
                ),
                itemBuilder:
                    (
                    context,
                    index,
                    ) {
                  final destination =
                  _destinations[
                  index];

                  return ListTile(
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                      side:
                      BorderSide(
                        color: Colors
                            .grey
                            .shade300,
                      ),
                    ),
                    leading:
                    const Icon(
                      Icons.train,
                      color:
                      Colors.blue,
                    ),
                    title:
                    Text(
                      destination.name,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    trailing:
                    const Icon(
                      Icons
                          .chevron_right,
                    ),
                    onTap:
                        () =>
                        _selectDestination(
                          destination,
                        ),
                  );
                },
              ),
            ),
      ],
    );
  }

  Widget _buildTrainResultsScreen() {
    return Column(
      children: [
        Padding(
          padding:
          const EdgeInsets.fromLTRB(
            8,
            8,
            12,
            4,
          ),
          child: Row(
            children: [
              IconButton(
                onPressed:
                _goBackToDestinations,
                icon:
                const Icon(
                  Icons.arrow_back,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      '${_selectedSource!.name} → ${_selectedDestination!.name}',
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${_trains.length} live departures',
                      style:
                      TextStyle(
                        fontSize: 12,
                        color: Colors
                            .grey
                            .shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed:
                _loadingTrains
                    ? null
                    : _loadTrainsForDestination,
                icon:
                const Icon(
                  Icons.refresh,
                ),
              ),
            ],
          ),
        ),

        const Divider(
          height: 1,
        ),

        if (_loadingTrains)
          const Expanded(
            child: Center(
              child:
              CircularProgressIndicator(),
            ),
          )
        else if (
        _errorMessage != null)
          Expanded(
            child: _errorBox(
              _errorMessage!,
              onRetry:
              _loadTrainsForDestination,
            ),
          )
        else if (
          _trains.isEmpty)
            const Expanded(
              child: Center(
                child: Padding(
                  padding:
                  EdgeInsets.all(
                    24,
                  ),
                  child: Text(
                    'No matching Mumbai local is currently shown by the live board.',
                    textAlign:
                    TextAlign.center,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child:
              RefreshIndicator(
                onRefresh:
                _loadTrainsForDestination,
                child:
                ListView.separated(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  itemCount:
                  _trains.length,
                  separatorBuilder:
                      (_, __) =>
                  const Divider(
                    height: 1,
                  ),
                  itemBuilder:
                      (
                      context,
                      index,
                      ) {
                    final train =
                    _trains[index];

                    return ListTile(
                      contentPadding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 4,
                        vertical: 5,
                      ),
                      leading:
                      Container(
                        width: 42,
                        height: 42,
                        decoration:
                        BoxDecoration(
                          color: Colors
                              .blue
                              .shade50,
                          borderRadius:
                          BorderRadius
                              .circular(
                            9,
                          ),
                        ),
                        child:
                        const Icon(
                          Icons.train,
                          color:
                          Colors.blue,
                        ),
                      ),
                      title:
                      Text(
                        train.number,
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      subtitle:
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            train.name,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            'Departure ${_formatTime(train.departure)}',
                          ),
                        ],
                      ),
                      trailing:
                      Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .end,
                        children: [
                          Text(
                            _statusLabel(
                              train.liveType,
                            ),
                            style:
                            TextStyle(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.bold,
                              color:
                              _statusColor(
                                train.liveType,
                              ),
                            ),
                          ),
                          if (
                          train.delayMinutes >
                              0)
                            Text(
                              '+${train.delayMinutes} min',
                              style:
                              TextStyle(
                                fontSize:
                                10,
                                color: Colors
                                    .orange
                                    .shade800,
                              ),
                            ),
                          const Icon(
                            Icons
                                .chevron_right,
                            size: 18,
                          ),
                        ],
                      ),
                      onTap:
                          () =>
                          _showTrainDetails(
                            train,
                          ),
                    );
                  },
                ),
              ),
            ),
      ],
    );
  }

  Widget _errorBox(
      String message, {
        VoidCallback? onRetry,
      }) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          24,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 44,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              message,
              textAlign:
              TextAlign.center,
            ),
            if (onRetry !=
                null) ...[
              const SizedBox(
                height: 14,
              ),
              ElevatedButton(
                onPressed:
                onRetry,
                child:
                const Text(
                  'Retry',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int? _currentRouteIndex(
      LiveTrainDetail detail,
      ) {
    final code =
        detail.currentStationCode;

    if (
    code == null ||
        code.isEmpty) {
      return null;
    }

    for (
    var i = 0;
    i < detail.route.length;
    i++
    ) {
      if (
      detail.route[i]
          .code
          .toUpperCase() ==
          code.toUpperCase()) {
        return i;
      }
    }

    return null;
  }

  String _displayStatus(
      String value,
      ) {
    if (value.isEmpty) {
      return 'Live';
    }

    return value
        .replaceAll(
      '_',
      ' ',
    )
        .split(' ')
        .where(
          (word) =>
      word.isNotEmpty,
    )
        .map(
          (word) =>
      '${word[0].toUpperCase()}${word.substring(1)}',
    )
        .join(' ');
  }

  String _statusLabel(
      String value,
      ) {
    switch (value) {
      case 'at-station':
        return 'At station';
      case 'upcoming':
        return 'Upcoming';
      case 'scheduled':
        return 'Scheduled';
      case 'departed':
        return 'Departed';
      default:
        return 'Live';
    }
  }

  Color _statusColor(
      String value,
      ) {
    switch (value) {
      case 'at-station':
        return Colors.green.shade700;
      case 'upcoming':
        return Colors.blue.shade700;
      case 'departed':
        return Colors.grey.shade600;
      default:
        return Colors.orange.shade700;
    }
  }

  String _cleanError(
      Object error,
      ) {
    final value =
    error.toString();

    if (
    value.startsWith(
      'Exception: ',
    )) {
      return value.substring(
        11,
      );
    }

    return value;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    Widget body;

    if (
    _selectedSource ==
        null) {
      body =
          _buildSourceScreen();
    } else if (
    _selectedDestination ==
        null) {
      body =
          _buildDestinationScreen();
    } else {
      body =
          _buildTrainResultsScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title:
        const Text(
          'Live Trains',
        ),
        centerTitle:
        true,
      ),
      body: body,
    );
  }
}

class LiveTrainMap
    extends StatefulWidget {
  final double latitude;
  final double longitude;
  final List<LatLng>
  routePoints;

  const LiveTrainMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.routePoints =
    const [],
  });

  @override
  State<LiveTrainMap>
  createState() =>
      _LiveTrainMapState();
}

class _LiveTrainMapState
    extends State<LiveTrainMap>
    with
        SingleTickerProviderStateMixin {
  late AnimationController
  _animationController;

  LatLng? _oldPosition;
  LatLng? _newPosition;

  @override
  void initState() {
    super.initState();

    _newPosition =
        LatLng(
          widget.latitude,
          widget.longitude,
        );

    _animationController =
        AnimationController(
          vsync: this,
          duration:
          const Duration(
            seconds: 55,
          ),
        );
  }

  @override
  void didUpdateWidget(
      covariant LiveTrainMap
      oldWidget,
      ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (
    oldWidget.latitude !=
        widget.latitude ||
        oldWidget.longitude !=
            widget.longitude) {
      _oldPosition =
          _newPosition;

      _newPosition =
          LatLng(
            widget.latitude,
            widget.longitude,
          );

      _animationController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animationController
        .dispose();

    super.dispose();
  }

  LatLng get _currentPosition {
    final oldPosition =
        _oldPosition;

    final newPosition =
        _newPosition;

    if (newPosition ==
        null) {
      return const LatLng(
        19.0,
        73.0,
      );
    }

    if (oldPosition ==
        null) {
      return newPosition;
    }

    final progress =
    Curves.easeInOut.transform(
      _animationController
          .value,
    );

    return LatLng(
      oldPosition.latitude +
          (newPosition
              .latitude -
              oldPosition
                  .latitude) *
              progress,
      oldPosition.longitude +
          (newPosition
              .longitude -
              oldPosition
                  .longitude) *
              progress,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final initial =
        _newPosition ??
            LatLng(
              widget.latitude,
              widget.longitude,
            );

    return Container(
      height: 260,
      margin:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      clipBehavior:
      Clip.antiAlias,
      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
          Colors.grey.shade300,
        ),
      ),
      child:
      AnimatedBuilder(
        animation:
        _animationController,
        builder:
            (
            context,
            child,
            ) {
          return FlutterMap(
            options:
            MapOptions(
              initialCenter:
              initial,
              initialZoom:
              13.5,
              interactionOptions:
              const InteractionOptions(
                flags:
                InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                'com.smartlocaltrain.app',
              ),

              if (
              widget.routePoints
                  .length >=
                  2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points:
                      widget.routePoints,
                      strokeWidth:
                      5,
                      color:
                      Colors.blue.shade700,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  Marker(
                    point:
                    _currentPosition,
                    width: 70,
                    height: 70,
                    child:
                    Container(
                      alignment:
                      Alignment.center,
                      child:
                      Container(
                        width: 44,
                        height: 44,
                        decoration:
                        BoxDecoration(
                          color:
                          Colors.green,
                          shape:
                          BoxShape
                              .circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .green
                                  .withValues(
                                alpha:
                                0.35,
                              ),
                              blurRadius:
                              12,
                              spreadRadius:
                              4,
                            ),
                          ],
                        ),
                        child:
                        const Icon(
                          Icons.train,
                          color:
                          Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

String _stringValue(
    dynamic value, {
      String fallback = '',
    }) {
  if (value == null) {
    return fallback;
  }

  if (value is String) {
    final text =
    value.trim();

    return text.isEmpty
        ? fallback
        : text;
  }

  return value.toString();
}

String? _nullableString(
    dynamic value,
    ) {
  final text =
  _stringValue(
    value,
  );

  return text.isEmpty
      ? null
      : text;
}

int _intValue(
    dynamic value,
    ) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.round();
  }

  return int.tryParse(
    value?.toString() ??
        '',
  ) ??
      0;
}

double? _doubleValue(
    dynamic value,
    ) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(
    value?.toString() ??
        '',
  );
}

Map<String, dynamic>
_mapValue(
    dynamic value,
    ) {
  if (
  value
  is Map<String,
      dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String,
        dynamic>.from(
      value,
    );
  }

  return <
      String,
      dynamic>{};
}

_DestinationValue
_destinationValue(
    dynamic value,
    ) {
  if (value is Map) {
    final map =
    Map<String,
        dynamic>.from(
      value,
    );

    final code =
    _stringValue(
      map['code'],
    );

    final name =
    _stringValue(
      map['name'],
      fallback: code,
    );

    return _DestinationValue(
      code: code,
      name: name,
    );
  }

  final text =
  _stringValue(
    value,
  );

  return _DestinationValue(
    code: text,
    name: text,
  );
}

_StationValue
_stationValue(
    dynamic value,
    ) {
  if (value is Map) {
    final map =
    Map<String,
        dynamic>.from(
      value,
    );

    final code =
    _stringValue(
      map['code'],
    );

    final name =
    _stringValue(
      map['name'],
      fallback: code,
    );

    return _StationValue(
      code: code,
      name: name,
    );
  }

  final text =
  _stringValue(
    value,
  );

  return _StationValue(
    code: text,
    name: text,
  );
}

int _departureMinutes(
    String value,
    ) {
  if (value.isEmpty) {
    return 999999;
  }

  final parts =
  value.split(':');

  if (parts.length <
      2) {
    return 999999;
  }

  final hour =
      int.tryParse(
        parts[0],
      ) ??
          0;

  final minute =
      int.tryParse(
        parts[1],
      ) ??
          0;

  return hour * 60 +
      minute;
}

String _formatTime(
    String value,
    ) {
  if (value.isEmpty) {
    return '--';
  }

  final parts =
  value.split(':');

  if (parts.length <
      2) {
    return value;
  }

  var hour =
      int.tryParse(
        parts[0],
      ) ??
          0;

  final minute =
      int.tryParse(
        parts[1],
      ) ??
          0;

  final suffix =
  hour >= 12
      ? 'PM'
      : 'AM';

  if (hour == 0) {
    hour = 12;
  } else if (hour > 12) {
    hour -= 12;
  }

  return '$hour:${minute.toString().padLeft(2, '0')} $suffix';
}

String _formatLiveUpdatedTime(
    String value,
    ) {
  final parsed =
  DateTime.tryParse(
    value,
  );

  if (parsed == null) {
    return value;
  }

  final local =
  parsed.toLocal();

  var hour =
      local.hour;

  final minute =
  local.minute
      .toString()
      .padLeft(
    2,
    '0',
  );

  final second =
  local.second
      .toString()
      .padLeft(
    2,
    '0',
  );

  final suffix =
  hour >= 12
      ? 'PM'
      : 'AM';

  if (hour == 0) {
    hour = 12;
  } else if (hour > 12) {
    hour -= 12;
  }

  return '$hour:$minute:$second $suffix';
}

String _formatIsoOrTime(
    String value,
    ) {
  final parsed =
  DateTime.tryParse(
    value,
  );

  if (parsed == null) {
    return _formatTime(
      value,
    );
  }

  var hour =
      parsed.toLocal().hour;

  final minute =
      parsed.toLocal().minute;

  final suffix =
  hour >= 12
      ? 'PM'
      : 'AM';

  if (hour == 0) {
    hour = 12;
  } else if (hour > 12) {
    hour -= 12;
  }

  return '$hour:${minute.toString().padLeft(2, '0')} $suffix';
}