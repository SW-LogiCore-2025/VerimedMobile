import 'package:flutter/material.dart';
import 'package:verimedapp/screens/splash_screen.dart';
import 'package:verimedapp/utilities/app_constants.dart';

void main() {
  runApp(const VeriMedApp());
}

class VeriMedApp extends StatelessWidget {
  const VeriMedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppConstants.primaryBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
