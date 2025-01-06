import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Review extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String locationId;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final List<String> photoUrls;
  final String? userImage;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.locationId,
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.photoUrls = const [],
    this.userImage,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      locationId: map['locationId'] as String,
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String,
      timestamp: map['timestamp'] is String
          ? DateTime.parse(map['timestamp'])
          : (map['timestamp'] as Timestamp).toDate(),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      userImage: map['userImage'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'locationId': locationId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
      'photoUrls': photoUrls,
      'userImage': userImage,
    };
  }

  @override
  List<Object> get props => [
        id,
        userId,
        userName,
        locationId,
        rating,
        comment,
        timestamp,
        photoUrls,
        if (userImage != null) userImage!,
      ];
}
