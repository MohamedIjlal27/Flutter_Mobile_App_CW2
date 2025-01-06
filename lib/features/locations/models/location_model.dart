import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String address;
  final double rating;
  final String type;
  final String bestTimeToVisit;

  const Location({
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.rating,
    required this.type,
    required this.bestTimeToVisit,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      imageUrl: map['imageUrl'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String,
      rating: (map['rating'] as num).toDouble(),
      type: map['type'] as String,
      bestTimeToVisit: map['bestTimeToVisit'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'rating': rating,
      'type': type,
      'bestTimeToVisit': bestTimeToVisit,
    };
  }

  @override
  List<Object> get props => [
        name,
        description,
        category,
        imageUrl,
        latitude,
        longitude,
        address,
        rating,
        type,
        bestTimeToVisit,
      ];
}
