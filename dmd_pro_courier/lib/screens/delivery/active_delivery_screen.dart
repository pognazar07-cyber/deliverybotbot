import 'dart:async';

import 'package:dmd_design/dmd_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/strings.dart';
import '../../models/courier_order.dart';
import '../../services/api_service.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  final String lang;
  final int courierId;
  final CourierOrder initialOrder;
  final VoidCallback onOrderClosed;

  const ActiveDeliveryScreen({
    super.key,
    required this.lang,
    required this.courierId,
    required this.initialOrder,
    required this.onOrderClosed,
  });

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  final _api = ApiService();
  late CourierOrder _order;
  bool _advancing = false;
  Timer? _locationTimer;
  LatLng? _myPosition;

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder;
    _locationTimer = Timer.periodic(const Duration(seconds: 15), (_) => _reportLocation());
    _reportLocation();
  }

  Future<void> _reportLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _myPosition = LatLng(pos.latitude, pos.longitude));
      await _api.reportLocation(telegramId: widget.courierId, lat: pos.latitude, lon: pos.longitude);
    } catch (_) {
      // Best-effort — a missed location ping isn't worth surfacing to the courier.
    }
  }

  Future<void> _callPhone(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    await launchUrl(Uri.parse('tel:$phone'));
  }

  Future<void> _advance() async {
    final next = _order.nextStatus;
    if (next == null) return;

    setState(() => _advancing = true);
    try {
      await _api.updateOrderStatus(orderId: _order.id, courierId: widget.courierId, status: next);
      if (!mounted) return;
      if (next == 'completed') {
        widget.onOrderClosed();
        return;
      }
      setState(() => _order = _order.copyWith(status: next));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _advancing = false);
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    final pointA = LatLng(_order.latA, _order.lonA);
    final pointB = LatLng(_order.latB, _order.lonB);
    final destination = _order.status == 'accepted' ? pointA : pointB;
    final bounds = LatLngBounds.fromPoints([pointA, pointB]);
    final nextLabel = _order.nextStatus != null ? s.actionLabelFor(_order.nextStatus!) : '';

    return Scaffold(
      appBar: AppBar(title: Text(s.activeDeliveryTitle)),
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
                  userAgentPackageName: 'com.deliverymd.dmd_pro_courier',
                ),
                PolylineLayer(polylines: [
                  Polyline(
                    points: _order.route.isNotEmpty ? _order.route : [pointA, pointB],
                    strokeWidth: 4,
                    color: Colors.deepOrange,
                  ),
                ]),
                MarkerLayer(markers: [
                  Marker(
                    point: pointA,
                    width: 36,
                    height: 36,
                    child: Icon(Icons.trip_origin,
                        color: destination == pointA ? Colors.deepOrange : Colors.grey, size: 32),
                  ),
                  Marker(
                    point: pointB,
                    width: 36,
                    height: 36,
                    child: Icon(Icons.flag,
                        color: destination == pointB ? Colors.deepOrange : Colors.grey, size: 32),
                  ),
                  if (_myPosition != null)
                    Marker(
                      point: _myPosition!,
                      width: 48,
                      height: 48,
                      child: const DmdLiveLocationDot(color: Color(0xFFE8720C)),
                    ),
                ]),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DmdSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DmdStatusChip(label: s.statusLabel(_order.status), kind: _order.statusKind),
                  const SizedBox(height: DmdSpace.sm),
                  Text('#${_order.id} · ${_order.price.toStringAsFixed(2)} MDL',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (_order.comment.isNotEmpty) ...[
                    const SizedBox(height: DmdSpace.sm),
                    Text(_order.comment),
                  ],
                  const SizedBox(height: DmdSpace.lg),
                  if (_order.phoneSender != null)
                    _ContactTile(label: s.senderPhone, phone: _order.phoneSender!, onCall: _callPhone),
                  if (_order.phoneReceiver != null) ...[
                    const SizedBox(height: DmdSpace.sm),
                    _ContactTile(label: s.receiverPhone, phone: _order.phoneReceiver!, onCall: _callPhone),
                  ],
                  const SizedBox(height: DmdSpace.xl),
                  if (nextLabel.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _advancing ? null : _advance,
                        child: _advancing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(nextLabel),
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

class _ContactTile extends StatelessWidget {
  final String label;
  final String phone;
  final ValueChanged<String> onCall;

  const _ContactTile({required this.label, required this.phone, required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.phone_outlined),
        title: Text(label),
        subtitle: Text(phone),
        trailing: IconButton(icon: const Icon(Icons.call), onPressed: () => onCall(phone)),
      ),
    );
  }
}
