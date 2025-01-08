import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/details_model.dart';
import 'package:e_travel/features/locations/models/location_model.dart';

class DetailsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or update a location in Firestore
  Future<void> createLocation(Location location) async {
    try {
      await _firestore.collection('locations').doc(location.name).set({
        'name': location.name,
        'description': location.description,
        'imageUrl': location.imageUrl,
        'bestTimeToVisit': location.bestTimeToVisit,
        'category': location.category,
        'address': location.address,
        'rating': location.rating,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'type': location.type,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating location: $e');
      throw Exception('Failed to create location: $e');
    }
  }

  // Add a review to a location
  Future<void> addReview(
      String locationName, Map<String, dynamic> reviewData) async {
    try {
      final locationRef = _firestore.collection('locations').doc(locationName);

      // First verify if location exists
      final docSnapshot = await locationRef.get();
      if (!docSnapshot.exists) {
        throw Exception(
            'Location does not exist. Please create location first.');
      }

      // Add the review
      await locationRef.collection('reviews').add({
        ...reviewData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update average rating
      final reviewsSnapshot = await locationRef.collection('reviews').get();
      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in reviewsSnapshot.docs) {
          totalRating += (doc.data()['rating'] as num).toDouble();
        }
        double averageRating = totalRating / reviewsSnapshot.docs.length;

        await locationRef.update({'rating': averageRating});
      }
    } catch (e) {
      print('Error adding review: $e');
      throw Exception('Failed to add review: $e');
    }
  }

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

  // Create all locations in Firestore
  Future<void> createAllLocations(List<Location> locations) async {
    try {
      final batch = _firestore.batch();

      for (var location in locations) {
        final docRef = _firestore.collection('locations').doc(location.name);
        batch.set(
            docRef,
            {
              'name': location.name,
              'description': location.description,
              'imageUrl': location.imageUrl,
              'bestTimeToVisit': location.bestTimeToVisit,
              'category': location.category,
              'address': location.address,
              'rating': location.rating,
              'latitude': location.latitude,
              'longitude': location.longitude,
              'type': location.type,
            },
            SetOptions(merge: true));
      }

      await batch.commit();
      print('Successfully added all locations to Firestore');
    } catch (e) {
      print('Error creating locations: $e');
      throw Exception('Failed to create locations: $e');
    }
  }
}
