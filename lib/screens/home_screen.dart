import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_travel/core/constants/locations.dart';
import 'package:e_travel/models/location_model.dart';
import 'package:e_travel/screens/details_screen.dart';
import 'package:e_travel/widgets/custom_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _profileImageUrl; // Declare a variable to hold the profile image URL

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _filteredLocations = locations; // Initialize with all locations

    // ... other initialization
  }

  Future<void> _fetchUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _profileImageUrl = userDoc[
            'profileImage']; // Assuming 'profileImage' is the key in your Firestore document
      });
    }
  }

  String _searchTerm = '';
  String? _selectedCategory; // Added variable for selected category
  List<Location> _filteredLocations = [];

  void _onSearchChanged(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm;
      _filterLocations();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchTerm = '';
      _selectedCategory = null; // Clear selected category
      _filteredLocations = locations; // Display all locations again
    });
  }

  void _applyFilter() {
    _showFilterDialog(); // Show filter dialog
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('All'),
                onTap: () {
                  setState(() {
                    _selectedCategory = null; // Reset category filter
                    Navigator.of(context).pop();
                    _filterLocations();
                  });
                },
              ),
              ListTile(
                title: Text('Popular'),
                onTap: () {
                  setState(() {
                    _selectedCategory = 'Popular'; // Set to Popular
                    Navigator.of(context).pop();
                    _filterLocations();
                  });
                },
              ),
              ListTile(
                title: Text('Summer'),
                onTap: () {
                  setState(() {
                    _selectedCategory = 'Summer'; // Set to Summer
                    Navigator.of(context).pop();
                    _filterLocations();
                  });
                },
              ),
              ListTile(
                title: Text('Winter'),
                onTap: () {
                  setState(() {
                    _selectedCategory = 'Winter'; // Set to Winter
                    Navigator.of(context).pop();
                    _filterLocations();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _filterLocations() {
    setState(() {
      _filteredLocations = locations.where((location) {
        final matchesSearchTerm =
            location.name.toLowerCase().contains(_searchTerm.toLowerCase());
        final matchesCategory =
            _selectedCategory == null || location.category == _selectedCategory;
        return matchesSearchTerm && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: AppBar(
          flexibleSpace: Image.network(
            'https://khaleejmag.com/wp-content/uploads/2022/05/Traveling-the-World.jpg',
            fit: BoxFit.cover,
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: Text(
              'Discover Asia',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 25,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!) // Use the fetched URL
                    : const NetworkImage(
                        'https://img.freepik.com/free-photo/young-male-posing-isolated-against-blank-studio-wall_273609-12356.jpg'), // Default image if URL is not available
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Search Locations...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon: _searchTerm.isNotEmpty
                          ? IconButton(
                              icon:
                                  const Icon(Icons.clear, color: Colors.black),
                              onPressed: _clearSearch,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(
                    width: 8), // Spacing between TextField and button
                ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orange, // Set text color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16), // Rounded corners
                    ),
                    shadowColor: Colors.black.withOpacity(0.25), // Shadow color
                    elevation: 6, // Add elevation
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0), // Padding for larger click target
                    child: Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 16, // Slightly larger font size
                        fontWeight: FontWeight.bold, // Bold font weight
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'Popular', backgroundColor: Colors.orange),
          LocationList(
            _filteredLocations
                .where((loc) => loc.category == 'Popular')
                .toList(),
            size: 250,
          ),
          const SectionTitle(title: 'Summer', backgroundColor: Colors.blue),
          SummerLocationList(
            _filteredLocations
                .where((loc) => loc.category == 'Summer')
                .toList(),
          ),
          const SectionTitle(title: 'Winter', backgroundColor: Colors.teal),
          WinterLocationList(
            _filteredLocations
                .where((loc) => loc.category == 'Winter')
                .toList(),
          ),
        ],
      ),
    );
  }
}

// Other parts of the code remain unchanged.
// SectionTitle, LocationList, SummerLocationList, and WinterLocationList remain the same.

// Custom Drawer

class SectionTitle extends StatelessWidget {
  final String title;
  final Color backgroundColor;

  const SectionTitle({
    Key? key,
    required this.title,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
            16), // Increased rounding for more modern look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12), // Slightly lighter shadow
            spreadRadius: 2, // Expanded shadow for more depth
            blurRadius: 8, // Slightly blurrier shadow
            offset: const Offset(0, 4), // Shadow position adjustment
          ),
        ],
      ),
      padding: const EdgeInsets.all(
          20.0), // Increased padding for more spacious feel
      margin: const EdgeInsets.symmetric(
          vertical: 12.0, horizontal: 16.0), // Adjusted margin for balance
      child: Text(
        title,
        style: TextStyle(
          fontSize: 28, // Slightly larger font for emphasis
          fontWeight:
              FontWeight.w700, // Stronger font weight for more visibility
          color: Colors.white,
          letterSpacing:
              1.5, // Increased letter spacing for clearer readability
          shadows: [
            Shadow(
              blurRadius: 2.0,
              color: Colors.black
                  .withOpacity(0.2), // Soft shadow for the text for contrast
              offset: Offset(1, 1), // Offset shadow for text clarity
            ),
          ],
        ),
      ),
    );
  }
}

class LocationList extends StatelessWidget {
  final List<Location> locations;
  final double size;

  const LocationList(this.locations, {Key? key, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size, // Make sure the size is passed correctly
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(location: location),
                ),
              );
            },
            child: Container(
              width: 200, // You can adjust this width depending on your design
              margin: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          location.imageUrl,
                          fit: BoxFit.cover,
                          width: double
                              .infinity, // Ensure it stretches across the width
                          height: double
                              .infinity, // Ensure it stretches across the height
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                location.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                location.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildRatingStars(location.rating),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      stars.add(Icon(
        i < rating ? Icons.star : Icons.star_border,
        color: i < rating ? Colors.amber : Colors.white,
        size: 16,
      ));
    }
    return Row(
      children: stars,
    );
  }
}

// Summer Locations List Widget (Horizontal List View)
class SummerLocationList extends StatelessWidget {
  final List<Location> locations;

  const SummerLocationList(this.locations, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // Set a height for the ListView
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(location: location),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              margin: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 250, // Explicit width for the container
                  height: 180, // Explicit height for the container
                  child: Stack(
                    children: [
                      // Ensure the image is constrained
                      Positioned.fill(
                        child: Image.network(
                          location.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Gradient overlay to make text more readable
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      // Content on top of the image
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Location name with enhanced styling
                            Text(
                              location.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5.0,
                                    color: Colors.black54,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Location description with a smaller font
                            Text(
                              location.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class WinterLocationList extends StatelessWidget {
  final List<Location> locations;

  const WinterLocationList(this.locations, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(location: location),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Circular Avatar with Shadow and Border
                  ClipOval(
                    child: Container(
                      width: 120, // Size of the circle
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          location.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Overlay Text with Location Name
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        location.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
