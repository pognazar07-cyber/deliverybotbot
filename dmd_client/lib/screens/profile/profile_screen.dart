import 'package:dmd_design/dmd_design.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
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
  String? _currentVersion;
  bool _deleting = false;
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profileId = await _storage.getOrCreateProfileId();
    final username = await _storage.getTelegramUsername();
    final name = await _storage.getTelegramName();
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _profileId = profileId;
      _username = username;
      _name = name;
      _currentVersion = packageInfo.version;
    });
  }

  Future<void> _checkForUpdates() async {
    final s = AppStrings(widget.lang);
    setState(() => _checkingUpdate = true);
    try {
      final info = await _api.checkForUpdate(widget.lang);
      if (!mounted) return;
      if (!isDmdVersionNewer(latest: info.latestVersion, current: _currentVersion ?? '0')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.upToDate)));
        return;
      }
      await showDmdUpdateDialog(
        context,
        info: info,
        title: s.updateAvailableTitle,
        updateNowLabel: s.updateNow,
        laterLabel: s.later,
        onUpdateNow: () => launchUrl(
          Uri.parse('${AppConfig.apiBaseUrl}${info.apkUrl}'),
          mode: LaunchMode.externalApplication,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _checkingUpdate = false);
    }
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
          Card(
            child: ListTile(
              leading: const Icon(Icons.system_update_outlined),
              title: Text(s.checkUpdates),
              subtitle: _currentVersion != null ? Text('${s.currentVersion} ${_currentVersion!}') : null,
              trailing: _checkingUpdate
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.chevron_right),
              onTap: _checkingUpdate ? null : _checkForUpdates,
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
