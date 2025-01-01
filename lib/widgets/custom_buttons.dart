import 'package:e_travel/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final double borderRadius;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primaryColor,
    this.borderRadius = 8.0,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 90.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle ?? 
            const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
