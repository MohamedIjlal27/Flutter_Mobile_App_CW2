import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String location;
  final String userId;
  final String date;
  final String time;
  final String people;
  final String status;

  Booking({
    required this.id,
    required this.location,
    required this.userId,
    required this.date,
    required this.time,
    required this.people,
    required this.status,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      location: map['location'] ?? '',
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      people: map['people'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'userId': userId,
      'date': date,
      'time': time,
      'people': people,
      'status': status,
    };
  }
}
