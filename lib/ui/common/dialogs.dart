import 'package:flutter/material.dart';

import '../../core/glass.dart';
import '../../core/theme.dart';

/// Liquid-glass confirmation dialog. Returns true when confirmed.
Future<bool> confirmGlassDialog(
  BuildContext context, {
  required String title,
  String? body,
  String confirmLabel = 'Delete',
  Color confirmColor = Yc.danger,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => PopScope(
      canPop: false,
      child: Center(
        child: Glass(
          radius: 28,
          blur: 30,
          opacity: 0.14,
          margin: const EdgeInsets.symmetric(horizontal: 36),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16.5, fontWeight: FontWeight.w700)),
              if (body != null) ...[
                const SizedBox(height: 8),
                Text(body,
                    style: const TextStyle(
                        fontSize: 13.5,
                        color: Yc.textSecondary,
                        height: 1.35)),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Yc.textPrimary,
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.2)),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(confirmLabel,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}
