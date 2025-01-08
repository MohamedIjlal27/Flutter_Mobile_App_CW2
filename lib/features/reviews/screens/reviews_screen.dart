import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_travel/features/reviews/bloc/review_bloc.dart';
import 'package:e_travel/features/reviews/widgets/rating_summary.dart';
import 'package:e_travel/features/reviews/widgets/review_list.dart';
import 'package:e_travel/features/reviews/widgets/add_review_sheet.dart';

class ReviewsScreen extends StatefulWidget {
  final String locationId;
  final String locationName;

  const ReviewsScreen({
    Key? key,
    required this.locationId,
    required this.locationName,
  }) : super(key: key);

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewBloc>().add(LoadReviews(widget.locationId));
  }

  void _showAddReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddReviewSheet(
        locationId: widget.locationId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews - ${widget.locationName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RatingSummary(locationId: widget.locationId),
          ),
          Expanded(
            child: ReviewList(locationId: widget.locationId),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReviewSheet,
        child: const Icon(Icons.rate_review),
      ),
    );
  }
}
