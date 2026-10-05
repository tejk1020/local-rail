class TicketModel {
  final String ticketId;
  final String bookingId;
  final String ownerId;

  final String passengerName;

  final String source;
  final String destination;
  final String? via;

  final String trainName;
  final String trainNumber;

  final double fare;

  final String journeyType;
  final String status;

  final String qrToken;

  final DateTime? journeyDate;
  final DateTime? createdAt;

  TicketModel({
    required this.ticketId,
    required this.bookingId,
    required this.ownerId,
    required this.passengerName,
    required this.source,
    required this.destination,
    this.via,
    required this.trainName,
    required this.trainNumber,
    required this.fare,
    required this.journeyType,
    required this.status,
    required this.qrToken,
    this.journeyDate,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'bookingId': bookingId,
      'ownerId': ownerId,
      'passengerName': passengerName,
      'source': source,
      'destination': destination,
      'via': via,
      'trainName': trainName,
      'trainNumber': trainNumber,
      'fare': fare,
      'journeyType': journeyType,
      'status': status,
      'qrToken': qrToken,
      'journeyDate': journeyDate,
      'createdAt': createdAt,
    };
  }

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      ticketId: map['ticketId'] ?? '',
      bookingId: map['bookingId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      passengerName: map['passengerName'] ?? '',
      source: map['source'] ?? '',
      destination: map['destination'] ?? '',
      via: map['via'],
      trainName: map['trainName'] ?? 'Mumbai Local',
      trainNumber: map['trainNumber'] ?? '',
      fare: (map['fare'] ?? 0).toDouble(),
      journeyType: map['journeyType'] ?? 'one_way',
      status: map['status'] ?? 'valid',
      qrToken: map['qrToken'] ?? '',
      journeyDate: map['journeyDate'] != null
          ? (map['journeyDate'] as dynamic).toDate()
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
    );
  }
}