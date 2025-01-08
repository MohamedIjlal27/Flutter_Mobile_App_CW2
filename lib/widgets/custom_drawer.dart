import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_travel/features/auth/screens/login_screen.dart';
import 'package:e_travel/features/bookings/screens/bookings_screen.dart';
import 'package:e_travel/core/config/theme/colors.dart';
import 'package:e_travel/screens/fav_screen.dart';
import 'package:e_travel/screens/profile_screen.dart';
import 'package:e_travel/features/budget/screens/budget_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = userDoc.data() ?? {};
    return {
      'name': data['name'] ?? 'User Name',
      'email': data['email'] ?? 'user@example.com',
      'profileImage': data['profileImage'] ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<Map<String, dynamic>>(
      future: user != null
          ? fetchUserData(user.uid)
          : Future.value({
              'name': 'User Name',
              'email': 'user@example.com',
              'profileImage': '',
            }),
      builder: (context, snapshot) {
        String name = 'User Name';
        String email = 'user@example.com';
        String profileImageUrl = '';

        if (snapshot.hasData) {
          name = snapshot.data!['name'];
          email = snapshot.data!['email'];
          profileImageUrl = snapshot.data!['profileImage'];
        }

        return Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(name),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : null,
                  child: profileImageUrl.isEmpty
                      ? Icon(Icons.person, color: Colors.grey[400], size: 35)
                      : null,
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
                    MaterialPageRoute(
                        builder: (context) => BookingsListScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Budget Tracker'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BudgetScreen()),
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
