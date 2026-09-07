// lib/services/auth_service.dart
//
// NOTE ON OTP: This MVP's backend generates and checks the OTP itself
// (see backend/src/modules/auth/auth.service.js), rather than using
// full Firebase Phone Auth. That keeps the whole login flow testable
// without setting up SHA keys / billing on Firebase first. If you
// later switch the backend to real Firebase Phone Auth, only this
// file needs to change (send the Firebase ID token instead of a
// typed OTP) — everything else in the app stays the same.

import '../config/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  Future<String?> sendOtp(String mobileNumber) async {
    final data = await _api.post(
      ApiConstants.sendOtp,
      body: {'mobile_number': mobileNumber},
      auth: false,
    );
    // In development the backend returns the OTP directly so you can
    // test without a real SMS gateway. This will be null in production.
    return data['dev_otp'] as String?;
  }

  Future<UserModel> verifyOtp({
    required String mobileNumber,
    required String otp,
    String? userType,
    String? name,
  }) async {
    final data = await _api.post(
      ApiConstants.verifyOtp,
      body: {
        'mobile_number': mobileNumber,
        'otp': otp,
        if (userType != null) 'user_type': userType,
        if (name != null) 'name': name,
      },
      auth: false,
    );

    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user']);
    await _storage.saveSession(token, user);
    return user;
  }

  Future<void> logout() async {
    await _storage.clear();
  }
}
