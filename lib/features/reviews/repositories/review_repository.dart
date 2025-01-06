import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_travel/features/reviews/models/review_model.dart';
import 'package:uuid/uuid.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ReviewRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<List<Review>> getLocationReviews(String locationId) async {
    try {
      final snapshot = await _firestore
          .collection('locations')
          .doc(locationId)
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Review.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to load reviews: ${e.toString()}');
    }
  }

  Future<Review> addReview({
    required String locationId,
    required String comment,
    required double rating,
    List<String> photoUrls = const [],
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      final reviewId = const Uuid().v4();
      final review = Review(
        id: reviewId,
        locationId: locationId,
        userId: user.uid,
        userName: userData['name'] ?? user.displayName ?? 'Anonymous',
        userImage: userData['profileImage'],
        comment: comment,
        rating: rating,
        timestamp: DateTime.now(),
        photoUrls: photoUrls,
      );

      // Store the review
      await _firestore.collection('reviews').doc(reviewId).set(review.toMap());

      // Add to location's reviews subcollection
      await _firestore
          .collection('locations')
          .doc(locationId)
          .collection('reviews')
          .doc(reviewId)
          .set(review.toMap());

      // Update location's average rating
      await _updateLocationRating(locationId, rating);

      return review;
    } catch (e) {
      throw Exception('Failed to add review: ${e.toString()}');
    }
  }

  Future<void> updateReview({
    required String reviewId,
    required String locationId,
    String? comment,
    double? rating,
    List<String>? photoUrls,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final reviewDoc =
          await _firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) throw Exception('Review not found');

      final reviewData = reviewDoc.data()!;
      if (reviewData['userId'] != user.uid) {
        throw Exception('Not authorized to update this review');
      }

      final updates = <String, dynamic>{};
      if (comment != null) updates['comment'] = comment;
      if (rating != null) updates['rating'] = rating;
      if (photoUrls != null) updates['photoUrls'] = photoUrls;

      await _firestore.collection('reviews').doc(reviewId).update(updates);
      await _firestore
          .collection('locations')
          .doc(locationId)
          .collection('reviews')
          .doc(reviewId)
          .update(updates);

      if (rating != null) {
        await _updateLocationRating(locationId, rating);
      }
    } catch (e) {
      throw Exception('Failed to update review: ${e.toString()}');
    }
  }

  Future<void> deleteReview(String reviewId, String locationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final reviewDoc =
          await _firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) throw Exception('Review not found');

      final reviewData = reviewDoc.data()!;
      if (reviewData['userId'] != user.uid) {
        throw Exception('Not authorized to delete this review');
      }

      await _firestore.collection('reviews').doc(reviewId).delete();
      await _firestore
          .collection('locations')
          .doc(locationId)
          .collection('reviews')
          .doc(reviewId)
          .delete();

      await _updateLocationRating(locationId, null);
    } catch (e) {
      throw Exception('Failed to delete review: ${e.toString()}');
    }
  }

  Future<double> getLocationAverageRating(String locationId) async {
    try {
      final snapshot = await _firestore
          .collection('locations')
          .doc(locationId)
          .collection('reviews')
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      final totalRating = snapshot.docs
          .fold<double>(0.0, (sum, doc) => sum + (doc.data()['rating'] ?? 0.0));

      return totalRating / snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get average rating: ${e.toString()}');
    }
  }

  Future<void> _updateLocationRating(
      String locationId, double? newRating) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final locationRef = _firestore.collection('locations').doc(locationId);
        final reviews = await _firestore
            .collection('locations')
            .doc(locationId)
            .collection('reviews')
            .get();

        double totalRating = 0;
        for (var doc in reviews.docs) {
          totalRating += doc.data()['rating'] ?? 0.0;
        }

        final newAvgRating =
            reviews.docs.isEmpty ? 0.0 : totalRating / reviews.docs.length;

        transaction.update(locationRef, {
          'rating': newAvgRating,
          'numReviews': reviews.docs.length,
          'lastReviewAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      throw Exception('Failed to update location rating: ${e.toString()}');
    }
  }
}
