import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const DmdApp());
}

class DmdApp extends StatelessWidget {
  const DmdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeliveryMD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2563EB),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
