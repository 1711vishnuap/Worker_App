import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:service_marketplace/config/app_routes.dart';
import 'package:service_marketplace/config/app_theme.dart';
import 'package:service_marketplace/models/category_model.dart';
import 'package:service_marketplace/models/user_model.dart';
import 'package:service_marketplace/models/work_model.dart';
import 'package:service_marketplace/providers/auth_provider.dart';
import 'package:service_marketplace/providers/work_provider.dart';
import 'package:service_marketplace/providers/worker_provider.dart';
import 'package:service_marketplace/screens/common/login_screen.dart';
import 'package:service_marketplace/screens/customer/customer_home_screen.dart';
import 'package:service_marketplace/screens/customer/select_category_screen.dart';
import 'package:service_marketplace/screens/worker/worker_home_screen.dart';
import 'package:service_marketplace/screens/worker/select_categories_screen.dart';
import 'package:service_marketplace/widgets/marketplace_widgets.dart';

class FixtureAuth extends AuthProvider {
  final bool worker;
  FixtureAuth({this.worker = false});
  @override
  UserModel get user => UserModel(
      id: 1,
      mobileNumber: '971500000000',
      name: 'Alex',
      userType: worker ? 'worker' : 'customer');
}

class FixtureWorks extends WorkProvider {
  bool failCategories;
  int categoryLoads = 0;
  FixtureWorks({this.failCategories = false}) {
    myWorks = [
      WorkModel(
          id: 1,
          customerId: 1,
          categoryId: 1,
          categoryName: 'Plumber',
          title: 'Kitchen tap repair',
          customerLat: 25,
          customerLng: 55,
          status: WorkStatus.accepted,
          createdAt: '2026-09-10')
    ];
  }
  @override
  Future<void> loadCategories() async {
    categoryLoads++;
    categoriesError = failCategories ? 'Connection failed' : null;
    categories = failCategories
        ? []
        : [
            CategoryModel(id: 1, name: 'Plumber'),
            CategoryModel(id: 2, name: 'Electrician'),
            CategoryModel(id: 3, name: 'Carpenter'),
            CategoryModel(id: 4, name: 'Cleaning'),
            CategoryModel(id: 5, name: 'AC Repair'),
          ];
    notifyListeners();
  }

  @override
  Future<void> loadMyWorks() async {
    notifyListeners();
  }
}

class FixtureWorker extends WorkerProvider {
  @override
  Future<void> ensureProfile() async {}
  @override
  Future<void> loadAvailableWorks() async {
    notifyListeners();
  }
}

final previewKey = GlobalKey();

Widget harness(Widget screen,
        {FixtureWorks? works,
        double scale = 1,
        bool worker = false,
        RouteFactory? onGenerateRoute}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
            create: (_) => FixtureAuth(worker: worker)),
        ChangeNotifierProvider<WorkProvider>(
            create: (_) => works ?? FixtureWorks()),
        ChangeNotifierProvider<WorkerProvider>(create: (_) => FixtureWorker()),
      ],
      child: RepaintBoundary(
          key: previewKey,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: screen,
            onGenerateRoute: onGenerateRoute,
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!),
          )),
    );

Future<void> setSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> preview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('UPDATE_PREVIEWS')) return;
  await tester.runAsync(() async {
    final boundary =
        previewKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('../docs/ui-$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  testWidgets(
      'Services search filters results and passes the selected category to booking',
      (tester) async {
    await setSize(tester, const Size(390, 844));
    CategoryModel? selected;
    await tester.pumpWidget(
        harness(const SelectCategoryScreen(), onGenerateRoute: (settings) {
      expect(settings.name, AppRoutes.addWork);
      selected = settings.arguments! as CategoryModel;
      return MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Booking form')));
    }));
    await tester.pumpAndSettle();
    await preview(tester, 'services');
    await tester.enterText(find.byType(TextField), '  PLUMB ');
    await tester.pumpAndSettle();
    expect(find.text('Plumber'), findsOneWidget);
    expect(find.text('Electrician'), findsNothing);
    await tester.tap(find.text('Plumber'));
    await tester.pumpAndSettle();
    expect(selected?.id, 1);
    expect(find.text('Booking form'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Category failures have a retry that recovers to real results',
      (tester) async {
    await setSize(tester, const Size(390, 844));
    final works = FixtureWorks(failCategories: true);
    await tester
        .pumpWidget(harness(const SelectCategoryScreen(), works: works));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Try again'), findsOneWidget);
    works.failCategories = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(works.categoryLoads, 2);
    expect(find.text('Plumber'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'not a service');
    await tester.pumpAndSettle();
    expect(find.text('No services found. Try a different search.'),
        findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.byType(ServiceCategoryTile), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home navigation reaches services, bookings and account',
      (tester) async {
    await setSize(tester, const Size(390, 844));
    await tester.pumpWidget(harness(const CustomerHomeScreen()));
    await tester.pumpAndSettle();
    await preview(tester, 'home');
    await tester.tap(find.text('Find a service'));
    await tester.pumpAndSettle();
    expect(find.text('Search services'), findsOneWidget);
    await tester.tap(find.byType(NavigationDestination).at(2));
    await tester.pumpAndSettle();
    expect(find.text('Kitchen tap repair'), findsOneWidget);
    await tester.tap(find.byType(NavigationDestination).at(3));
    await tester.pumpAndSettle();
    expect(find.text('971500000000'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login and worker home render with local assets', (tester) async {
    await setSize(tester, const Size(390, 844));
    await tester.pumpWidget(harness(const LoginScreen()));
    await tester.pumpAndSettle();
    await preview(tester, 'welcome');
    expect(find.text('Continue'), findsOneWidget);
    const channel = MethodChannel('flutter.baseflow.com/geolocator');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => false);
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(harness(const WorkerHomeScreen(), worker: true));
    await tester.pumpAndSettle();
    await preview(tester, 'worker');
    expect(find.text('Work near you'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Core screens support a small phone and enlarged text without overflow',
      (tester) async {
    await setSize(tester, const Size(320, 568));
    for (final screen in [
      const LoginScreen(),
      const CustomerHomeScreen(),
      const SelectCategoryScreen(),
      const SelectCategoriesScreen(),
    ]) {
      await tester.pumpWidget(harness(screen, scale: 1.6));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: '${screen.runtimeType} initial layout');
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -450));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: '${screen.runtimeType} scrolled layout');
    }
  });
}
