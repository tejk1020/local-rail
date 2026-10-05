class BookingModel {
  final String bookingId;
  final String userId;

  final String source;
  final String destination;
  final String? via;

  final String journeyType;
  final DateTime? journeyDate;

  final int passengerCount;
  final double totalFare;

  final String paymentStatus;
  final String bookingStatus;

  final DateTime? createdAt;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.source,
    required this.destination,
    this.via,
    required this.journeyType,
    this.journeyDate,
    required this.passengerCount,
    required this.totalFare,
    required this.paymentStatus,
    required this.bookingStatus,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'source': source,
      'destination': destination,
      'via': via,
      'journeyType': journeyType,
      'journeyDate': journeyDate,
      'passengerCount': passengerCount,
      'totalFare': totalFare,
      'paymentStatus': paymentStatus,
      'bookingStatus': bookingStatus,
      'createdAt': createdAt,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      bookingId: map['bookingId'] ?? '',
      userId: map['userId'] ?? '',
      source: map['source'] ?? '',
      destination: map['destination'] ?? '',
      via: map['via'],
      journeyType: map['journeyType'] ?? 'one_way',
      journeyDate: map['journeyDate'] != null
          ? (map['journeyDate'] as dynamic).toDate()
          : null,
      passengerCount: map['passengerCount'] ?? 1,
      totalFare: (map['totalFare'] ?? 0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? 'pending',
      bookingStatus: map['bookingStatus'] ?? 'active',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
    );
  }
}