import 'package:e_travel/features/locations/models/location_model.dart';

class LocationDetails {
  final String name;
  final String description;
  final String imageUrl;
  final String bestTimeToVisit;
  final String category;
  final String address;
  final double rating;
  final Location location;

  LocationDetails({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.bestTimeToVisit,
    required this.category,
    required this.address,
    required this.rating,
    required this.location,
  });

  factory LocationDetails.fromLocation(Location location,
      {double rating = 0.0}) {
    return LocationDetails(
      name: location.name,
      description: location.description,
      imageUrl: location.imageUrl,
      bestTimeToVisit: location.bestTimeToVisit,
      category: location.category,
      address: location.address,
      rating: rating,
      location: location,
    );
  }

  LocationDetails copyWith({
    String? name,
    String? description,
    String? imageUrl,
    String? bestTimeToVisit,
    String? category,
    String? address,
    double? rating,
    Location? location,
  }) {
    return LocationDetails(
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      bestTimeToVisit: bestTimeToVisit ?? this.bestTimeToVisit,
      category: category ?? this.category,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      location: location ?? this.location,
    );
  }
}
