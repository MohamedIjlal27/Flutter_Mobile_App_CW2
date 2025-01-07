import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show TimeOfDay;

enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking {
  final String id;
  final String locationId;
  final String locationName;
  final String locationImageUrl;
  final String userId;
  final DateTime date;
  final TimeOfDay time;
  final int numberOfPeople;
  final BookingStatus status;
  final DateTime createdAt;
  final double totalAmount;

  Booking({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.locationImageUrl,
    required this.userId,
    required this.date,
    required this.time,
    required this.numberOfPeople,
    this.status = BookingStatus.pending,
    DateTime? createdAt,
    required this.totalAmount,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      locationId: map['locationId'] ?? '',
      locationName: map['locationName'] ?? '',
      locationImageUrl: map['locationImageUrl'] ?? '',
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      time: TimeOfDay(
        hour: map['time']['hour'] ?? 0,
        minute: map['time']['minute'] ?? 0,
      ),
      numberOfPeople: map['numberOfPeople'] ?? 0,
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${map['status'] ?? 'pending'}',
        orElse: () => BookingStatus.pending,
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'locationName': locationName,
      'locationImageUrl': locationImageUrl,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'time': {
        'hour': time.hour,
        'minute': time.minute,
      },
      'numberOfPeople': numberOfPeople,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalAmount': totalAmount,
    };
  }

  Booking copyWith({
    String? id,
    String? locationId,
    String? locationName,
    String? locationImageUrl,
    String? userId,
    DateTime? date,
    TimeOfDay? time,
    int? numberOfPeople,
    BookingStatus? status,
    DateTime? createdAt,
    double? totalAmount,
  }) {
    return Booking(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      locationImageUrl: locationImageUrl ?? this.locationImageUrl,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      time: time ?? this.time,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  String get formattedDate => '${date.day}/${date.month}/${date.year}';
  String get formattedTime =>
      '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  bool get isUpcoming => date.isAfter(DateTime.now());
  bool get canCancel =>
      status == BookingStatus.pending || status == BookingStatus.confirmed;
}
