import 'package:equatable/equatable.dart';
import 'package:e_travel/features/reviews/models/review_model.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewsLoaded extends ReviewState {
  final List<Review> reviews;

  const ReviewsLoaded({required this.reviews});

  @override
  List<Object> get props => [reviews];
}

class RatingLoaded extends ReviewState {
  final double rating;
  final int numReviews;

  const RatingLoaded({required this.rating, required this.numReviews});

  @override
  List<Object> get props => [rating, numReviews];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError({required this.message});

  @override
  List<Object> get props => [message];
}
