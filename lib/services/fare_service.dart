class FareService {
  // ============================================================
  // MUMBAI SUBURBAN SECOND-CLASS SINGLE-JOURNEY FARES
  // ============================================================
  //
  // Distance is in kilometres.
  //
  // These are the current project fare slabs used for
  // ordinary second-class suburban tickets.
  //
  // We deliberately keep the fare table in one service so
  // that it can be updated later without changing the UI.
  //
  // ============================================================

  static const List<_FareSlab> _secondClassFareSlabs = [
    _FareSlab(0, 5, 5),
    _FareSlab(6, 10, 5),
    _FareSlab(11, 15, 10),
    _FareSlab(16, 20, 10),
    _FareSlab(21, 25, 10),
    _FareSlab(26, 30, 10),
    _FareSlab(31, 35, 15),
    _FareSlab(36, 40, 15),
    _FareSlab(41, 45, 15),
    _FareSlab(46, 50, 15),
    _FareSlab(51, 55, 15),
    _FareSlab(56, 60, 20),
    _FareSlab(61, 65, 20),
    _FareSlab(66, 70, 20),
    _FareSlab(71, 75, 20),
    _FareSlab(76, 80, 20),
    _FareSlab(81, 85, 25),
    _FareSlab(86, 90, 25),
    _FareSlab(91, 95, 25),
    _FareSlab(96, 100, 30),
    _FareSlab(101, 105, 30),
    _FareSlab(106, 110, 30),
    _FareSlab(111, 115, 30),
    _FareSlab(116, 120, 30),
    _FareSlab(121, 125, 35),
  ];

  // ============================================================
  // DISTANCE BETWEEN TWO ADJACENT STATIONS
  // ============================================================
  //
  // These values are used to calculate the railway route
  // distance instead of simply counting stations.
  //
  // ============================================================

  static const Map<String, double>
  _segmentDistances = {
    // ----------------------------------------------------------
    // CENTRAL LINE
    // ----------------------------------------------------------

    'CSMT|Masjid': 1,
    'Masjid|Sandhurst Road': 1,
    'Sandhurst Road|Byculla': 2,
    'Byculla|Chinchpokli': 1,
    'Chinchpokli|Currey Road': 1,
    'Currey Road|Parel': 2,
    'Parel|Dadar': 1,
    'Dadar|Matunga': 1,
    'Matunga|Sion': 3,
    'Sion|Kurla': 3,
    'Kurla|Vidyavihar': 2,
    'Vidyavihar|Ghatkopar': 2,
    'Ghatkopar|Vikhroli': 4,
    'Vikhroli|Kanjur Marg': 2,
    'Kanjur Marg|Bhandup': 2,
    'Bhandup|Nahur': 2,
    'Nahur|Mulund': 3,
    'Mulund|Thane': 2,
    'Thane|Kalwa': 2,
    'Kalwa|Mumbra': 4,
    'Mumbra|Diva Junction': 3,
    'Diva Junction|Kopar': 4,
    'Kopar|Dombivli': 3,
    'Dombivli|Thakurli': 1,
    'Thakurli|Kalyan Junction': 4,
    'Kalyan Junction|Shahad': 3,
    'Shahad|Ambivli': 2,
    'Ambivli|Titwala': 6,
    'Titwala|Khadavli': 7,
    'Khadavli|Vasind': 8,
    'Vasind|Asangaon': 6,
    'Asangaon|Atgaon': 9,
    'Atgaon|Thansit': 6,
    'Thansit|Khardi': 6,
    'Khardi|Oombermali': 6,
    'Oombermali|Kasara': 7,

    // ----------------------------------------------------------
    // KALYAN - KARJAT / KHOPOLI
    // ----------------------------------------------------------

    'Kalyan Junction|Vithalwadi': 2,
    'Vithalwadi|Ulhasnagar': 2,
    'Ulhasnagar|Ambernath': 4,
    'Ambernath|Chikhloli': 3,
    'Chikhloli|Badlapur': 3,
    'Badlapur|Vangani': 7,
    'Vangani|Shelu': 5,
    'Shelu|Neral': 4,
    'Neral|Bhivpuri Road': 5,
    'Bhivpuri Road|Karjat': 7,
    'Karjat|Palasdhari': 5,
    'Palasdhari|Kelavli': 3,
    'Kelavli|Dolavli': 3,
    'Dolavli|Lowjee': 3,
    'Lowjee|Khopoli': 3,

    // ----------------------------------------------------------
    // HARBOUR LINE
    // ----------------------------------------------------------

    'Sandhurst Road|Dockyard Road': 1,
    'Dockyard Road|Reay Road': 1,
    'Reay Road|Cotton Green': 2,
    'Cotton Green|Sewri': 1,
    'Sewri|Wadala Road': 2,
    'Wadala Road|GTB Nagar': 2,
    'GTB Nagar|Chunabhatti': 2,
    'Chunabhatti|Kurla': 2,
    'Kurla|Tilak Nagar': 1,
    'Tilak Nagar|Chembur': 1,
    'Chembur|Govandi': 2,
    'Govandi|Mankhurd': 2,
    'Mankhurd|Vashi': 8,
    'Vashi|Sanpada': 1,
    'Sanpada|Juinagar': 2,
    'Juinagar|Nerul': 2,
    'Nerul|Seawoods Darave': 2,
    'Seawoods Darave|Belapur CBD': 2,
    'Belapur CBD|Kharghar': 2,
    'Kharghar|Mansarovar': 4,
    'Mansarovar|Khandeshwar': 2,
    'Khandeshwar|Panvel': 3,

    // ----------------------------------------------------------
    // WESTERN LINE
    // ----------------------------------------------------------

    'Churchgate|Marine Lines': 1,
    'Marine Lines|Charni Road': 1,
    'Charni Road|Grant Road': 1,
    'Grant Road|Mumbai Central': 1,
    'Mumbai Central|Mahalaxmi': 1,
    'Mahalaxmi|Lower Parel': 2,
    'Lower Parel|Prabhadevi': 1,
    'Prabhadevi|Dadar': 1,
    'Dadar|Matunga Road': 2,
    'Matunga Road|Mahim Junction': 1,
    'Mahim Junction|Bandra': 2,
    'Bandra|Khar Road': 2,
    'Khar Road|Santacruz': 1,
    'Santacruz|Vile Parle': 2,
    'Vile Parle|Andheri': 2,
    'Andheri|Jogeshwari': 2,
    'Jogeshwari|Ram Mandir': 2,
    'Ram Mandir|Goregaon': 1,
    'Goregaon|Malad': 2,
    'Malad|Kandivali': 2,
    'Kandivali|Borivali': 3,
    'Borivali|Dahisar': 2,
    'Dahisar|Mira Road': 3,
    'Mira Road|Bhayandar': 3,
    'Bhayandar|Naigaon': 5,
    'Naigaon|Vasai Road': 4,
    'Vasai Road|Nalasopara': 4,
    'Nalasopara|Virar': 4,
    'Virar|Vaitarna': 6,
    'Vaitarna|Saphale': 5,
    'Saphale|Kelve Road': 5,
    'Kelve Road|Palghar': 7,
    'Palghar|Umroli': 5,
    'Umroli|Boisar': 4,
    'Boisar|Vangaon': 7,
    'Vangaon|Dahanu Road': 9,

    // ----------------------------------------------------------
    // TRANS-HARBOUR
    // ----------------------------------------------------------

    'Thane|Digha Gaon': 3,
    'Digha Gaon|Airoli': 3,
    'Airoli|Rabale': 3,
    'Rabale|Ghansoli': 2,
    'Ghansoli|Koparkhairane': 2,
    'Koparkhairane|Turbhe': 3,
    'Turbhe|Sanpada': 2,

    // ----------------------------------------------------------
    // TRANS-HARBOUR / NERUL BRANCH
    // ----------------------------------------------------------

    'Turbhe|Juinagar': 2,

    // ----------------------------------------------------------
    // URAN LINE
    // ----------------------------------------------------------

    'Nerul|Bamandongri': 4,
    'Bamandongri|Kharkopar': 3,
    'Kharkopar|Gavan': 4,
    'Gavan|Ranjanpada': 5,
    'Ranjanpada|Nhava Sheva': 4,
    'Nhava Sheva|Uran': 4,
  };

  // ============================================================
  // NORMALIZE STATION PAIR
  // ============================================================

  static String _pairKey(
      String first,
      String second,
      ) {
    return '$first|$second';
  }

  // ============================================================
  // FIND SEGMENT DISTANCE
  // ============================================================

  static double _getSegmentDistance(
      String first,
      String second,
      ) {
    final String forward =
    _pairKey(first, second);

    final String reverse =
    _pairKey(second, first);

    return _segmentDistances[forward] ??
        _segmentDistances[reverse] ??
        2.0;
  }

  // ============================================================
  // CALCULATE ROUTE DISTANCE
  // ============================================================

  static double calculateRouteDistance({
    required List<String> route,
  }) {
    if (route.length < 2) {
      return 0;
    }

    double totalDistance = 0;

    for (int i = 0;
    i < route.length - 1;
    i++) {
      totalDistance +=
          _getSegmentDistance(
            route[i],
            route[i + 1],
          );
    }

    return totalDistance;
  }

  // ============================================================
  // CALCULATE ONE-WAY FARE
  // ============================================================

  static double calculateOneWayFare({
    required List<String> route,
  }) {
    final double distance =
    calculateRouteDistance(
      route: route,
    );

    return _fareForDistance(
      distance,
    );
  }

  // ============================================================
  // DISTANCE → FARE
  // ============================================================

  static double _fareForDistance(
      double distance,
      ) {
    if (distance <= 0) {
      return 0;
    }

    final int roundedDistance =
    distance.ceil();

    for (final slab
    in _secondClassFareSlabs) {
      if (roundedDistance >= slab.minKm &&
          roundedDistance <= slab.maxKm) {
        return slab.fare;
      }
    }

    // For routes beyond the currently
    // supported Mumbai suburban network.
    return 35;
  }

  // ============================================================
  // TOTAL FARE
  // ============================================================

  static double calculateTotalFare({
    required List<String> route,
    required int passengerCount,
    required String journeyType,
  }) {
    if (passengerCount < 1) {
      return 0;
    }

    final double oneWayFare =
    calculateOneWayFare(
      route: route,
    );

    final double journeyMultiplier =
    journeyType == 'return'
        ? 2
        : 1;

    return oneWayFare *
        passengerCount *
        journeyMultiplier;
  }

  // ============================================================
  // GET DISTANCE FOR DISPLAY
  // ============================================================

  static String getDistanceText({
    required List<String> route,
  }) {
    final double distance =
    calculateRouteDistance(
      route: route,
    );

    if (distance == distance.roundToDouble()) {
      return '${distance.toInt()} km';
    }

    return '${distance.toStringAsFixed(1)} km';
  }
}

// ============================================================
// FARE SLAB MODEL
// ============================================================

class _FareSlab {
  final int minKm;
  final int maxKm;
  final double fare;

  const _FareSlab(
      this.minKm,
      this.maxKm,
      this.fare,
      );
}