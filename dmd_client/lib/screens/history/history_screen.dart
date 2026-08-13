import 'package:dmd_design/dmd_design.dart';
import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final String lang;
  final int clientId;

  const HistoryScreen({super.key, required this.lang, required this.clientId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _api = ApiService();
  late Future<List<DeliveryOrder>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getOrderHistory(widget.clientId);
  }

  Future<void> _refresh() async {
    setState(() => _future = _api.getOrderHistory(widget.clientId));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    return Scaffold(
      appBar: AppBar(title: Text(s.tabHistory)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<DeliveryOrder>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 60),
                  DmdEmptyState(icon: Icons.error_outline, message: '${snapshot.error}'),
                ],
              );
            }
            final orders = snapshot.data ?? [];
            if (orders.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 60),
                  DmdEmptyState(icon: Icons.receipt_long_outlined, message: s.historyEmpty),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(DmdSpace.md),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: DmdSpace.sm),
              itemBuilder: (context, i) {
                final o = orders[i];
                final isFreight = o.cargoType == 'freight';
                return Card(
                  child: ListTile(
                    leading: Icon(isFreight ? Icons.local_shipping : Icons.inventory_2_outlined),
                    title: Text('#${o.id} · ${o.price.toStringAsFixed(2)} MDL'),
                    trailing: DmdStatusChip(label: s.statusLabel(o.status), kind: o.statusKind),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
