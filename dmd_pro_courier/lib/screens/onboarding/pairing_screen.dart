import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../l10n/strings.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../home_screen.dart';
import 'photo_verification_screen.dart';

class PairingScreen extends StatefulWidget {
  final String lang;
  const PairingScreen({super.key, required this.lang});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final _storage = StorageService();
  final _api = ApiService();
  final _codeController = TextEditingController();

  String? _profileId;
  bool _verifying = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadProfileId();
  }

  Future<void> _loadProfileId() async {
    final id = await _storage.getOrCreateProfileId();
    if (!mounted) return;
    setState(() => _profileId = id);
  }

  Future<void> _openTelegram() async {
    final uri = Uri.parse('https://t.me/${AppConfig.botUsername}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _copyId() async {
    if (_profileId == null) return;
    await Clipboard.setData(ClipboardData(text: _profileId!));
    if (!mounted) return;
    final s = AppStrings(widget.lang);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.idCopied)));
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (_profileId == null || code.isEmpty) return;

    setState(() {
      _verifying = true;
      _errorText = null;
    });

    try {
      final result = await _api.verify(profileId: _profileId!, code: code);
      await _storage.savePairing(
        telegramId: result.telegramId,
        telegramUsername: result.telegramUsername,
        telegramName: result.telegramName,
      );
      if (!mounted) return;

      if (result.isApproved) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(lang: widget.lang, telegramId: result.telegramId),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PhotoVerificationScreen(lang: widget.lang, telegramId: result.telegramId),
          ),
        );
      }
    } catch (e) {
      setState(() => _errorText = e.toString());
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    return Scaffold(
      appBar: AppBar(title: Text(s.pairingTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s.pairingInstructions),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '/verify ${_profileId ?? '...'}',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: s.copyId,
                        onPressed: _copyId,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _openTelegram,
                icon: const Icon(Icons.send),
                label: Text(s.openTelegram),
              ),
              const SizedBox(height: 28),
              Text(s.pairingCodeHint),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(labelText: s.codeLabel, border: const OutlineInputBorder()),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(_errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _verifying ? null : _verify,
                child: _verifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(s.verifyBtn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
