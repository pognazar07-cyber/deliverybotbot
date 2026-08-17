import 'package:dmd_design/dmd_design.dart';
import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DmdNotifications.init();
  await DmdPushNotifications.init();
  DmdPushNotifications.listenForegroundMessages();
  runApp(const DmdProCourierApp());
}

class DmdProCourierApp extends StatelessWidget {
  const DmdProCourierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DMD Pro Courier',
      debugShowCheckedModeBanner: false,
      theme: DmdTheme.light(DmdBrand.courierSeed),
      darkTheme: DmdTheme.dark(DmdBrand.courierSeed),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
