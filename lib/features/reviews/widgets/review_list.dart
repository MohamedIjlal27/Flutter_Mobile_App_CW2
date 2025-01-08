import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_travel/features/reviews/bloc/review_bloc.dart';
import 'package:e_travel/features/reviews/models/review_model.dart';
import 'package:e_travel/features/reviews/widgets/review_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewList extends StatelessWidget {
  final String locationId;

  const ReviewList({
    Key? key,
    required this.locationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        if (state is ReviewLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReviewError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is ReviewLoaded) {
          if (state.reviews.isEmpty) {
            return const Center(
              child: Text(
                'No reviews yet. Be the first to review!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.reviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final review = state.reviews[index];
              final currentUser = FirebaseAuth.instance.currentUser;
              final isCurrentUser = currentUser?.uid == review.userId;

              return ReviewCard(
                review: review,
                isCurrentUser: isCurrentUser,
                onEdit: isCurrentUser
                    ? () => _showEditReviewDialog(context, review)
                    : null,
                onDelete: isCurrentUser
                    ? () => _showDeleteConfirmation(context, review)
                    : null,
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showEditReviewDialog(BuildContext context, Review review) {
    final reviewBloc = context.read<ReviewBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: reviewBloc,
        child: _EditReviewDialog(
          review: review,
          onSubmit: (comment, rating) {
            final updatedReview = Review(
              id: review.id,
              locationName: locationId,
              userId: review.userId,
              userName: review.userName,
              comment: comment,
              rating: rating,
              createdAt: DateTime.now(),
            );
            reviewBloc.add(AddNewReview(updatedReview));
            Navigator.pop(dialogContext);
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ReviewBloc>().add(
                    DeleteExistingReview(locationId, review.id),
                  );
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditReviewDialog extends StatefulWidget {
  final Review review;
  final Function(String comment, double rating) onSubmit;

  const _EditReviewDialog({
    required this.review,
    required this.onSubmit,
  });

  @override
  _EditReviewDialogState createState() => _EditReviewDialogState();
}

class _EditReviewDialogState extends State<_EditReviewDialog> {
  late TextEditingController _commentController;
  late double _rating;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.review.comment);
    _rating = widget.review.rating;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Review'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Comment',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Rating: '),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 24,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSubmit(_commentController.text, _rating);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
