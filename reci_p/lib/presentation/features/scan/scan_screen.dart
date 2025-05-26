import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reci_p/presentation/features/scan/bloc/scan_bloc.dart';
import 'package:reci_p/presentation/features/scan/bloc/scan_event.dart';
import 'package:reci_p/presentation/routes.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ingredients'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _pickImage(context, ImageSource.camera);
              },
              child: const Text('Scan from Camera'),
            ),
            ElevatedButton(
              onPressed: () {
                _pickImage(context, ImageSource.gallery);
              },
              child: const Text('Scan from Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(BuildContext context, ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final imagePath = pickedFile.path;
      if (!context.mounted) return;
      Navigator.of(context).pushNamed(AppRoutes.recipeList, arguments: imagePath);
    }
  }
}