import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';
import 'onboarding/language_screen.dart';
import 'onboarding/pending_approval_screen.dart';
import 'onboarding/photo_verification_screen.dart';

/// Decides where to land: onboarding if this device isn't paired yet,
/// otherwise the approval/photo/home screen matching the courier's
/// current status (re-checked from the server, not just cached locally).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = StorageService();
  final _api = ApiService();
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    setState(() => _error = null);
    final telegramId = await _storage.getTelegramId();
    final lang = await _storage.getLanguage();
    if (!mounted) return;

    if (telegramId == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LanguageScreen()),
      );
      return;
    }

    try {
      final status = await _api.getStatus(telegramId);
      if (!mounted) return;

      if (status.isApproved) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(lang: lang, telegramId: telegramId)),
        );
        return;
      }

      if (status.isDeclined) {
        // The server is the source of truth for a decline — always send
        // the courier back to resubmit, regardless of the local flag.
        await _storage.setPhotoSubmitted(false);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => PhotoVerificationScreen(lang: lang, telegramId: telegramId)),
        );
        return;
      }

      final photoSubmitted = await _storage.getPhotoSubmitted();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => photoSubmitted
              ? PendingApprovalScreen(lang: lang, telegramId: telegramId)
              : PhotoVerificationScreen(lang: lang, telegramId: telegramId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(onPressed: _route, child: Text(AppStrings('ru').retry)),
              ],
            ),
          ),
        ),
      );
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
