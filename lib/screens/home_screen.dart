import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_travel/core/constants/locations.dart';
import 'package:e_travel/features/locations/models/location_model.dart';
import 'package:e_travel/widgets/custom_drawer.dart';
import 'package:e_travel/widgets/section_title.dart';
import 'package:e_travel/widgets/location_list.dart';
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
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _filteredLocations = locations;
  }

  Future<void> _fetchUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _profileImageUrl = data['profileImage'] as String?;
          });
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        _profileImageUrl = null;
      });
    }
  }

  String _searchTerm = '';
  String? _selectedCategory;
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
      _selectedCategory = null;
      _filteredLocations = locations;
    });
  }

  void _applyFilter() {
    _showFilterDialog();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All'),
                onTap: () {
                  setState(() {
                    _selectedCategory = null;
                    Navigator.of(context).pop();
                    _filterLocations();
                  });
                },
              ),
              ListTile(
                title: const Text('Popular'),
                onTap: () {
                  setState(() {
                    _selectedCategory = 'Popular';
                    Navigator.of(context).pop();
                    _filterLocations();
                  });
                },
              ),
              ListTile(
                title: const Text('Summer'),
                onTap: () {
                  setState(() {
                    _selectedCategory = 'Summer';
                    Navigator.of(context).pop();
                    _filterLocations();
                  });
                },
              ),
              ListTile(
                title: const Text('Winter'),
                onTap: () {
                  setState(() {
                    _selectedCategory = 'Winter';
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
      _filteredLocations = locations.where((Location location) {
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
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                  child: _profileImageUrl == null || _profileImageUrl!.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
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
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: Colors.black.withOpacity(0.25),
                    elevation: 6,
                  ),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    child: Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SectionTitle(title: 'Popular', backgroundColor: Colors.orange),
          LocationList(
            locations: _filteredLocations
                .where((loc) => loc.category == 'Popular')
                .toList(),
            category: 'Popular',
          ),
          const SectionTitle(title: 'Summer', backgroundColor: Colors.blue),
          LocationList(
            locations: _filteredLocations
                .where((loc) => loc.category == 'Summer')
                .toList(),
            category: 'Summer',
          ),
          const SectionTitle(title: 'Winter', backgroundColor: Colors.teal),
          LocationList(
            locations: _filteredLocations
                .where((loc) => loc.category == 'Winter')
                .toList(),
            category: 'Winter',
          ),
        ],
      ),
    );
  }
}
