import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/courier_order.dart';

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
  final bool isApproved;

  const VerifyResult({
    required this.telegramId,
    required this.telegramUsername,
    required this.telegramName,
    required this.isApproved,
  });
}

class CourierStatus {
  final String? role;
  final bool isApproved;
  final bool isOnline;

  const CourierStatus({required this.role, required this.isApproved, required this.isOnline});
}

class CourierHistory {
  final double earningsThisMonth;
  final int completedThisMonth;
  final List<CourierOrder> orders;

  const CourierHistory({
    required this.earningsThisMonth,
    required this.completedThisMonth,
    required this.orders,
  });
}

/// Thin wrapper around the bot's /api/courier/* REST API (see bot.py,
/// section "REST API ДЛЯ ПРИЛОЖЕНИЯ DMD PRO COURIER").
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

  /// POST /api/courier/verify
  Future<VerifyResult> verify({required String profileId, required String code}) async {
    final resp = await _client
        .post(
          _uri('/api/courier/verify'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'profile_id': profileId, 'code': code}),
        )
        .timeout(const Duration(seconds: 15));
    final body = _decode(resp);
    return VerifyResult(
      telegramId: body['telegram_id'] as int,
      telegramUsername: body['telegram_username'] as String? ?? '',
      telegramName: body['telegram_name'] as String? ?? '',
      isApproved: body['is_approved'] as bool? ?? false,
    );
  }

  /// POST /api/courier/register-photo
  Future<void> submitVerificationPhoto({required int telegramId, required String photoBase64}) async {
    final resp = await _client
        .post(
          _uri('/api/courier/register-photo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'telegram_id': telegramId, 'photo_base64': photoBase64}),
        )
        .timeout(const Duration(seconds: 30));
    _decode(resp);
  }

  /// GET /api/courier/status/{telegramId}
  Future<CourierStatus> getStatus(int telegramId) async {
    final resp =
        await _client.get(_uri('/api/courier/status/$telegramId')).timeout(const Duration(seconds: 15));
    final body = _decode(resp);
    return CourierStatus(
      role: body['role'] as String?,
      isApproved: body['is_approved'] as bool? ?? false,
      isOnline: body['is_online'] as bool? ?? false,
    );
  }

  /// POST /api/courier/online/{telegramId}
  Future<void> goOnline(int telegramId) async {
    final resp =
        await _client.post(_uri('/api/courier/online/$telegramId')).timeout(const Duration(seconds: 15));
    _decode(resp);
  }

  /// POST /api/courier/offline/{telegramId}
  Future<void> goOffline(int telegramId) async {
    final resp =
        await _client.post(_uri('/api/courier/offline/$telegramId')).timeout(const Duration(seconds: 15));
    _decode(resp);
  }

  /// POST /api/courier/location/{telegramId} — reported periodically while
  /// a delivery is in progress so the client can see the courier on the map.
  Future<void> reportLocation({required int telegramId, required double lat, required double lon}) async {
    final resp = await _client
        .post(
          _uri('/api/courier/location/$telegramId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'lat': lat, 'lon': lon}),
        )
        .timeout(const Duration(seconds: 15));
    _decode(resp);
  }

  /// GET /api/courier/orders/available/{telegramId}
  Future<List<CourierOrder>> getAvailableOrders(int telegramId) async {
    final resp = await _client
        .get(_uri('/api/courier/orders/available/$telegramId'))
        .timeout(const Duration(seconds: 15));
    final body = _decode(resp);
    final list = body['orders'] as List;
    return list.map((e) => CourierOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /api/courier/orders/{id}/accept
  Future<CourierOrder> acceptOrder({required int orderId, required int courierId}) async {
    final resp = await _client
        .post(
          _uri('/api/courier/orders/$orderId/accept'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'courier_id': courierId}),
        )
        .timeout(const Duration(seconds: 15));
    final body = _decode(resp);
    return CourierOrder.fromJson(body['order'] as Map<String, dynamic>);
  }

  /// GET /api/courier/orders/active/{telegramId}
  Future<CourierOrder?> getActiveOrder(int telegramId) async {
    final resp = await _client
        .get(_uri('/api/courier/orders/active/$telegramId'))
        .timeout(const Duration(seconds: 15));
    final body = _decode(resp);
    final order = body['order'];
    if (order == null) return null;
    return CourierOrder.fromJson(order as Map<String, dynamic>);
  }

  /// POST /api/courier/orders/{id}/status
  Future<void> updateOrderStatus({
    required int orderId,
    required int courierId,
    required String status,
  }) async {
    final resp = await _client
        .post(
          _uri('/api/courier/orders/$orderId/status'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'courier_id': courierId, 'status': status}),
        )
        .timeout(const Duration(seconds: 15));
    _decode(resp);
  }

  /// GET /api/courier/history/{telegramId}
  Future<CourierHistory> getHistory(int telegramId) async {
    final resp = await _client
        .get(_uri('/api/courier/history/$telegramId'))
        .timeout(const Duration(seconds: 15));
    final body = _decode(resp);
    final list = body['orders'] as List;
    return CourierHistory(
      earningsThisMonth: (body['earnings_this_month'] as num).toDouble(),
      completedThisMonth: body['completed_this_month'] as int,
      orders: list.map((e) => CourierOrder.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
