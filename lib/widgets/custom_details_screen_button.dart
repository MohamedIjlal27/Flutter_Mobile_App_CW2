import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final IconData? icon; // Optionally add an icon
  final double borderRadius; // Allow customization of border radius
  final Color backgroundColor; // Background color of the button
  final Color textColor; // Color of the text

  const CustomButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.icon,
    this.borderRadius = 30.0,
    this.backgroundColor = Colors.blueAccent, // Default background color
    this.textColor = Colors.white, // Default text color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        side: BorderSide(color: backgroundColor, width: 2),
        elevation: 4,
        shadowColor: backgroundColor.withOpacity(0.4),
        backgroundColor: backgroundColor, // Set the background color
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 20), // Set icon color
            const SizedBox(width: 8), // Space between icon and text
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor, // Set the text color
            ),
          ),
        ],
      ),
    );
  }
}