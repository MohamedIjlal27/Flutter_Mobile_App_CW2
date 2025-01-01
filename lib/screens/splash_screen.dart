import 'package:e_travel/constants/app_constants.dart';
import 'package:e_travel/screens/auth/login_screen.dart';
import 'package:e_travel/screens/home_screen.dart';
import 'package:e_travel/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/custom_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      _navigateUser();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      // Location permission granted
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is required for this app.'),
        ),
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _navigateUser() async {
    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Navigate to Home Screen if logged in
      Get.off(() =>  HomeScreen());
    } else {
      // Navigate to Login Screen if not logged in
      Get.off(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.primaryGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                applogo,
                const SizedBox(height: 20),
                Text(
                  appname,
                  style: CustomFonts.titleFont(
                    fontSize: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  splashtagline,
                  style: CustomFonts.subtitleFont(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 50),
                const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
