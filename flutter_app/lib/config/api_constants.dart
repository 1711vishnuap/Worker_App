// lib/config/api_constants.dart
//
// EVERY API URL IN THE APP COMES FROM THIS FILE.
// Screens and services never hardcode a URL — they call ApiService,
// which reads endpoints from here. Change the base URL in ONE place
// when moving from local dev to a real server.

class ApiConstants {
  ApiConstants._();

  // ---------------------------------------------------------------
  // BASE URL — change this depending on where your backend is running
  // ---------------------------------------------------------------
  // Defaults to the current development Mac on the same Wi-Fi as the phone.
  // Override per device/network without editing source:
  // flutter run --dart-define=API_BASE_URL=http://<mac-lan-ip>:3001/api
  // Android emulator: http://10.0.2.2:3001/api
  // iOS simulator: http://127.0.0.1:3001/api
  // Production: use the deployed API's HTTPS URL.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.60.189.216:3001/api',
  );

  // ---------------------------------------------------------------
  // AUTH
  // ---------------------------------------------------------------
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';

  // ---------------------------------------------------------------
  // WORKS (customer + worker actions on the works resource)
  // ---------------------------------------------------------------
  static const String works = '/works';
  static String myWorks = '/works/my';
  static String workById(dynamic id) => '/works/$id';
  static String cancelWork(dynamic id) => '/works/$id';
  static String updateWork(dynamic id) => '/works/$id';
  static String workWorker(dynamic id) => '/works/$id/worker';

  static String acceptWork(dynamic id) => '/works/$id/accept';
  static String verifyWorkOtp(dynamic id) => '/works/$id/verify-otp';
  static String completeWork(dynamic id) => '/works/$id/complete';

  // ---------------------------------------------------------------
  // WORKERS
  // ---------------------------------------------------------------
  static const String workerProfile = '/workers/profile';
  static const String workerCategories = '/workers/categories';
  static const String workerLocation = '/workers/location';
  static const String availableWorks = '/workers/available-works';
  static const String workerHistory =
      '/workers/history'; // see note at end of chat

  // ---------------------------------------------------------------
  // CATEGORIES + USER
  // NOTE: these two endpoints are small additions on top of the
  // backend built earlier — see the note at the end of this chat
  // for the ~10 lines to add on the server. Everything else in this
  // app talks to the exact endpoints already built.
  // ---------------------------------------------------------------
  static const String categories = '/categories';
  static const String updateFcmToken = '/users/fcm-token';
}
