import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a review
  Future<void> addReview(Review review) async {
    try {
      final locationRef =
          _firestore.collection('locations').doc(review.locationName);

      // First verify if location exists
      final docSnapshot = await locationRef.get();
      if (!docSnapshot.exists) {
        throw Exception('Location does not exist');
      }

      // Get latest user data
      final userDoc =
          await _firestore.collection('users').doc(review.userId).get();
      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      final userData = userDoc.data()!;

      // Add the review with latest user data
      await locationRef.collection('reviews').add({
        ...review.toMap(),
        'userName': userData['name'] ?? 'Anonymous',
        'userProfileImage': userData['profileImage'],
      });

      // Update average rating
      await _updateLocationRating(review.locationName);
    } catch (e) {
      print('Error adding review: $e');
      throw Exception('Failed to add review: $e');
    }
  }

  // Get real-time stream of reviews for a location
  Stream<List<Review>> getLocationReviews(String locationName) {
    return _firestore
        .collection('locations')
        .doc(locationName)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Review.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Update location's average rating
  Future<void> _updateLocationRating(String locationName) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection('locations')
          .doc(locationName)
          .collection('reviews')
          .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in reviewsSnapshot.docs) {
          totalRating += (doc.data()['rating'] as num).toDouble();
        }
        double averageRating = totalRating / reviewsSnapshot.docs.length;

        await _firestore
            .collection('locations')
            .doc(locationName)
            .update({'rating': averageRating});
      }
    } catch (e) {
      print('Error updating location rating: $e');
    }
  }

  // Delete a review
  Future<void> deleteReview(String locationName, String reviewId) async {
    try {
      await _firestore
          .collection('locations')
          .doc(locationName)
          .collection('reviews')
          .doc(reviewId)
          .delete();

      // Update the average rating after deletion
      await _updateLocationRating(locationName);
    } catch (e) {
      print('Error deleting review: $e');
      throw Exception('Failed to delete review: $e');
    }
  }

  // Update user's reviews when profile changes
  Future<void> updateUserReviews(
      String userId, Map<String, dynamic> userData) async {
    try {
      // First get all locations
      final locationsSnapshot = await _firestore.collection('locations').get();

      // Use batch write for better performance
      final batch = _firestore.batch();

      // For each location, check for reviews by this user
      for (var locationDoc in locationsSnapshot.docs) {
        final reviewsSnapshot = await locationDoc.reference
            .collection('reviews')
            .where('userId', isEqualTo: userId)
            .get();

        // Update each review found
        for (var reviewDoc in reviewsSnapshot.docs) {
          batch.update(reviewDoc.reference, {
            'userName': userData['name'] ?? 'Anonymous',
            'userProfileImage': userData['profileImage'],
          });
        }
      }

      // Commit all updates
      await batch.commit();
    } catch (e) {
      print('Error updating user reviews: $e');
      throw Exception('Failed to update user reviews: $e');
    }
  }
}
