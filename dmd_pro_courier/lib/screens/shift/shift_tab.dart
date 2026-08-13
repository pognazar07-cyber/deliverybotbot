import 'dart:async';

import 'package:dmd_design/dmd_design.dart';
import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/courier_order.dart';
import '../../services/api_service.dart';
import '../delivery/active_delivery_screen.dart';

/// The "Shift" tab: online/offline toggle + live feed of available orders,
/// or the active delivery screen if the courier already has one in hand.
class ShiftTab extends StatefulWidget {
  final String lang;
  final int courierId;

  const ShiftTab({super.key, required this.lang, required this.courierId});

  @override
  State<ShiftTab> createState() => _ShiftTabState();
}

class _ShiftTabState extends State<ShiftTab> {
  final _api = ApiService();

  bool _loading = true;
  bool _online = false;
  bool _togglingShift = false;
  CourierOrder? _activeOrder;
  List<CourierOrder> _available = [];
  String? _error;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _poll = Timer.periodic(const Duration(seconds: 8), (_) => _refreshQuietly());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = await _api.getStatus(widget.courierId);
      final active = await _api.getActiveOrder(widget.courierId);
      List<CourierOrder> available = [];
      if (active == null && status.isOnline) {
        available = await _api.getAvailableOrders(widget.courierId);
      }
      if (!mounted) return;
      setState(() {
        _online = status.isOnline;
        _activeOrder = active;
        _available = available;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshQuietly() async {
    // While a delivery is active, ActiveDeliveryScreen owns the screen (and
    // its own location-reporting timer); this loop's job — surfacing new
    // available orders — has nothing to do until that delivery closes.
    if (!mounted || _togglingShift || _activeOrder != null) return;
    try {
      final active = await _api.getActiveOrder(widget.courierId);
      if (!mounted) return;
      if (active != null) {
        setState(() => _activeOrder = active);
        return;
      }
      if (_online) {
        final available = await _api.getAvailableOrders(widget.courierId);
        if (!mounted) return;
        setState(() {
          _activeOrder = null;
          _available = available;
        });
      } else if (_activeOrder != null) {
        setState(() => _activeOrder = null);
      }
    } catch (_) {
      // Keep showing the last known state; next tick retries.
    }
  }

  Future<void> _toggleShift(bool goOnline) async {
    setState(() => _togglingShift = true);
    try {
      if (goOnline) {
        await _api.goOnline(widget.courierId);
      } else {
        await _api.goOffline(widget.courierId);
      }
      if (!mounted) return;
      setState(() => _online = goOnline);
      await _refreshQuietly();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _togglingShift = false);
    }
  }

  Future<void> _accept(CourierOrder order) async {
    try {
      final accepted = await _api.acceptOrder(orderId: order.id, courierId: widget.courierId);
      if (!mounted) return;
      setState(() => _activeOrder = accepted);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: DmdEmptyState(
          icon: Icons.error_outline,
          message: _error!,
          action: FilledButton(onPressed: _bootstrap, child: Text(s.retry)),
        ),
      );
    }

    if (_activeOrder != null) {
      return ActiveDeliveryScreen(
        lang: widget.lang,
        courierId: widget.courierId,
        initialOrder: _activeOrder!,
        onOrderClosed: () {
          setState(() => _activeOrder = null);
          _refreshQuietly();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(s.appName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: DmdSpace.lg),
            child: Row(
              children: [
                Text(_online ? s.onShift : s.offShift, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: DmdSpace.sm),
                Switch(
                  value: _online,
                  onChanged: _togglingShift ? null : _toggleShift,
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _bootstrap,
        child: !_online
            ? ListView(
                children: [
                  const SizedBox(height: 80),
                  DmdEmptyState(icon: Icons.bedtime_outlined, message: s.goOnlinePrompt),
                ],
              )
            : _available.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      DmdEmptyState(icon: Icons.inbox_outlined, message: s.noOrdersYet),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(DmdSpace.md),
                    itemCount: _available.length,
                    separatorBuilder: (_, _) => const SizedBox(height: DmdSpace.sm),
                    itemBuilder: (context, i) {
                      final o = _available[i];
                      final isFreight = o.cargoType == 'freight';
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(DmdSpace.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(isFreight ? Icons.local_shipping : Icons.inventory_2_outlined),
                                      const SizedBox(width: DmdSpace.sm),
                                      Text(s.cargoLabel(o.cargoType)),
                                    ],
                                  ),
                                  Text(
                                    '${o.price.toStringAsFixed(2)} MDL',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              if (o.comment.isNotEmpty) ...[
                                const SizedBox(height: DmdSpace.sm),
                                Text(o.comment, maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                              const SizedBox(height: DmdSpace.md),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () => _accept(o),
                                  child: Text(s.acceptOrder),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
