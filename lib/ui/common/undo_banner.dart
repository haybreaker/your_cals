import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../domain/food.dart';
import '../../state/providers.dart';

/// Floating undo banner anchored directly above the glass dock.
///
/// Rendered inside RootShell's tree via [UndoBannerHost] so placement is
/// exact — SnackBar margins fought the dock and landed mid-screen.
class UndoBannerHost extends StatefulWidget {
  const UndoBannerHost({super.key, required this.child});

  final Widget child;

  @override
  State<UndoBannerHost> createState() => UndoBannerHostState();
}

class UndoBannerHostState extends State<UndoBannerHost>
    with SingleTickerProviderStateMixin {
  UndoRequest? _current;
  Timer? _timer;
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 200),
  );

  static UndoBannerHostState? of(BuildContext context) =>
      context.findAncestorStateOfType<UndoBannerHostState>();

  void show(UndoRequest request) {
    _timer?.cancel();
    setState(() => _current = request);
    _c.forward(from: 0);
    _timer = Timer(const Duration(seconds: 5), _dismiss);
  }

  void _dismiss() {
    if (!mounted || _current == null) return;
    _c.reverse().then((_) {
      if (mounted) setState(() => _current = null);
    });
  }

  void _undo() {
    _timer?.cancel();
    _current?.onUndo();
    _dismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_current != null)
          Positioned(
            left: 20,
            right: 20,
            bottom: 108, // dock height + breathing room
            child: SizeTransition(
              sizeFactor: CurvedAnimation(
                  parent: _c, curve: Curves.easeOutCubic),

              child: FadeTransition(
                opacity: _c,
                child: _Banner(
                  request: _current!,
                  onUndo: _undo,
                  onClose: _dismiss,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class UndoRequest {
  UndoRequest({required this.text, required this.onUndo});
  final String text;
  final Future<void> Function() onUndo;
}

class _Banner extends StatelessWidget {
  const _Banner({required this.request, required this.onUndo, required this.onClose});

  final UndoRequest request;
  final VoidCallback onUndo;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xF0161822),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, size: 17, color: Yc.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(request.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.5)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Yc.calories,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: onUndo,
            child: const Text('UNDO',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          ),
          SizedBox(
            width: 30,
            height: 30,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 16,
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, color: Yc.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Convenience API — finds the host above [context].
/// Call BEFORE popping any sheet (the sheet's context dies on pop).
abstract final class DiaryUndo {
  static void added(BuildContext context, WidgetRef ref, LogEntry entry) {
    UndoBannerHostState.of(context)?.show(UndoRequest(
      text: '${entry.name} added · ${entry.nutr.kcal.round()} kcal',
      onUndo: () => ref.read(diaryRepoProvider).delete(entry.id),
    ));
  }

  static void deleted(BuildContext context, WidgetRef ref, LogEntry entry) {
    UndoBannerHostState.of(context)?.show(UndoRequest(
      text: '${entry.name} deleted',
      onUndo: () => ref.read(diaryRepoProvider).restore(entry),
    ));
  }
}
