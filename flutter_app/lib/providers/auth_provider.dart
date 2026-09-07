// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/fcm_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final FcmService _fcmService = FcmService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  /// Called once on app startup (from splash screen) to restore a
  /// previously saved session.
  Future<void> loadSession() async {
    _user = await _storageService.getUser();
    notifyListeners();
  }

  Future<String?> sendOtp(String mobileNumber) async {
    _setLoading(true);
    try {
      final devOtp = await _authService.sendOtp(mobileNumber);
      _errorMessage = null;
      return devOtp;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp({
    required String mobileNumber,
    required String otp,
    String? userType,
    String? name,
  }) async {
    _setLoading(true);
    try {
      _user = await _authService.verifyOtp(
        mobileNumber: mobileNumber,
        otp: otp,
        userType: userType,
        name: name,
      );
      _errorMessage = null;
      // Register push notification token now that we're logged in
      // (best-effort — never blocks login).
      _fcmService.initAndRegister();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
