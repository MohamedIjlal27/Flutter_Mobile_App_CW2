import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String locationName;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String comment;
  final double rating;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.locationName,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      locationName: map['locationName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfileImage: map['userProfileImage'],
      comment: map['comment'] ?? '',
      rating: (map['rating'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locationName': locationName,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'comment': comment,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
