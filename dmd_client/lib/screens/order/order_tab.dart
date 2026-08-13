import 'package:dmd_design/dmd_design.dart';
import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import 'active_order_screen.dart';
import 'create_order_screen.dart';

/// The "Order" tab: shows the active order if there is one (polling for
/// status changes), otherwise a prompt to place a new one.
class OrderTab extends StatefulWidget {
  final String lang;
  final int clientId;

  const OrderTab({super.key, required this.lang, required this.clientId});

  @override
  State<OrderTab> createState() => _OrderTabState();
}

class _OrderTabState extends State<OrderTab> {
  final _api = ApiService();
  bool _loading = true;
  DeliveryOrder? _activeOrder;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final order = await _api.getActiveOrder(widget.clientId);
      if (!mounted) return;
      setState(() => _activeOrder = order);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createOrder() async {
    final placed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateOrderScreen(lang: widget.lang, clientId: widget.clientId),
      ),
    );
    if (placed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: Text(s.retry)),
            ],
          ),
        ),
      );
    }

    if (_activeOrder != null) {
      return ActiveOrderScreen(
        lang: widget.lang,
        clientId: widget.clientId,
        initialOrder: _activeOrder!,
        onOrderClosed: () {
          setState(() => _activeOrder = null);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.appName)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(DmdSpace.xl),
          children: [
            const SizedBox(height: 60),
            DmdEmptyState(
              icon: Icons.local_shipping_outlined,
              message: s.noActiveOrder,
              action: FilledButton.icon(
                onPressed: _createOrder,
                icon: const Icon(Icons.add),
                label: Text(s.newOrder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
