import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BirthdayLabel extends StatelessWidget {
  final String message;
  final Color textColor;

  const BirthdayLabel(
      {super.key, required this.message, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: birthdayTextStyle.copyWith(color: textColor),
      textAlign: TextAlign.center,
    );
  }
}