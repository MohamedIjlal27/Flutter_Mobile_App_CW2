import 'package:e_travel/features/locations/models/location_model.dart';
import 'package:e_travel/features/locations/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:e_travel/core/config/theme/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_travel/features/reviews/bloc/review_bloc.dart';
import 'package:e_travel/features/reviews/bloc/review_state.dart';
import 'package:e_travel/features/reviews/bloc/review_event.dart';
import '../widgets/custom_details_button.dart';

class DetailsTabScreen extends StatefulWidget {
  final Location location;
  final VoidCallback onBookNow;

  const DetailsTabScreen({
    Key? key,
    required this.location,
    required this.onBookNow,
  }) : super(key: key);

  @override
  State<DetailsTabScreen> createState() => _DetailsTabScreenState();
}

class _DetailsTabScreenState extends State<DetailsTabScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewBloc>().add(LoadLocationRating(widget.location.name));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _HeaderImage(imageUrl: widget.location.imageUrl),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LocationTitle(title: widget.location.name),
                const SizedBox(height: 8),
                _LocationDescription(description: widget.location.description),
                const SizedBox(height: 16),
                _RatingSection(),
                const SizedBox(height: 16),
                _BestTimeToVisit(bestTime: widget.location.bestTimeToVisit),
                const SizedBox(height: 16),
                _LocationDetailsCard(location: widget.location),
                const SizedBox(height: 16),
                _ActionButtons(
                  location: widget.location,
                  onBookNow: widget.onBookNow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  final String imageUrl;

  const _HeaderImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }
}

class _LocationTitle extends StatelessWidget {
  final String title;

  const _LocationTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _LocationDescription extends StatelessWidget {
  final String description;

  const _LocationDescription({Key? key, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black54,
        height: 1.5,
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Rating: ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        BlocBuilder<ReviewBloc, ReviewState>(
          builder: (context, state) {
            final rating = state is RatingLoaded ? state.rating : 0.0;
            return Row(
              children: [
                RatingBarIndicator(
                  rating: rating,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 30.0,
                ),
                const SizedBox(width: 8),
                Text(
                  '(${rating.toStringAsFixed(1)})',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BestTimeToVisit extends StatelessWidget {
  final String bestTime;

  const _BestTimeToVisit({Key? key, required this.bestTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Best Time to Visit',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          bestTime,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}

class _LocationDetailsCard extends StatelessWidget {
  final Location location;

  const _LocationDetailsCard({Key? key, required this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text('Category: ${location.category}'),
            Text('Address: ${location.address}'),
            BlocBuilder<ReviewBloc, ReviewState>(
              builder: (context, state) {
                final rating = state is RatingLoaded ? state.rating : 0.0;
                return Text('Rating: ${rating.toStringAsFixed(1)}');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Location location;
  final VoidCallback onBookNow;

  const _ActionButtons({
    Key? key,
    required this.location,
    required this.onBookNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomDetailsButton(
          title: 'View On Map',
          backgroundColor: Colors.greenAccent,
          textColor: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapScreen(location: location),
              ),
            );
          },
        ),
        const SizedBox(width: 20),
        CustomDetailsButton(
          title: 'Book Now',
          backgroundColor: Colors.orangeAccent,
          textColor: Colors.white,
          onPressed: onBookNow,
        ),
      ],
    );
  }
}
