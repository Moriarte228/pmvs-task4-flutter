import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/platform_utils.dart';

/// Кроссплатформенный сервис уведомлений.
///
/// Для Android/iOS — Toast через fluttertoast.
/// Для Linux/Web — SnackBar (Toast у fluttertoast на десктопе работает
/// нестабильно).
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  /// Показывает уведомление с учётом платформы.
  void show(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 2),
      Color? backgroundColor}) {
    try {
      if (PlatformUtils.isMobile) {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: backgroundColor ?? Colors.black87,
          textColor: Colors.white,
        );
      } else {
        // Desktop / Web — SnackBar
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: duration,
            backgroundColor: backgroundColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // На случай, если контекст недоступен — пишем в консоль.
      debugPrint('NotificationService error: $e');
      debugPrint('Message: $message');
    }
  }

  /// Показывает уведомление об успехе.
  void success(BuildContext context, String message) {
    show(context, message, backgroundColor: Colors.green.shade700);
  }

  /// Показывает уведомление об ошибке.
  void error(BuildContext context, String message) {
    show(context, message, backgroundColor: Colors.red.shade700);
  }
}
