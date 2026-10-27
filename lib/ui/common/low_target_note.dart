import 'package:flutter/material.dart';

import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../domain/profile.dart';

/// Gentle caution shown when an auto target lands under 1200 kcal.
/// Informational only — muted tertiary copy with an info glyph, never
/// red, never blocking. Self-hides at/above the threshold.
class LowTargetNote extends StatelessWidget {
  const LowTargetNote({super.key, required this.kcalTarget});

  final int kcalTarget;

  @override
  Widget build(BuildContext context) {
    if (kcalTarget >= Goals.lowTargetNote) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: Yc.textTertiary,
            ),
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              'Below 1,200 kcal — please be careful.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppText.footnote,
                color: Yc.textTertiary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
