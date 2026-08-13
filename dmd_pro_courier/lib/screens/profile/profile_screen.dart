import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../services/storage_service.dart';
import '../onboarding/language_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String lang;
  final int telegramId;

  const ProfileScreen({super.key, required this.lang, required this.telegramId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = StorageService();

  String? _profileId;
  String? _username;
  String? _name;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profileId = await _storage.getOrCreateProfileId();
    final username = await _storage.getTelegramUsername();
    final name = await _storage.getTelegramName();
    if (!mounted) return;
    setState(() {
      _profileId = profileId;
      _username = username;
      _name = name;
    });
  }

  Future<void> _logout() async {
    await _storage.clearPairing();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LanguageScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    return Scaffold(
      appBar: AppBar(title: Text(s.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.send),
              title: Text(s.telegramLabel),
              subtitle: Text(_username != null && _username!.isNotEmpty
                  ? '@$_username'
                  : (_name ?? '—')),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(s.profileIdLabel),
              subtitle: Text(_profileId ?? '—', style: const TextStyle(fontFamily: 'monospace')),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: Text(s.logout),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }
}
