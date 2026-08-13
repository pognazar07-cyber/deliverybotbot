import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/strings.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'pending_approval_screen.dart';

class PhotoVerificationScreen extends StatefulWidget {
  final String lang;
  final int telegramId;

  const PhotoVerificationScreen({super.key, required this.lang, required this.telegramId});

  @override
  State<PhotoVerificationScreen> createState() => _PhotoVerificationScreenState();
}

class _PhotoVerificationScreenState extends State<PhotoVerificationScreen> {
  final _picker = ImagePicker();
  final _api = ApiService();
  final _storage = StorageService();

  XFile? _photo;
  bool _submitting = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1600);
    if (file == null) return;
    setState(() => _photo = file);
  }

  Future<void> _submit() async {
    if (_photo == null) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final bytes = await _photo!.readAsBytes();
      final base64Photo = base64Encode(bytes);
      await _api.submitVerificationPhoto(telegramId: widget.telegramId, photoBase64: base64Photo);
      await _storage.setPhotoSubmitted(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PendingApprovalScreen(lang: widget.lang, telegramId: widget.telegramId),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    return Scaffold(
      appBar: AppBar(title: Text(s.photoTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s.photoInstructions),
              const SizedBox(height: 20),
              if (_photo != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(File(_photo!.path), height: 280, fit: BoxFit.cover),
                )
              else
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.badge_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(s.takePhoto),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(s.choosePhoto),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _photo == null || _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(s.submitPhoto),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
