class Review {
  final String id;
  final String userId;
  final String userName;
  final String locationId;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final List<String> photoUrls;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.locationId,
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.photoUrls = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'locationId': locationId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
      'photoUrls': photoUrls,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      locationId: map['locationId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
    );
  }
}
