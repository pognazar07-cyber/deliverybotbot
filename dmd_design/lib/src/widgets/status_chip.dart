import 'package:flutter/material.dart';

import '../colors.dart';

enum DmdStatusKind { pending, inProgress, success, danger, warning }

/// A small colored pill for order/ticket statuses. Callers own the label
/// text (so each app can localize it); this widget just owns the color
/// language so "danger" always looks the same everywhere.
class DmdStatusChip extends StatelessWidget {
  final String label;
  final DmdStatusKind kind;

  const DmdStatusChip({super.key, required this.label, required this.kind});

  Color get _color => switch (kind) {
        DmdStatusKind.pending => DmdStatusColors.pending,
        DmdStatusKind.inProgress => DmdStatusColors.inProgress,
        DmdStatusKind.success => DmdStatusColors.success,
        DmdStatusKind.danger => DmdStatusColors.danger,
        DmdStatusKind.warning => DmdStatusColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
