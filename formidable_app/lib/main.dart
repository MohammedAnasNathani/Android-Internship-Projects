import 'package:flutter/material.dart';
import 'package:formidable_app/screens/home_screen.dart';
import 'package:formidable_app/utils/app_colors.dart';
import 'package:formidable_app/services/socket_service.dart';
import 'package:provider/provider.dart';

void main() {
  SocketService.instance.connectSocket();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SocketService.instance,
      child: MaterialApp(
        title: "SundarScaleless",
        theme: ThemeData(
          primarySwatch: AppColors.primarySwatch,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}