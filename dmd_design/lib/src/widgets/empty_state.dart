import 'package:flutter/material.dart';

import '../spacing.dart';

/// Shared "nothing here yet" placeholder used across list/tab screens in
/// both apps (empty history, no active order, no tickets, ...).
class DmdEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Widget? action;

  const DmdEmptyState({super.key, required this.icon, required this.message, this.action});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DmdSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: DmdSpace.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
            ),
            if (action != null) ...[
              const SizedBox(height: DmdSpace.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
