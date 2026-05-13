import 'package:shared_preferences/shared_preferences.dart';

/// Простой сервис аутентификации.
///
/// Сессия сохраняется в SharedPreferences (email и флаг входа).
/// Принимает любой email/пароль (минимум 6 символов) — обучающая реализация.
class AuthService {
  static const _kEmail = 'auth_email';
  static const _kLoggedIn = 'auth_logged_in';

  /// Проверка email — простой regex.
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Возвращает true, если пользователь авторизован.
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kLoggedIn) ?? false;
    } catch (e) {
      // ignore: avoid_print
      print('AuthService.isLoggedIn error: $e');
      return false;
    }
  }

  /// Возвращает email текущего пользователя или null.
  Future<String?> currentEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kEmail);
    } catch (e) {
      // ignore: avoid_print
      print('AuthService.currentEmail error: $e');
      return null;
    }
  }

  /// Пытается выполнить вход.
  /// Бросает [AuthException] при ошибке валидации.
  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty) {
      throw AuthException(AuthErrorType.emailRequired);
    }
    if (!_emailRegex.hasMatch(email.trim())) {
      throw AuthException(AuthErrorType.emailInvalid);
    }
    if (password.isEmpty) {
      throw AuthException(AuthErrorType.passwordRequired);
    }
    if (password.length < 6) {
      throw AuthException(AuthErrorType.passwordTooShort);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kEmail, email.trim());
      await prefs.setBool(_kLoggedIn, true);
    } catch (e) {
      // ignore: avoid_print
      print('AuthService.login save error: $e');
      throw AuthException(AuthErrorType.unknown);
    }
  }

  /// Выход — очистка флага.
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kLoggedIn, false);
      await prefs.remove(_kEmail);
    } catch (e) {
      // ignore: avoid_print
      print('AuthService.logout error: $e');
    }
  }
}

enum AuthErrorType {
  emailRequired,
  emailInvalid,
  passwordRequired,
  passwordTooShort,
  invalidCredentials,
  unknown,
}

class AuthException implements Exception {
  final AuthErrorType type;
  AuthException(this.type);

  @override
  String toString() => 'AuthException: $type';
}
