import 'package:flutter/material.dart';

enum SnackBarType { success, warning, error }

class FloatingSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.success,
    Duration duration = const Duration(seconds: 2),
    double width = 300,
  }) {
    final overlay = Overlay.of(context);
    final color = _getBackgroundColor(type);
    final icon = _getIcon(type);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 30,
        left: MediaQuery.of(context).size.width / 2 - width / 2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(duration, () => overlayEntry.remove());
  }

  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.warning:
        return Colors.orange;
      case SnackBarType.error:
        return Colors.red;
    }
  }

  static Icon _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const Icon(Icons.check_circle, color: Colors.white);
      case SnackBarType.warning:
        return const Icon(Icons.warning, color: Colors.white);
      case SnackBarType.error:
        return const Icon(Icons.error, color: Colors.white);
    }
  }
}