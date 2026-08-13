import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/order.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class VerifyResult {
  final int telegramId;
  final String telegramUsername;
  final String telegramName;

  const VerifyResult({
    required this.telegramId,
    required this.telegramUsername,
    required this.telegramName,
  });
}

class AppUpdateInfo {
  final String latestVersion;
  final String updateMessage;
  final bool forceUpdate;
  final List<String> newFeatures;
  final String apkUrl;

  const AppUpdateInfo({
    required this.latestVersion,
    required this.updateMessage,
    required this.forceUpdate,
    required this.newFeatures,
    required this.apkUrl,
  });
}

/// Thin wrapper around the bot's REST API (see the `app.router.add_*` calls
/// near the bottom of bot.py for the authoritative list of routes).
class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, dynamic> _decode(http.Response resp) {
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw ApiException(body['error'] as String? ?? 'Unknown server error');
    }
    return body;
  }

  /// POST /api/verify — completes the Telegram <-> app pairing started by
  /// the user typing `/verify <profile_id>` in the bot.
  Future<VerifyResult> verify({required String profileId, required String code}) async {
    final resp = await _client
        .post(
          _uri('/api/verify'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'profile_id': profileId, 'code': code}),
        )
        .timeout(const Duration(seconds: 15));
    final body = _decode(resp);
    return VerifyResult(
      telegramId: body['telegram_id'] as int,
      telegramUsername: body['telegram_username'] as String? ?? '',
      telegramName: body['telegram_name'] as String? ?? '',
    );
  }

  /// POST /api/delete-account/{profileId}
  Future<void> deleteAccount(String profileId) async {
    final resp = await _client
        .post(_uri('/api/delete-account/$profileId'))
        .timeout(const Duration(seconds: 15));
    _decode(resp);
  }

  /// POST /api/orders
  Future<int> createOrder({
    required int clientId,
    required String cargoType,
    required double latA,
    required double lonA,
    required double latB,
    required double lonB,
    required String phoneSender,
    required String phoneReceiver,
    required String comment,
    required double price,
  }) async {
    final resp = await _client
        .post(
          _uri('/api/orders'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'client_id': clientId,
            'cargo_type': cargoType,
            'lat_a': latA,
            'lon_a': lonA,
            'lat_b': latB,
            'lon_b': lonB,
            'phone_sender': phoneSender,
            'phone_receiver': phoneReceiver,
            'comment': comment,
            'price': price,
          }),
        )
        .timeout(const Duration(seconds: 15));
    final body = _decode(resp);
    return body['order_id'] as int;
  }

  /// GET /api/orders/active/{clientId}
  Future<DeliveryOrder?> getActiveOrder(int clientId) async {
    final resp = await _client
        .get(_uri('/api/orders/active/$clientId'))
        .timeout(const Duration(seconds: 15));
    final body = _decode(resp);
    final order = body['order'];
    if (order == null) return null;
    return DeliveryOrder.fromJson(order as Map<String, dynamic>);
  }

  /// POST /api/orders/{id}/cancel
  Future<void> cancelOrder(int orderId) async {
    final resp = await _client
        .post(_uri('/api/orders/$orderId/cancel'))
        .timeout(const Duration(seconds: 15));
    _decode(resp);
  }

  /// GET /api/orders/history/{clientId}
  Future<List<DeliveryOrder>> getOrderHistory(int clientId) async {
    final resp = await _client
        .get(_uri('/api/orders/history/$clientId'))
        .timeout(const Duration(seconds: 15));
    final body = _decode(resp);
    final list = body['orders'] as List;
    return list.map((e) => DeliveryOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /api/support
  Future<int> submitSupportTicket({
    required int clientId,
    required String name,
    required String username,
    required String text,
  }) async {
    final resp = await _client
        .post(
          _uri('/api/support'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'client_id': clientId,
            'name': name,
            'username': username,
            'text': text,
          }),
        )
        .timeout(const Duration(seconds: 15));
    final body = _decode(resp);
    return body['ticket_id'] as int;
  }

  /// GET /api/support/{clientId}
  Future<List<SupportTicket>> getSupportTickets(int clientId) async {
    final resp = await _client
        .get(_uri('/api/support/$clientId'))
        .timeout(const Duration(seconds: 15));
    final body = _decode(resp);
    final list = body['tickets'] as List;
    return list.map((e) => SupportTicket.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/app-update
  Future<AppUpdateInfo> checkForUpdate(String lang) async {
    final resp = await _client.get(_uri('/api/app-update')).timeout(const Duration(seconds: 15));
    final body = _decode(resp);
    final messageKey = 'update_message_$lang';
    return AppUpdateInfo(
      latestVersion: body['latest_version'] as String? ?? '',
      updateMessage: body[messageKey] as String? ?? body['update_message_ru'] as String? ?? '',
      forceUpdate: body['force_update'] as bool? ?? false,
      newFeatures: (body['new_features'] as List? ?? []).cast<String>(),
      apkUrl: body['apk_url'] as String? ?? '/api/download-apk',
    );
  }
}
