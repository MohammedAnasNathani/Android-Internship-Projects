import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String text;
  final Function(String) buttonPressed;
  final bool isOperator;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.buttonPressed,
    this.isOperator = false
  });
  void _onButtonPressed() {
    buttonPressed(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: 70.0,
        height: 70.0,
        child: ElevatedButton(
          onPressed: _onButtonPressed,
          style: ElevatedButton.styleFrom(
              backgroundColor: isOperator ? Theme.of(context).colorScheme.secondary : Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))
          ),
          child: Text(text, style: TextStyle(fontSize: 24, color: Theme.of(context).scaffoldBackgroundColor)),
        ),
      ),
    );
  }
}