import 'package:flutter/material.dart';

// Custom TextFormField widget with improved design
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final Function()? toggleVisibility;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.toggleVisibility,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 10.0), // Adds vertical padding
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 20.0), // Padding inside the text field
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.w500,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.blueAccent, // Icon color
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.blueAccent, // Password visibility icon color
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true, // Background color fill
          fillColor: Colors.white,
        ),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your $label';
              }
              return null;
            },
      ),
    );
  }
}
