import 'package:dmd_design/dmd_design.dart';
import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final String lang;
  final int courierId;

  const HistoryScreen({super.key, required this.lang, required this.courierId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _api = ApiService();
  late Future<CourierHistory> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getHistory(widget.courierId);
  }

  Future<void> _refresh() async {
    setState(() => _future = _api.getHistory(widget.courierId));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    return Scaffold(
      appBar: AppBar(title: Text(s.tabHistory)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<CourierHistory>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  DmdEmptyState(icon: Icons.error_outline, message: '${snapshot.error}'),
                ],
              );
            }
            final history = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(DmdSpace.lg),
              children: [
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(DmdSpace.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.earningsThisMonth),
                        const SizedBox(height: DmdSpace.xs),
                        Text(
                          '${history.earningsThisMonth.toStringAsFixed(2)} MDL',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: DmdSpace.xs),
                        Text('${history.completedThisMonth} ${s.ordersThisMonth}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DmdSpace.lg),
                if (history.orders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: DmdSpace.xxl),
                    child: DmdEmptyState(icon: Icons.receipt_long_outlined, message: s.historyEmpty),
                  )
                else
                  ...history.orders.map((o) => Padding(
                        padding: const EdgeInsets.only(bottom: DmdSpace.sm),
                        child: Card(
                          child: ListTile(
                            leading: Icon(o.cargoType == 'freight'
                                ? Icons.local_shipping
                                : Icons.inventory_2_outlined),
                            title: Text('#${o.id} · ${o.price.toStringAsFixed(2)} MDL'),
                            trailing: DmdStatusChip(label: s.statusLabel(o.status), kind: o.statusKind),
                          ),
                        ),
                      )),
              ],
            );
          },
        ),
      ),
    );
  }
}
