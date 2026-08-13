import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../services/api_service.dart';
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
  final _api = ApiService();

  String? _profileId;
  String? _username;
  String? _name;
  bool _deleting = false;

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

  Future<void> _confirmDelete() async {
    final s = AppStrings(widget.lang);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.deleteAccount),
        content: Text(s.deleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(s.confirm)),
        ],
      ),
    );
    if (confirmed != true) return;
    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    if (_profileId == null) return;
    setState(() => _deleting = true);
    try {
      await _api.deleteAccount(_profileId!);
      await _storage.clearPairing();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LanguageScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
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
            onPressed: _deleting ? null : _confirmDelete,
            icon: _deleting
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.delete_outline),
            label: Text(s.deleteAccount),
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
