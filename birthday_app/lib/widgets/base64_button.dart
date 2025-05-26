import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';

class Base64Button extends StatelessWidget {
  final bool isBase64;
  final VoidCallback onTap;
  final Color textColor;

  const Base64Button(
      {super.key,
        required this.isBase64,
        required this.onTap,
        required this.textColor});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          backgroundColor: pastelPink,
          foregroundColor: textColor,
          elevation: 3,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: Text(isBase64 ? "Decode" : "Encode").animate().shimmer(),
    );
  }
}