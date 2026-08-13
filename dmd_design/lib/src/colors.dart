import 'package:flutter/material.dart';

/// Brand seed colors. Each app generates its own Material 3 ColorScheme
/// from one of these via [DmdTheme], so both apps share the same shape and
/// typography but stay visually distinct: blue reads as "ordering, trust"
/// for clients, amber reads as "on shift, move fast" for couriers.
class DmdBrand {
  DmdBrand._();

  static const clientSeed = Color(0xFF2F6FED);
  static const courierSeed = Color(0xFFE8720C);
}

/// Status colors shared by order-status chips/badges across both apps.
/// Kept independent of the brand seed so "cancelled" always reads as
/// danger and "completed" always reads as success, regardless of app.
class DmdStatusColors {
  DmdStatusColors._();

  static const pending = Color(0xFF6B7280); // searching for a courier
  static const inProgress = Color(0xFF2F6FED); // accepted / en route
  static const success = Color(0xFF15803D); // completed
  static const danger = Color(0xFFDC2626); // cancelled
  static const warning = Color(0xFFE8720C); // needs attention
}
