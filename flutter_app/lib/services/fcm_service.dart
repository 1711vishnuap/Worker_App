// lib/services/fcm_service.dart
// Sets up Firebase Cloud Messaging: asks for notification permission,
// grabs the device token and sends it to our backend (so the backend
// knows where to push notifications for this user), and listens for
// foreground messages.

import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/api_constants.dart';
import 'api_service.dart';

class FcmService {
  final ApiService _api = ApiService();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initAndRegister() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await _messaging.getToken();
    if (token != null) {
      await _sendTokenToBackend(token);
    }

    // Keep the backend updated if the token ever refreshes
    _messaging.onTokenRefresh.listen(_sendTokenToBackend);
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _api.put(ApiConstants.updateFcmToken, body: {'fcm_token': token});
    } catch (_) {
      // Non-fatal — push notifications just won't work until this succeeds.
      // See the note at the end of the chat for the small backend
      // endpoint this call expects.
    }
  }

  /// Call this once from main() to see notifications while the app
  /// is open in the foreground (Flutter doesn't show system
  /// notification banners automatically while in foreground).
  void listenForeground(void Function(RemoteMessage message) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }
}
