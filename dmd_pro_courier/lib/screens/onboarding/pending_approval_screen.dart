import 'package:dmd_design/dmd_design.dart';
import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../home_screen.dart';
import 'photo_verification_screen.dart';

class PendingApprovalScreen extends StatefulWidget {
  final String lang;
  final int telegramId;

  const PendingApprovalScreen({super.key, required this.lang, required this.telegramId});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  final _api = ApiService();
  final _storage = StorageService();
  bool _checking = false;

  Future<void> _checkStatus() async {
    setState(() => _checking = true);
    try {
      final status = await _api.getStatus(widget.telegramId);
      if (!mounted) return;
      if (status.isApproved) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(lang: widget.lang, telegramId: widget.telegramId),
          ),
        );
      } else if (status.isDeclined) {
        await _storage.setPhotoSubmitted(false);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PhotoVerificationScreen(lang: widget.lang, telegramId: widget.telegramId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings(widget.lang).pendingMessage)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    return Scaffold(
      body: SafeArea(
        child: DmdEmptyState(
          icon: Icons.hourglass_top_rounded,
          message: '${s.pendingTitle}\n\n${s.pendingMessage}',
          action: FilledButton.icon(
            onPressed: _checking ? null : _checkStatus,
            icon: _checking
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            label: Text(s.checkStatus),
          ),
        ),
      ),
    );
  }
}
