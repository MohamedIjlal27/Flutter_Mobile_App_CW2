export 'location_list.dart';

import 'package:e_travel/features/locations/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:e_travel/features/locations/screens/details_screen.dart';

class LocationList extends StatelessWidget {
  final List<Location> locations;
  final double? height;
  final String category;

  const LocationList({
    Key? key,
    required this.locations,
    this.height,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? _getDefaultHeight(),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(location: location),
                ),
              );
            },
            child: _buildLocationCard(location),
          );
        },
      ),
    );
  }

  double _getDefaultHeight() {
    switch (category) {
      case 'Popular':
        return 250;
      case 'Summer':
        return 180;
      case 'Winter':
        return 160;
      default:
        return 200;
    }
  }

  Widget _buildLocationCard(Location location) {
    switch (category) {
      case 'Winter':
        return _buildWinterCard(location);
      case 'Summer':
        return _buildSummerCard(location);
      default:
        return _buildPopularCard(location);
    }
  }

  Widget _buildPopularCard(Location location) {
    return Container(
      width: 200,
      margin: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  location.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildRatingStars(location.rating),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummerCard(Location location) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      margin: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 250,
          height: 180,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  location.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black54,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinterCard(Location location) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  location.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                location.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      stars.add(Icon(
        i < rating ? Icons.star : Icons.star_border,
        color: i < rating ? Colors.amber : Colors.white,
        size: 16,
      ));
    }
    return Row(
      children: stars,
    );
  }
}
