import 'package:e_travel/models/location_model.dart';
import 'package:e_travel/features/locations/screens/details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Location> favoriteLocations = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteLocations();
  }

  // Load the list of favorite locations from Firebase
  void _loadFavoriteLocations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      List<Location> locations = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        locations.add(Location(
          name: data['name'],
          description:
              'click to view more details', // You can modify this later
          category: 'Category here', // Modify as needed
          imageUrl: data['imageUrl'],
          latitude: 0.0, // Add more data as needed
          longitude: 0.0, // Add more data as needed
          address: 'Address here', // Modify as needed
          rating: 4.5, // Modify as needed
          type: 'Type here', // Modify as needed
          bestTimeToVisit: 'Best time here', // Modify as needed
        ));
      }

      setState(() {
        favoriteLocations = locations;
      });
    }
  }

  // Remove a location from favorites
  void _removeFromFavorites(Location location) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(location.name);

      await docRef.delete();
      _loadFavoriteLocations(); // Reload the list after deletion
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      body: favoriteLocations.isEmpty
          ? const Center(child: Text('No favorites yet!'))
          : ListView.builder(
              itemCount: favoriteLocations.length,
              itemBuilder: (context, index) {
                final location = favoriteLocations[index];

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    leading: Image.network(
                      location.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    title: Text(location.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    subtitle: Text(location.description,
                        style: const TextStyle(fontSize: 16)),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _removeFromFavorites(location);
                      },
                    ),
                    onTap: () {
                      // Navigate to the DetailScreen when a location is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailScreen(location: location),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
