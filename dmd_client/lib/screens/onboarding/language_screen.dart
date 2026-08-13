import 'package:flutter/material.dart';

import '../../config.dart';
import '../../services/storage_service.dart';
import 'pairing_screen.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _labels = {'ru': '🇷🇺 Русский', 'ro': '🇲🇩 Română', 'en': '🇬🇧 English'};

  Future<void> _select(BuildContext context, String lang) async {
    await StorageService().setLanguage(lang);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PairingScreen(lang: lang)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_shipping_rounded, size: 72),
                const SizedBox(height: 16),
                const Text(
                  'DeliveryMD',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 48),
                for (final lang in AppConfig.supportedLanguages)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _select(context, lang),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                        child: Text(_labels[lang] ?? lang, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
