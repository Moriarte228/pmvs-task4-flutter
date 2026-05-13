import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// Утилита определения платформы и адаптивных параметров экрана.
/// Использует kIsWeb и dart:io Platform для условной логики.
class PlatformUtils {
  PlatformUtils._();

  static bool get isWeb => kIsWeb;

  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  static bool get isLinux {
    if (kIsWeb) return false;
    return Platform.isLinux;
  }

  static bool get isMacOS {
    if (kIsWeb) return false;
    return Platform.isMacOS;
  }

  static bool get isWindows {
    if (kIsWeb) return false;
    return Platform.isWindows;
  }

  /// Мобильная платформа (Android/iOS).
  static bool get isMobile => isAndroid || isIOS;

  /// Desktop-платформа (Linux/macOS/Windows).
  static bool get isDesktop => isLinux || isMacOS || isWindows;
}

/// Брейкпоинты адаптивного дизайна.
class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Тип экрана по ширине.
enum ScreenType { mobile, tablet, desktop }

/// Расширения BuildContext для удобной работы с адаптивностью.
extension ResponsiveContext on BuildContext {
  /// Размер экрана.
  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  /// Тип экрана по ширине.
  ScreenType get screenType {
    final w = screenWidth;
    if (w < Breakpoints.mobile) return ScreenType.mobile;
    if (w < Breakpoints.desktop) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  bool get isMobileScreen => screenType == ScreenType.mobile;
  bool get isTabletScreen => screenType == ScreenType.tablet;
  bool get isDesktopScreen => screenType == ScreenType.desktop;

  /// Процент от ширины экрана.
  double widthPct(double pct) => screenWidth * pct;

  /// Процент от высоты экрана.
  double heightPct(double pct) => screenHeight * pct;

  /// Темная ли сейчас тема.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
