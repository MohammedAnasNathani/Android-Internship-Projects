import 'package:flutter/material.dart';

class GifDisplay extends StatelessWidget {
  final String asset;

  const GifDisplay({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Text('Unable to load the image',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red)),
          );
        },
      ),
    );
  }
}