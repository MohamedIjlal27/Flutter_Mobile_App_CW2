import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object> get props => [];
}

class LoadLocationReviews extends ReviewEvent {
  final String locationId;

  const LoadLocationReviews(this.locationId);

  @override
  List<Object> get props => [locationId];
}

class AddReview extends ReviewEvent {
  final String locationId;
  final String comment;
  final double rating;
  final List<String> photoUrls;

  AddReview({
    required this.locationId,
    required this.comment,
    required this.rating,
    this.photoUrls = const [],
  });
}

class UpdateReview extends ReviewEvent {
  final String reviewId;
  final String locationId;
  final String? comment;
  final double? rating;
  final List<String>? photoUrls;

  UpdateReview({
    required this.reviewId,
    required this.locationId,
    this.comment,
    this.rating,
    this.photoUrls,
  });
}

class DeleteReview extends ReviewEvent {
  final String reviewId;
  final String locationId;

  DeleteReview({
    required this.reviewId,
    required this.locationId,
  });
}

class LoadLocationRating extends ReviewEvent {
  final String locationId;

  const LoadLocationRating(this.locationId);

  @override
  List<Object> get props => [locationId];
}
