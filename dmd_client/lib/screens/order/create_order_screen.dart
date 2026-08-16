import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../services/api_service.dart';
import '../../services/pricing_service.dart';
import '../../widgets/map_point_picker.dart';

class CreateOrderScreen extends StatefulWidget {
  final String lang;
  final int clientId;

  const CreateOrderScreen({super.key, required this.lang, required this.clientId});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _pricing = PricingService();
  final _api = ApiService();

  final _phoneSenderCtrl = TextEditingController();
  final _phoneReceiverCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();

  PickedLocation? _pointA;
  PickedLocation? _pointB;
  String _cargoType = 'standard';

  RouteQuote? _quote;
  bool _quoting = false;
  bool _warmingUp = false;
  bool _submitting = false;
  String? _error;

  Future<void> _pickPoint(bool isA) async {
    final s = AppStrings(widget.lang);
    final result = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(
        builder: (_) => MapPointPicker(
          title: isA ? s.pickPointA : s.pickPointB,
          initial: (isA ? _pointA : _pointB)?.point,
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      if (isA) {
        _pointA = result;
      } else {
        _pointB = result;
      }
    });
    _refreshQuote();
  }

  Future<void> _refreshQuote() async {
    if (_pointA == null || _pointB == null) {
      setState(() => _quote = null);
      return;
    }
    setState(() {
      _quoting = true;
      _warmingUp = false;
    });
    try {
      final quote = await _pricing.quote(
        pointA: _pointA!.point,
        pointB: _pointB!.point,
        cargoType: _cargoType,
        onWarmingUp: () {
          if (mounted) setState(() => _warmingUp = true);
        },
      );
      if (!mounted) return;
      setState(() => _quote = quote);
    } finally {
      if (mounted) setState(() => _quoting = false);
    }
  }

  Future<void> _submit() async {
    final s = AppStrings(widget.lang);
    if (_pointA == null ||
        _pointB == null ||
        _quote == null ||
        _phoneSenderCtrl.text.trim().isEmpty ||
        _phoneReceiverCtrl.text.trim().isEmpty) {
      setState(() => _error = s.fillAllFields);
      return;
    }

    setState(() {
      _submitting = true;
      _warmingUp = false;
      _error = null;
    });

    // The map service may have gone idle between quoting and confirming —
    // same retry pattern as PricingService.quote() instead of letting the
    // request block server-side until it might outrun our HTTP timeout.
    const maxAttempts = 6;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        await _api.createOrder(
          clientId: widget.clientId,
          cargoType: _cargoType,
          latA: _pointA!.point.latitude,
          lonA: _pointA!.point.longitude,
          latB: _pointB!.point.latitude,
          lonB: _pointB!.point.longitude,
          phoneSender: _phoneSenderCtrl.text.trim(),
          phoneReceiver: _phoneReceiverCtrl.text.trim(),
          comment: _commentCtrl.text.trim(),
          price: _quote!.price,
        );
        if (!mounted) return;
        Navigator.of(context).pop(true);
        return;
      } on MapWarmingUpException {
        if (!mounted) return;
        setState(() => _warmingUp = true);
        await Future.delayed(const Duration(seconds: 3));
      } catch (e) {
        if (!mounted) return;
        setState(() => _error = e.toString());
        break;
      }
    }
    if (mounted && _warmingUp) {
      setState(() => _error = s.mapWarmingUp);
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  void dispose() {
    _phoneSenderCtrl.dispose();
    _phoneReceiverCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    return Scaffold(
      appBar: AppBar(title: Text(s.newOrder)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PointTile(
              icon: Icons.trip_origin,
              label: s.pickPointA,
              value: _pointA?.label,
              onTap: () => _pickPoint(true),
            ),
            const SizedBox(height: 8),
            _PointTile(
              icon: Icons.flag,
              label: s.pickPointB,
              value: _pointB?.label,
              onTap: () => _pickPoint(false),
            ),
            const SizedBox(height: 20),
            Text(s.cargoType, style: Theme.of(context).textTheme.titleMedium),
            RadioGroup<String>(
              groupValue: _cargoType,
              onChanged: (v) {
                setState(() => _cargoType = v!);
                _refreshQuote();
              },
              child: Column(
                children: [
                  RadioListTile<String>(value: 'standard', title: Text(s.cargoStandard)),
                  RadioListTile<String>(value: 'freight', title: Text(s.cargoFreight)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneSenderCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: s.phoneSender, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneReceiverCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: s.phoneReceiver, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              decoration: InputDecoration(labelText: s.comment, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            if (_quoting)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    if (_warmingUp) ...[
                      const SizedBox(height: 12),
                      Text(s.mapWarmingUp, textAlign: TextAlign.center),
                    ],
                  ],
                ),
              ),
            if (_quote != null && !_quoting)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.estimatedPrice),
                      Text(
                        '${_quote!.price.toStringAsFixed(2)} MDL',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting || _quote == null ? null : _submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(s.confirmOrder),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _PointTile({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: value != null ? Text(value!) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
