import 'dart:async';

import 'package:dmd_design/dmd_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/strings.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';

class ActiveOrderScreen extends StatefulWidget {
  final String lang;
  final int clientId;
  final DeliveryOrder initialOrder;
  final VoidCallback onOrderClosed;

  const ActiveOrderScreen({
    super.key,
    required this.lang,
    required this.clientId,
    required this.initialOrder,
    required this.onOrderClosed,
  });

  @override
  State<ActiveOrderScreen> createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen> {
  final _api = ApiService();
  late DeliveryOrder _order;
  Timer? _poll;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder;
    _poll = Timer.periodic(const Duration(seconds: 6), (_) => _refresh());
  }

  Future<void> _refresh() async {
    try {
      final updated = await _api.getActiveOrder(widget.clientId);
      if (!mounted) return;
      if (updated == null) {
        widget.onOrderClosed();
        return;
      }
      setState(() => _order = updated);
    } catch (_) {
      // Keep showing the last known state; next tick will retry.
    }
  }

  Future<void> _cancel() async {
    setState(() => _cancelling = true);
    try {
      await _api.cancelOrder(_order.id);
      widget.onOrderClosed();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    final pointA = LatLng(_order.latA, _order.lonA);
    final pointB = LatLng(_order.latB, _order.lonB);
    final bounds = LatLngBounds.fromPoints([pointA, pointB]);

    return Scaffold(
      appBar: AppBar(title: Text(s.activeOrderTitle)),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.deliverymd.dmd_client',
                ),
                PolylineLayer(polylines: [
                  Polyline(points: [pointA, pointB], strokeWidth: 3, color: Colors.blueAccent),
                ]),
                MarkerLayer(markers: [
                  Marker(
                    point: pointA,
                    width: 36,
                    height: 36,
                    child: const Icon(Icons.trip_origin, color: Colors.green, size: 32),
                  ),
                  Marker(
                    point: pointB,
                    width: 36,
                    height: 36,
                    child: const Icon(Icons.flag, color: Colors.red, size: 32),
                  ),
                  if (_order.courierLat != null && _order.courierLon != null)
                    Marker(
                      point: LatLng(_order.courierLat!, _order.courierLon!),
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.two_wheeler, color: Colors.deepOrange, size: 34),
                    ),
                ]),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DmdStatusChip(label: s.statusLabel(_order.status), kind: _order.statusKind),
                  const SizedBox(height: 8),
                  Text('#${_order.id} · ${_order.price.toStringAsFixed(2)} MDL',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (_order.courierName != null) ...[
                    const SizedBox(height: 4),
                    Text('${s.courierLabel}: @${_order.courierName}'),
                  ],
                  if (_order.comment.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_order.comment, maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                  const Spacer(),
                  if (_order.isCancellable)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _cancelling ? null : _cancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          padding: const EdgeInsets.all(14),
                        ),
                        child: _cancelling
                            ? const SizedBox(
                                height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(s.cancelOrder),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
