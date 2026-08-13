import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import 'home_screen.dart';
import 'onboarding/language_screen.dart';

/// Decides where to land: straight into the client's home screen if the
/// device is already paired with a Telegram account, otherwise onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = StorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    final telegramId = await _storage.getTelegramId();
    final lang = await _storage.getLanguage();
    if (!mounted) return;

    if (telegramId != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(lang: lang, telegramId: telegramId)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LanguageScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
