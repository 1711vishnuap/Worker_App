// lib/config/app_routes.dart
// Every screen navigation uses these named constants instead of raw
// strings, so a typo shows up as a compile error, not a runtime bug.

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';

  // Customer
  static const customerHome = '/customer/home';
  static const addWork = '/customer/add-work';
  static const selectCategory = '/customer/select-category';
  static const customerWorkDetails = '/customer/work-details';
  static const myWorks = '/customer/my-works';
  static const workTracking = '/customer/work-tracking';
  static const workerMap = '/customer/worker-map';
  static const showOtp = '/customer/show-otp';
  static const completedWork = '/customer/completed-work';

  // Worker
  static const workerHome = '/worker/home';
  static const selectCategories = '/worker/select-categories';
  static const availableWorks = '/worker/available-works';
  static const workerWorkDetails = '/worker/work-details';
  static const acceptedWork = '/worker/accepted-work';
  static const navigationMap = '/worker/navigation-map';
  static const workerEnterOtp = '/worker/enter-otp';
  static const workCompleted = '/worker/work-completed';
  static const workHistory = '/worker/work-history';
}
