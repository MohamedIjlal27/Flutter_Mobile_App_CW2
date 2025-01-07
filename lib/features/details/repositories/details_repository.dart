import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/details_model.dart';
import 'package:e_travel/features/locations/models/location_model.dart';

class DetailsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get location details including rating
  Future<LocationDetails> getLocationDetails(Location location) async {
    try {
      // Get the rating from reviews collection
      final reviewsSnapshot = await _firestore
          .collection('locations')
          .doc(location.name)
          .collection('reviews')
          .get();

      double rating = 0.0;
      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in reviewsSnapshot.docs) {
          totalRating += (doc.data()['rating'] as num).toDouble();
        }
        rating = totalRating / reviewsSnapshot.docs.length;
      }

      return LocationDetails.fromLocation(location, rating: rating);
    } catch (e) {
      throw Exception('Failed to get location details: $e');
    }
  }

  // Update location details
  Future<void> updateLocationDetails(LocationDetails details) async {
    try {
      await _firestore.collection('locations').doc(details.name).update({
        'description': details.description,
        'bestTimeToVisit': details.bestTimeToVisit,
        'category': details.category,
        'address': details.address,
      });
    } catch (e) {
      throw Exception('Failed to update location details: $e');
    }
  }
}
