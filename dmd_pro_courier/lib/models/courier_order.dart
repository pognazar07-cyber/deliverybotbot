import 'package:dmd_design/dmd_design.dart';
import 'package:latlong2/latlong.dart';

/// Mirrors the order DTO returned by bot.py's courier API (_order_dto()).
/// phoneSender/phoneReceiver are only populated once the order is accepted
/// (the backend withholds them from the "available orders" listing).
class CourierOrder {
  final int id;
  final String cargoType; // 'standard' | 'freight'
  final double latA;
  final double lonA;
  final double latB;
  final double lonB;
  final String comment;
  final double price;
  final String status; // pending | accepted | at_a | at_b | completed
  final String? phoneSender;
  final String? phoneReceiver;
  final List<LatLng> route; // real road route from OSRM; empty if unavailable

  const CourierOrder({
    required this.id,
    required this.cargoType,
    required this.latA,
    required this.lonA,
    required this.latB,
    required this.lonB,
    required this.comment,
    required this.price,
    required this.status,
    this.phoneSender,
    this.phoneReceiver,
    this.route = const [],
  });

  factory CourierOrder.fromJson(Map<String, dynamic> json) {
    return CourierOrder(
      id: json['id'] as int,
      cargoType: json['cargo_type'] as String,
      latA: (json['lat_a'] as num).toDouble(),
      lonA: (json['lon_a'] as num).toDouble(),
      latB: (json['lat_b'] as num).toDouble(),
      lonB: (json['lon_b'] as num).toDouble(),
      comment: json['comment'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String,
      phoneSender: json['phone_sender'] as String?,
      phoneReceiver: json['phone_receiver'] as String?,
      route: _parseRoute(json['route']),
    );
  }

  static List<LatLng> _parseRoute(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((p) => LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble()))
        .toList();
  }

  /// The status this order will move to when the courier taps the primary
  /// action button, or null once it's completed.
  String? get nextStatus => switch (status) {
        'accepted' => 'at_a',
        'at_a' => 'at_b',
        'at_b' => 'completed',
        _ => null,
      };

  DmdStatusKind get statusKind => switch (status) {
        'accepted' || 'at_a' || 'at_b' => DmdStatusKind.inProgress,
        'completed' => DmdStatusKind.success,
        _ => DmdStatusKind.pending,
      };

  CourierOrder copyWith({String? status}) {
    return CourierOrder(
      id: id,
      cargoType: cargoType,
      latA: latA,
      lonA: lonA,
      latB: latB,
      lonB: lonB,
      comment: comment,
      price: price,
      status: status ?? this.status,
      phoneSender: phoneSender,
      phoneReceiver: phoneReceiver,
      route: route,
    );
  }
}
