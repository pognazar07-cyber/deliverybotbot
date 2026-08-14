/// Mirrors bot.py's GET /api/app-update response. Shared by both apps so
/// the parsing and "is this actually newer" logic exists exactly once.
class DmdAppUpdateInfo {
  final String latestVersion;
  final String updateMessage;
  final bool forceUpdate;
  final List<String> newFeatures;
  final String apkUrl;

  const DmdAppUpdateInfo({
    required this.latestVersion,
    required this.updateMessage,
    required this.forceUpdate,
    required this.newFeatures,
    required this.apkUrl,
  });

  factory DmdAppUpdateInfo.fromJson(Map<String, dynamic> body, String lang) {
    final messageKey = 'update_message_$lang';
    return DmdAppUpdateInfo(
      latestVersion: body['latest_version'] as String? ?? '',
      updateMessage: body[messageKey] as String? ?? body['update_message_ru'] as String? ?? '',
      forceUpdate: body['force_update'] as bool? ?? false,
      newFeatures: (body['new_features'] as List? ?? []).cast<String>(),
      apkUrl: body['apk_url'] as String? ?? '/api/download-apk',
    );
  }
}

/// Compares two dotted version strings (e.g. "2.1.4"). Returns true if
/// [latest] is strictly newer than [current]. Non-numeric/missing segments
/// are treated as 0, so "2.2" beats "2.1.9".
bool isDmdVersionNewer({required String latest, required String current}) {
  List<int> parse(String v) => v
      .split('.')
      .map((part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
      .toList();

  final a = parse(latest);
  final b = parse(current);
  final length = a.length > b.length ? a.length : b.length;

  for (var i = 0; i < length; i++) {
    final av = i < a.length ? a[i] : 0;
    final bv = i < b.length ? b[i] : 0;
    if (av != bv) return av > bv;
  }
  return false;
}
