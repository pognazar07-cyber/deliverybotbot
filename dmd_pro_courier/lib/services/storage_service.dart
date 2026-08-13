import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the pairing state produced by the /verify + /api/courier/verify
/// flow, plus simple user prefs. See bot.py: cmd_verify_app / handle_courier_verify_api.
class StorageService {
  static const _kProfileId = 'profile_id';
  static const _kTelegramId = 'telegram_id';
  static const _kTelegramUsername = 'telegram_username';
  static const _kTelegramName = 'telegram_name';
  static const _kLanguage = 'language';
  static const _kPhotoSubmitted = 'photo_submitted';

  /// Generates a fresh 15-character profile id shaped like DEL-XXXX-XXXX-XXXX
  /// (matches the length check in bot.py's cmd_verify_app: 15 or 16 chars
  /// once dashes are stripped — shared with the client app's pairing flow).
  static String generateProfileId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    String group() => List.generate(4, (_) => chars[rnd.nextInt(chars.length)]).join();
    return 'DEL-${group()}-${group()}-${group()}';
  }

  Future<String> getOrCreateProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_kProfileId);
    if (existing != null && existing.isNotEmpty) return existing;
    final fresh = generateProfileId();
    await prefs.setString(_kProfileId, fresh);
    return fresh;
  }

  Future<void> savePairing({
    required int telegramId,
    required String telegramUsername,
    required String telegramName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTelegramId, telegramId);
    await prefs.setString(_kTelegramUsername, telegramUsername);
    await prefs.setString(_kTelegramName, telegramName);
  }

  Future<int?> getTelegramId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kTelegramId);
  }

  Future<String?> getTelegramUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTelegramUsername);
  }

  Future<String?> getTelegramName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kTelegramName);
  }

  Future<bool> isPaired() async => (await getTelegramId()) != null;

  Future<void> setPhotoSubmitted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPhotoSubmitted, value);
  }

  Future<bool> getPhotoSubmitted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPhotoSubmitted) ?? false;
  }

  Future<void> clearPairing() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTelegramId);
    await prefs.remove(_kTelegramUsername);
    await prefs.remove(_kTelegramName);
    await prefs.remove(_kProfileId);
    await prefs.remove(_kPhotoSubmitted);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLanguage) ?? 'ru';
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, lang);
  }
}
