import 'package:e_travel/constants/app_constants.dart';
import 'package:e_travel/constants/custom_fonts.dart';
import 'package:e_travel/screens/auth/for_get_password.dart';
import 'package:e_travel/screens/auth/signup_screen.dart';
import 'package:e_travel/screens/home_screen.dart';
import 'package:e_travel/utils/colors.dart';
import 'package:e_travel/widgets/custom_buttons.dart';
import 'package:e_travel/widgets/custom_textform_feild.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); 
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        Get.offAll(() => const HomeScreen());
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0), // Reduced padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  applogo,
                  const SizedBox(height: 10),
                  Text(
                    appname,
                    style: CustomFonts.titleFont(fontSize: 28, color: Colors.white), // Reduced font size
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 5), 
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextFormField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Enter your email',
                            icon: Icons.email,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          CustomTextFormField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter your password',
                            icon: Icons.lock,
                            isPassword: _obscureText,
                            toggleVisibility: _togglePasswordVisibility,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: 'Login',
                            onPressed: _login,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Get.to(() => const ForgotPasswordScreen());
                    },
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.roboto(fontSize: 12, color: Colors.white), // Reduced font size
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: GoogleFonts.roboto(fontSize: 12, color: Colors.white), // Reduced font size
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(() => const SignUpScreen());
                        },
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.roboto(fontSize: 12, color: AppColors.textColor), // Reduced font size
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}