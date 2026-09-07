// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/app_theme.dart';
import 'config/app_routes.dart';
import 'providers/auth_provider.dart';
import 'providers/work_provider.dart';
import 'providers/worker_provider.dart';

import 'screens/common/splash_screen.dart';
import 'screens/common/login_screen.dart';
import 'screens/common/otp_screen.dart';

import 'screens/customer/customer_home_screen.dart';
import 'screens/customer/add_work_screen.dart';
import 'screens/customer/select_category_screen.dart';
import 'screens/customer/work_details_screen.dart';
import 'screens/customer/my_works_screen.dart';
import 'screens/customer/work_tracking_screen.dart';
import 'screens/customer/worker_map_screen.dart';
import 'screens/customer/show_otp_screen.dart';
import 'screens/customer/completed_work_screen.dart';

import 'screens/worker/worker_home_screen.dart';
import 'screens/worker/select_categories_screen.dart';
import 'screens/worker/available_works_screen.dart';
import 'screens/worker/work_details_screen.dart';
import 'screens/worker/accepted_work_screen.dart';
import 'screens/worker/navigation_map_screen.dart';
import 'screens/worker/enter_otp_screen.dart';
import 'screens/worker/work_completed_screen.dart';
import 'screens/worker/work_history_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkProvider()),
        ChangeNotifierProvider(create: (_) => WorkerProvider()),
      ],
      child: MaterialApp(
        title: 'Service Marketplace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.otp: (_) => const OtpScreen(),

          // Customer
          AppRoutes.customerHome: (_) => const CustomerHomeScreen(),
          AppRoutes.addWork: (_) => const AddWorkScreen(),
          AppRoutes.selectCategory: (_) => const SelectCategoryScreen(),
          AppRoutes.customerWorkDetails: (_) => const WorkDetailsScreen(),
          AppRoutes.myWorks: (_) => const MyWorksScreen(),
          AppRoutes.workTracking: (_) => const WorkTrackingScreen(),
          AppRoutes.workerMap: (_) => const WorkerMapScreen(),
          AppRoutes.showOtp: (_) => const ShowOtpScreen(),
          AppRoutes.completedWork: (_) => const CompletedWorkScreen(),

          // Worker
          AppRoutes.workerHome: (_) => const WorkerHomeScreen(),
          AppRoutes.selectCategories: (_) => const SelectCategoriesScreen(),
          AppRoutes.availableWorks: (_) => const AvailableWorksScreen(),
          AppRoutes.workerWorkDetails: (_) => const WorkerWorkDetailsScreen(),
          AppRoutes.acceptedWork: (_) => const AcceptedWorkScreen(),
          AppRoutes.navigationMap: (_) => const NavigationMapScreen(),
          AppRoutes.workerEnterOtp: (_) => const WorkerEnterOtpScreen(),
          AppRoutes.workCompleted: (_) => const WorkCompletedScreen(),
          AppRoutes.workHistory: (_) => const WorkHistoryScreen(),
        },
      ),
    );
  }
}
