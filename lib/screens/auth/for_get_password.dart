import 'package:e_travel/constants/app_constants.dart';
import 'package:e_travel/constants/custom_fonts.dart';
import 'package:e_travel/utils/colors.dart';
import 'package:e_travel/widgets/custom_buttons.dart';
import 'package:e_travel/widgets/custom_textform_feild.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password reset link sent to your email")));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
         gradient: AppGradients.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // App Logo
                applogo,
                const SizedBox(height: 20),
                // App Title
                Text(
                  appname,
                  style: CustomFonts.titleFont(
                    fontSize: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                // Forgot Password Form
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      // Email Text Field
                      CustomTextFormField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 25),
                      // Reset Password Button
                      CustomButton(
                        text: 'Reset Password',
                        onPressed: () {
                          if (_emailController.text.trim().isNotEmpty) {
                            _resetPassword();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email')));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Go back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back(); // Navigate back to Login Screen
                      },
                      child: Text(
                        'Login',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 320),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
