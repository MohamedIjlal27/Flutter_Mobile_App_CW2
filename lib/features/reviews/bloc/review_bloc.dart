import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_travel/features/reviews/bloc/review_event.dart';
import 'package:e_travel/features/reviews/bloc/review_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_travel/features/reviews/models/review_model.dart';
import 'package:uuid/uuid.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  ReviewBloc() : super(ReviewInitial()) {
    on<LoadLocationReviews>(_onLoadLocationReviews);
    on<LoadLocationRating>(_onLoadLocationRating);
    on<AddReview>(_onAddReview);
    on<UpdateReview>(_onUpdateReview);
    on<DeleteReview>(_onDeleteReview);
  }

  Future<void> _onLoadLocationReviews(
    LoadLocationReviews event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      final snapshot = await _firestore
          .collection('locations')
          .doc(event.locationId)
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        emit(const ReviewsLoaded(reviews: []));
        return;
      }

      final reviews = snapshot.docs
          .map((doc) => Review.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      emit(ReviewsLoaded(reviews: reviews));
    } catch (e) {
      emit(ReviewError(message: e.toString()));
    }
  }

  Future<void> _onAddReview(
    AddReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const ReviewError(message: 'User not authenticated'));
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      final reviewId = const Uuid().v4();
      final review = Review(
        id: reviewId,
        userId: user.uid,
        userName: userData?['name'] ?? user.displayName ?? 'Anonymous',
        locationId: event.locationId,
        rating: event.rating,
        comment: event.comment,
        timestamp: DateTime.now(),
        photoUrls: event.photoUrls,
        userImage: userData?['profileImage'],
      );

      await _firestore
          .collection('locations')
          .doc(event.locationId)
          .collection('reviews')
          .doc(reviewId)
          .set(review.toMap());

      await _updateLocationRating(event.locationId);

      add(LoadLocationReviews(event.locationId));
      add(LoadLocationRating(event.locationId));
    } catch (e) {
      emit(ReviewError(message: e.toString()));
    }
  }

  Future<void> _onUpdateReview(
    UpdateReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      final updates = <String, dynamic>{};
      if (event.comment != null) updates['comment'] = event.comment;
      if (event.rating != null) updates['rating'] = event.rating;
      if (event.photoUrls != null) updates['photoUrls'] = event.photoUrls;

      await _firestore
          .collection('locations')
          .doc(event.locationId)
          .collection('reviews')
          .doc(event.reviewId)
          .update(updates);

      await _updateLocationRating(event.locationId);

      add(LoadLocationReviews(event.locationId));
      add(LoadLocationRating(event.locationId));
    } catch (e) {
      emit(ReviewError(message: e.toString()));
    }
  }

  Future<void> _onDeleteReview(
    DeleteReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      await _firestore
          .collection('locations')
          .doc(event.locationId)
          .collection('reviews')
          .doc(event.reviewId)
          .delete();

      await _updateLocationRating(event.locationId);

      add(LoadLocationReviews(event.locationId));
      add(LoadLocationRating(event.locationId));
    } catch (e) {
      emit(ReviewError(message: e.toString()));
    }
  }

  Future<void> _onLoadLocationRating(
    LoadLocationRating event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      final doc =
          await _firestore.collection('locations').doc(event.locationId).get();
      final rating = doc.data()?['rating'] ?? 0.0;
      final numReviews = doc.data()?['numReviews'] ?? 0;

      emit(RatingLoaded(rating: rating, numReviews: numReviews));
    } catch (e) {
      emit(ReviewError(message: e.toString()));
    }
  }

  Future<void> _updateLocationRating(String locationId) async {
    final snapshot = await _firestore
        .collection('locations')
        .doc(locationId)
        .collection('reviews')
        .get();

    double totalRating = 0;
    final numReviews = snapshot.docs.length;

    for (var doc in snapshot.docs) {
      totalRating += (doc.data()['rating'] as num).toDouble();
    }

    final avgRating = numReviews > 0 ? totalRating / numReviews : 0.0;

    await _firestore.collection('locations').doc(locationId).update({
      'rating': avgRating,
      'numReviews': numReviews,
      'lastReviewAt': FieldValue.serverTimestamp(),
    });
  }
}
