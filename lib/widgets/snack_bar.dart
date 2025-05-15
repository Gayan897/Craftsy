import 'package:flutter/material.dart';

enum SnackBarType {
  success,
  error,
  info,
  warning,
}

void showSnackBar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  // Clear any existing SnackBars first
  ScaffoldMessenger.of(context).clearSnackBars();

  // Define colors and icons based on type
  final Color backgroundColor;
  final IconData icon;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = Colors.green.shade800;
      icon = Icons.check_circle_outline;
      break;
    case SnackBarType.error:
      backgroundColor = Colors.red.shade800;
      icon = Icons.error_outline;
      break;
    case SnackBarType.warning:
      backgroundColor = Colors.orange.shade800;
      icon = Icons.warning_amber_outlined;
      break;
    case SnackBarType.info:
    // ignore: unreachable_switch_default
    default:
      backgroundColor = Colors.blue.shade800;
      icon = Icons.info_outline;
  }

  final snackBar = SnackBar(
    content: TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, iconValue, child) {
                    return Transform.scale(
                      scale: iconValue,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Icon(icon, color: Colors.white),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    duration: duration,
    dismissDirection: DismissDirection.horizontal,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

// Optional extended version with action button support
void showExtendedSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
  SnackBarType type = SnackBarType.info,
  String? actionLabel,
  VoidCallback? onActionPressed,
}) {
  // Clear any existing SnackBars first
  ScaffoldMessenger.of(context).clearSnackBars();

  // Define colors and icons based on type
  final Color backgroundColor;
  final IconData icon;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = Colors.green.shade800;
      icon = Icons.check_circle_outline;
      break;
    case SnackBarType.error:
      backgroundColor = Colors.red.shade800;
      icon = Icons.error_outline;
      break;
    case SnackBarType.warning:
      backgroundColor = Colors.orange.shade800;
      icon = Icons.warning_amber_outlined;
      break;
    case SnackBarType.info:
    // ignore: unreachable_switch_default
    default:
      backgroundColor = Colors.blue.shade800;
      icon = Icons.info_outline;
  }

  final snackBar = SnackBar(
    content: TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, iconValue, child) {
                    return Transform.scale(
                      scale: iconValue,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Icon(icon, color: Colors.white),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    duration: duration,
    dismissDirection: DismissDirection.horizontal,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    action: actionLabel != null
        ? SnackBarAction(
            label: actionLabel,
            textColor: Colors.white,
            onPressed: () {
              if (onActionPressed != null) {
                onActionPressed();
              }
            },
          )
        : null,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
