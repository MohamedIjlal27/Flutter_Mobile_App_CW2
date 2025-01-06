import 'package:e_travel/features/bookings/screens/booking_sheet.dart';
import 'package:e_travel/features/reviews/widgets/reviews_tab.dart';
import 'package:e_travel/models/location_model.dart';
import 'package:e_travel/core/config/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:e_travel/widgets/details_tab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_travel/features/reviews/bloc/review_bloc.dart';

class DetailScreen extends StatefulWidget {
  final Location location;

  const DetailScreen({Key? key, required this.location}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.location.name)
          .get();
      setState(() {
        isFavorite = doc.exists;
      });
    }
  }

  void _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.location.name);

      if (isFavorite) {
        await docRef.delete();
      } else {
        await docRef.set({
          'name': widget.location.name,
          'imageUrl': widget.location.imageUrl,
        });
      }

      setState(() {
        isFavorite = !isFavorite;
      });
    }
  }

  void _showBookingBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BookingBottomSheet(location: widget.location),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewBloc(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.secondaryColor,
            title: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.location.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Reviews & Rating'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            DetailsTab(
              location: widget.location,
              onBookNow: _showBookingBottomSheet,
            ),
            ReviewsTab(locationId: widget.location.name),
          ],
        ),
      ),
    );
  }
}
