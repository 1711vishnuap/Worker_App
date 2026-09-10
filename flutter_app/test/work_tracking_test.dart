import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_marketplace/config/app_routes.dart';
import 'package:service_marketplace/models/work_model.dart';
import 'package:service_marketplace/screens/customer/work_tracking_screen.dart';
import 'widget_test.dart' show FixtureWorks, harness, setSize, preview;

WorkModel booking(
        {WorkStatus status = WorkStatus.posted,
        String title = 'AC isn’t cooling',
        String? description = 'The bedroom unit runs, but the air is warm.'}) =>
    WorkModel(
      id: 42,
      customerId: 1,
      categoryId: 5,
      categoryName: 'AC Repair',
      title: title,
      description: description,
      customerLat: 25,
      customerLng: 55,
      status: status,
      createdAt: '2026-09-10 18:40:00',
      otpCode: '1234',
    );

class TrackingFixture extends FixtureWorks {
  WorkModel record;
  bool failLoad = false, failSave = false;
  int loads = 0, cancellations = 0, updates = 0;
  TrackingFixture({WorkStatus status = WorkStatus.posted})
      : record = booking(status: status);
  @override
  Future<void> loadWorkById(int id) async {
    loads++;
    errorMessage = failLoad ? 'Connection failed' : null;
    if (!failLoad) currentWork = record;
    notifyListeners();
  }

  @override
  Future<bool> updateWork(int workId,
      {required String title, String? description}) async {
    updates++;
    errorMessage = failSave ? 'Could not save. Please try again.' : null;
    if (!failSave) {
      record = booking(
          status: record.status, title: title, description: description);
      currentWork = record;
    }
    notifyListeners();
    return !failSave;
  }

  @override
  Future<bool> cancelWork(int workId) async {
    cancellations++;
    record = record.copyWithStatus(WorkStatus.cancelled);
    notifyListeners();
    return true;
  }
}

Future<void> openTracking(WidgetTester tester, TrackingFixture works,
    {double scale = 1, void Function(RouteSettings)? onRoute}) async {
  await tester.pumpWidget(harness(
      Builder(
          builder: (context) => Scaffold(
                  body: Center(
                      child: TextButton(
                onPressed: () => Navigator.pushNamed(
                    context, AppRoutes.workTracking,
                    arguments: 42),
                child: const Text('Open booking'),
              )))),
      works: works,
      scale: scale, onGenerateRoute: (settings) {
    onRoute?.call(settings);
    return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => settings.name == AppRoutes.workTracking
            ? const WorkTrackingScreen()
            : Scaffold(
                appBar: AppBar(title: const Text('Destination')),
                body: const Text('Destination screen')));
  }));
  await tester.tap(find.text('Open booking'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Manrope')
          ..addFont(rootBundle.load('assets/fonts/Manrope.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });

  testWidgets(
      'Posted booking presents current status and refreshes without repeating requests on rebuild',
      (tester) async {
    await setSize(tester, const Size(390, 844));
    final works = TrackingFixture();
    await openTracking(tester, works);
    expect(find.text('Your request is in.'), findsOneWidget);
    expect(find.text('AC isn’t cooling'), findsOneWidget);
    expect(find.text('#0042'), findsOneWidget);
    expect(find.text('Worker on the way'), findsNothing);
    expect(works.loads, 1);
    await preview(tester, 'tracking');
    works.record = booking(status: WorkStatus.notified);
    await tester.pump(const Duration(seconds: 8));
    await tester.pumpAndSettle();
    expect(find.text('Finding your\nhelping hand.'), findsOneWidget);
    expect(works.loads, 2);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 16));
    expect(works.loads, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Edit validates, keeps failed changes open, and saves without disposing live controllers',
      (tester) async {
    await setSize(tester, const Size(390, 844));
    final works = TrackingFixture();
    await openTracking(tester, works);
    await tester.ensureVisible(find.text('Edit request'));
    await tester.tap(find.text('Edit request'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Please add a short title.'), findsOneWidget);
    expect(works.updates, 0);
    await tester.enterText(find.byType(TextFormField).first, 'AC leaks water');
    works.failSave = true;
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save. Please try again.'), findsOneWidget);
    works.failSave = false;
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('AC leaks water'), findsOneWidget);
    expect(find.text('Edit your request'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'Cancellation requires confirmation and returns to the booking list',
      (tester) async {
    await setSize(tester, const Size(390, 844));
    final works = TrackingFixture();
    await openTracking(tester, works);
    await tester.ensureVisible(find.text('Cancel booking'));
    await tester.tap(find.text('Cancel booking'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep booking'));
    await tester.pumpAndSettle();
    expect(works.cancellations, 0);
    await tester.tap(find.text('Cancel booking'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
        of: find.byType(AlertDialog), matching: find.text('Cancel booking')));
    await tester.pumpAndSettle();
    expect(works.cancellations, 1);
    expect(find.text('Open booking'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Failed loads hide unrelated bookings and recover; later failures label stale status',
      (tester) async {
    await setSize(tester, const Size(390, 844));
    final works = TrackingFixture()..failLoad = true;
    works.currentWork = WorkModel(
        id: 99,
        customerId: 1,
        categoryId: 1,
        title: 'Unrelated booking',
        customerLat: 25,
        customerLng: 55,
        status: WorkStatus.started,
        createdAt: '2026-09-10');
    await openTracking(tester, works);
    expect(find.text('Unrelated booking'), findsNothing);
    expect(find.text('We couldn’t load this booking.'), findsOneWidget);
    works.failLoad = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('AC isn’t cooling'), findsOneWidget);
    works.failLoad = true;
    await tester.pump(const Duration(seconds: 8));
    await tester.pumpAndSettle();
    expect(find.text('Couldn’t refresh. Showing the last known status.'),
        findsOneWidget);
    expect(find.text('Status updates automatically'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Assigned booking preserves location and start-code navigation',
      (tester) async {
    await setSize(tester, const Size(390, 844));
    final works = TrackingFixture(status: WorkStatus.accepted);
    RouteSettings? latest;
    await openTracking(tester, works, onRoute: (route) => latest = route);
    expect(find.text('Edit request'), findsNothing);
    expect(find.text('Cancel booking'), findsNothing);
    await preview(tester, 'tracking-assigned');
    await tester.ensureVisible(find.text('View professional’s location'));
    await tester.tap(find.text('View professional’s location'));
    await tester.pumpAndSettle();
    expect(latest?.name, AppRoutes.workerMap);
    expect(latest?.arguments, 42);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Show start code'));
    await tester.tap(find.text('Show start code'));
    await tester.pumpAndSettle();
    expect(latest?.name, AppRoutes.showOtp);
    expect((latest?.arguments as WorkModel).otpCode, '1234');
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Terminal states stop polling and layouts fit a small phone with large text',
      (tester) async {
    await setSize(tester, const Size(320, 568));
    for (final status in [
      WorkStatus.posted,
      WorkStatus.accepted,
      WorkStatus.completed,
      WorkStatus.cancelled
    ]) {
      final works = TrackingFixture(status: status);
      await openTracking(tester, works, scale: 1.6);
      expect(tester.takeException(), isNull, reason: '$status initial');
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$status scrolled');
      if (status == WorkStatus.completed || status == WorkStatus.cancelled) {
        await tester.pump(const Duration(seconds: 24));
        expect(works.loads, 1);
        expect(find.text('Edit request'), findsNothing);
        if (status == WorkStatus.cancelled) {
          expect(find.text('Booking progress'), findsNothing);
        }
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
