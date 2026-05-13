import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;

  bool _isLoggedIn = false;
  String? _email;
  bool _isLoading = false;
  AuthErrorType? _error;

  AuthProvider({AuthService? service}) : _service = service ?? AuthService();

  bool get isLoggedIn => _isLoggedIn;
  String? get email => _email;
  bool get isLoading => _isLoading;
  AuthErrorType? get error => _error;

  /// Загрузить состояние сессии при старте приложения.
  Future<void> bootstrap() async {
    _isLoading = true;
    notifyListeners();
    try {
      _isLoggedIn = await _service.isLoggedIn();
      _email = await _service.currentEmail();
    } catch (e) {
      // ignore: avoid_print
      print('AuthProvider.bootstrap error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.login(email, password);
      _isLoggedIn = true;
      _email = email.trim();
      return true;
    } on AuthException catch (e) {
      _error = e.type;
      return false;
    } catch (e) {
      _error = AuthErrorType.unknown;
      // ignore: avoid_print
      print('AuthProvider.login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _isLoggedIn = false;
    _email = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
