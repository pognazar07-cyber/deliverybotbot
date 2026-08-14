import 'package:latlong2/latlong.dart';

import 'api_service.dart';

class RouteQuote {
  final double distanceKm;
  final double price;

  const RouteQuote({required this.distanceKm, required this.price});
}

/// Gets distance + price for a route from the backend's /api/quote, which
/// runs the exact same OSRM lookup + formula the order will actually be
/// charged with (bot.py's calculate_price()) — so the preview always
/// matches what gets billed, and there's one source of truth instead of
/// the app guessing with its own copy of the formula.
class PricingService {
  final ApiService _api;

  PricingService({ApiService? api}) : _api = api ?? ApiService();

  // Same constants as the backend, used only as an offline fallback so the
  // UI never gets stuck if the server is briefly unreachable.
  static const double _standardRatePerKm = 10;
  static const double _freightRatePerKm = 20;
  static const double _baseFare = 40;
  static const double _minimumPrice = 60;

  Future<RouteQuote> quote({
    required LatLng pointA,
    required LatLng pointB,
    required String cargoType,
  }) async {
    try {
      final result = await _api.getQuote(
        cargoType: cargoType,
        latA: pointA.latitude,
        lonA: pointA.longitude,
        latB: pointB.latitude,
        lonB: pointB.longitude,
      );
      return RouteQuote(distanceKm: result.distanceKm, price: result.price);
    } catch (_) {
      return _offlineFallback(pointA, pointB, cargoType);
    }
  }

  RouteQuote _offlineFallback(LatLng pointA, LatLng pointB, String cargoType) {
    const haversine = Distance();
    final distanceKm = double.parse(
      haversine.as(LengthUnit.Kilometer, pointA, pointB).toStringAsFixed(2),
    );
    final rate = cargoType == 'freight' ? _freightRatePerKm : _standardRatePerKm;
    var price = double.parse((distanceKm * rate + _baseFare).toStringAsFixed(2));
    if (price < _minimumPrice) price = _minimumPrice;
    return RouteQuote(distanceKm: distanceKm, price: price);
  }
}
