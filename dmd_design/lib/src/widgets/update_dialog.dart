import 'package:flutter/material.dart';

import '../update_info.dart';

/// Shows the "a new version is available" dialog. If [info.forceUpdate] is
/// true, the dialog has no dismiss action — the caller decides what that
/// means (typically: block the app until the user updates).
Future<void> showDmdUpdateDialog(
  BuildContext context, {
  required DmdAppUpdateInfo info,
  required String title,
  required String updateNowLabel,
  required String laterLabel,
  required VoidCallback onUpdateNow,
}) {
  return showDialog(
    context: context,
    barrierDismissible: !info.forceUpdate,
    builder: (context) => PopScope(
      canPop: !info.forceUpdate,
      child: AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (info.updateMessage.isNotEmpty) Text(info.updateMessage),
              if (info.newFeatures.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final feature in info.newFeatures)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(child: Text(feature)),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        actions: [
          if (!info.forceUpdate)
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(laterLabel)),
          FilledButton(onPressed: onUpdateNow, child: Text(updateNowLabel)),
        ],
      ),
    ),
  );
}
