import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteQuote {
  final double distanceKm;
  final double price;

  const RouteQuote({required this.distanceKm, required this.price});
}

/// Mirrors bot.py's get_osrm_data() (public OSRM router) and the price
/// formula used in process_confirm_order / handle_create_order_api:
///   rate = 10 (standard) or 20 (freight) MDL/km
///   price = round(dist_km * rate + 40, 2), floored at 60 MDL.
class PricingService {
  static const double standardRatePerKm = 10;
  static const double freightRatePerKm = 20;
  static const double baseFare = 40;
  static const double minimumPrice = 60;

  Future<RouteQuote> quote({
    required LatLng pointA,
    required LatLng pointB,
    required String cargoType,
  }) async {
    final distanceKm = await _fetchDistanceKm(pointA, pointB);
    final rate = cargoType == 'freight' ? freightRatePerKm : standardRatePerKm;
    var price = (distanceKm * rate + baseFare);
    price = double.parse(price.toStringAsFixed(2));
    if (price < minimumPrice) price = minimumPrice;
    return RouteQuote(distanceKm: distanceKm, price: price);
  }

  Future<double> _fetchDistanceKm(LatLng a, LatLng b) async {
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${a.longitude},${a.latitude};${b.longitude},${b.latitude}'
      '?overview=false&geometries=geojson',
    );
    try {
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final meters = (routes[0]['distance'] as num).toDouble();
          return double.parse((meters / 1000).toStringAsFixed(2));
        }
      }
    } catch (_) {
      // Falls through to the straight-line fallback below.
    }
    // Fallback so the UI never gets stuck if OSRM is briefly unreachable.
    const haversine = Distance();
    return double.parse((haversine.as(LengthUnit.Kilometer, a, b)).toStringAsFixed(2));
  }
}
