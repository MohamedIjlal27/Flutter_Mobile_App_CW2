import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/review_model.dart';
import '../repositories/review_repository.dart';

// Events
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object> get props => [];
}

class LoadReviews extends ReviewEvent {
  final String locationName;

  const LoadReviews(this.locationName);

  @override
  List<Object> get props => [locationName];
}

class AddNewReview extends ReviewEvent {
  final Review review;

  const AddNewReview(this.review);

  @override
  List<Object> get props => [review];
}

class DeleteExistingReview extends ReviewEvent {
  final String locationName;
  final String reviewId;

  const DeleteExistingReview(this.locationName, this.reviewId);

  @override
  List<Object> get props => [locationName, reviewId];
}

// States
abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final List<Review> reviews;

  const ReviewLoaded(this.reviews);

  @override
  List<Object> get props => [reviews];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository _reviewRepository;
  StreamSubscription? _reviewsSubscription;

  ReviewBloc({required ReviewRepository reviewRepository})
      : _reviewRepository = reviewRepository,
        super(ReviewInitial()) {
    on<LoadReviews>(_onLoadReviews);
    on<AddNewReview>(_onAddNewReview);
    on<DeleteExistingReview>(_onDeleteReview);
    on<UpdateReviews>(_onUpdateReviews);
  }

  void _onLoadReviews(LoadReviews event, Emitter<ReviewState> emit) {
    emit(ReviewLoading());
    _reviewsSubscription?.cancel();
    _reviewsSubscription =
        _reviewRepository.getLocationReviews(event.locationName).listen(
              (reviews) => add(UpdateReviews(reviews)),
              onError: (error) => emit(ReviewError(error.toString())),
            );
  }

  void _onUpdateReviews(UpdateReviews event, Emitter<ReviewState> emit) {
    emit(ReviewLoaded(event.reviews));
  }

  Future<void> _onAddNewReview(
      AddNewReview event, Emitter<ReviewState> emit) async {
    try {
      await _reviewRepository.addReview(event.review);
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  Future<void> _onDeleteReview(
      DeleteExistingReview event, Emitter<ReviewState> emit) async {
    try {
      await _reviewRepository.deleteReview(event.locationName, event.reviewId);
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _reviewsSubscription?.cancel();
    return super.close();
  }
}

// Additional event for stream updates
class UpdateReviews extends ReviewEvent {
  final List<Review> reviews;

  const UpdateReviews(this.reviews);

  @override
  List<Object> get props => [reviews];
}
