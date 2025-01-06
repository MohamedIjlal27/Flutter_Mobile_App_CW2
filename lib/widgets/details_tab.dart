import 'package:e_travel/features/locations/models/location_model.dart';
import 'package:e_travel/features/locations/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:e_travel/widgets/custom_details_screen_button.dart';
import 'package:e_travel/core/config/theme/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_travel/features/reviews/bloc/review_bloc.dart';
import 'package:e_travel/features/reviews/bloc/review_state.dart';
import 'package:e_travel/features/reviews/bloc/review_event.dart';

class DetailsTab extends StatefulWidget {
  final Location location;
  final VoidCallback onBookNow;

  const DetailsTab({
    Key? key,
    required this.location,
    required this.onBookNow,
  }) : super(key: key);

  @override
  State<DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
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
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.location.imageUrl),
                fit: BoxFit.cover,
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.location.name,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.location.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
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
                        final rating =
                            state is RatingLoaded ? state.rating : 0.0;
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
                ),
                const SizedBox(height: 16),
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
                  widget.location.bestTimeToVisit,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Card(
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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Text('Category: ${widget.location.category}'),
                        Text('Address: ${widget.location.address}'),
                        BlocBuilder<ReviewBloc, ReviewState>(
                          builder: (context, state) {
                            final rating =
                                state is RatingLoaded ? state.rating : 0.0;
                            return Text('Rating: ${rating.toStringAsFixed(1)}');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      title: 'View On Map',
                      backgroundColor: Colors.greenAccent,
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MapScreen(location: widget.location),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    CustomButton(
                      title: 'Book Now',
                      backgroundColor: Colors.orangeAccent,
                      textColor: Colors.white,
                      onPressed: widget.onBookNow,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
