import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_travel/features/reviews/bloc/review_bloc.dart';
import 'package:e_travel/features/reviews/widgets/review_list.dart';
import 'package:e_travel/features/reviews/widgets/add_review_sheet.dart';

class ReviewsTab extends StatefulWidget {
  final String locationId;

  const ReviewsTab({
    Key? key,
    required this.locationId,
  }) : super(key: key);

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewBloc>().add(LoadReviews(widget.locationId));
  }

  void _showAddReviewSheet() {
    final reviewBloc = context.read<ReviewBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: reviewBloc,
        child: AddReviewSheet(
          locationId: widget.locationId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewBloc = context.read<ReviewBloc>();
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: BlocProvider.value(
                value: reviewBloc,
                child: ReviewList(locationId: widget.locationId),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _showAddReviewSheet,
            child: const Icon(Icons.rate_review),
          ),
        ),
      ],
    );
  }
}
