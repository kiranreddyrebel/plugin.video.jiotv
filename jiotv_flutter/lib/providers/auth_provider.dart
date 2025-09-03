import 'package:flutter/material.dart';
import 'package:jiotv_flutter/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    _isLoggedIn = await _authService.isLoggedIn();
    notifyListeners();
  }

  Future<String?> login(String username, String password) async {
    final error = await _authService.login(username, password);
    if (error == null) {
      _isLoggedIn = true;
      notifyListeners();
    }
    return error;
  }

  Future<String?> sendOtp(String mobile) async {
    return await _authService.sendOtp(mobile);
  }

  Future<String?> verifyOtp(String mobile, String otp) async {
    final error = await _authService.verifyOtp(mobile, otp);
    if (error == null) {
      _isLoggedIn = true;
      notifyListeners();
    }
    return error;
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
