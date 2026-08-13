import 'package:dmd_design/dmd_design.dart';

/// Mirrors the order DTO returned by the bot's REST API
/// (handle_get_active_order_api / handle_get_order_history_api in bot.py).
class DeliveryOrder {
  final int id;
  final String cargoType; // 'standard' | 'freight'
  final double latA;
  final double lonA;
  final double latB;
  final double lonB;
  final String phoneSender;
  final String phoneReceiver;
  final String comment;
  final double price;
  final String status; // pending | accepted | at_a | at_b | completed | cancelled
  final int? courierId;
  final String? courierName;
  final double? courierLat;
  final double? courierLon;

  const DeliveryOrder({
    required this.id,
    required this.cargoType,
    required this.latA,
    required this.lonA,
    required this.latB,
    required this.lonB,
    required this.phoneSender,
    required this.phoneReceiver,
    required this.comment,
    required this.price,
    required this.status,
    this.courierId,
    this.courierName,
    this.courierLat,
    this.courierLon,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] as int,
      cargoType: json['cargo_type'] as String,
      latA: (json['lat_a'] as num).toDouble(),
      lonA: (json['lon_a'] as num).toDouble(),
      latB: (json['lat_b'] as num).toDouble(),
      lonB: (json['lon_b'] as num).toDouble(),
      phoneSender: json['phone_sender'] as String? ?? '',
      phoneReceiver: json['phone_receiver'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String,
      courierId: json['courier_id'] as int?,
      courierName: json['courier_name'] as String?,
      courierLat: (json['courier_lat'] as num?)?.toDouble(),
      courierLon: (json['courier_lon'] as num?)?.toDouble(),
    );
  }

  bool get isActive =>
      status == 'pending' || status == 'accepted' || status == 'at_a' || status == 'at_b';

  bool get isCancellable => status == 'pending';

  DmdStatusKind get statusKind => switch (status) {
        'pending' => DmdStatusKind.pending,
        'accepted' || 'at_a' || 'at_b' => DmdStatusKind.inProgress,
        'completed' => DmdStatusKind.success,
        'cancelled' => DmdStatusKind.danger,
        _ => DmdStatusKind.pending,
      };
}

/// Mirrors a support_tickets row returned by handle_get_support_tickets_api.
class SupportTicket {
  final int id;
  final int clientId;
  final String message;
  final String? reply;
  final String status; // open | answered (server-defined)
  final DateTime? createdAt;

  const SupportTicket({
    required this.id,
    required this.clientId,
    required this.message,
    required this.status,
    this.reply,
    this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as int,
      clientId: json['client_id'] as int,
      message: json['message'] as String? ?? '',
      reply: json['reply'] as String?,
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
