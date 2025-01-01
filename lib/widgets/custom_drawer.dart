import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_travel/screens/auth/login_screen.dart';
import 'package:e_travel/screens/bookings_screen.dart';
import 'package:e_travel/screens/fav_screen.dart';
import 'package:e_travel/screens/profile_screen.dart';
import 'package:e_travel/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  Future<String> fetchProfileImage(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()?['profileImage'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<String>(
      future: user != null ? fetchProfileImage(user.uid) : Future.value(''),
      builder: (context, snapshot) {
        String profileImageUrl = '';

        if (snapshot.hasData) {
          profileImageUrl = snapshot.data!;
        }

        return Drawer(
          child: ListView(
            children: <Widget>[
              // Drawer Header with user profile
              UserAccountsDrawerHeader(
                accountName: Text(user?.displayName ?? 'User Name'),
                accountEmail: Text(user?.email ?? 'user@example.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : const NetworkImage(
                          'https://img.freepik.com/free-photo/young-male-posing-isolated-against-blank-studio-wall_273609-12356.jpg',
                        ),
                ),
                decoration: const BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                ),
              ),

              // Navigation Items
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Get.back(); // Navigate to Home screen
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Get.to(() => ProfileScreen());
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favorites'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritesScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.book_online),
                title: const Text('My Bookings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookingsListScreen()),
                  );
                },
              ),
              // Logout Option
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Get.to(() => LoginScreen());
                },
              ),
            ],
          ),
        );
      },
    );
  }
}