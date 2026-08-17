import 'package:dmd_design/dmd_design.dart';
import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DmdNotifications.init();
  await DmdPushNotifications.init();
  DmdPushNotifications.listenForegroundMessages();
  runApp(const DmdApp());
}

class DmdApp extends StatelessWidget {
  const DmdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeliveryMD',
      debugShowCheckedModeBanner: false,
      theme: DmdTheme.light(DmdBrand.clientSeed),
      darkTheme: DmdTheme.dark(DmdBrand.clientSeed),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
