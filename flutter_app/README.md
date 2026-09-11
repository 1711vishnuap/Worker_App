# Service Marketplace — Flutter App

## 1. Create the platform folders (Android/iOS)

This project was generated as pure Dart/Flutter source files. Before it can
run, generate the platform scaffolding once:

```bash
cd flutter_app
flutter create . --org com.yourcompany --project-name service_marketplace
flutter pub get
```

This adds the `android/` and `ios/` folders needed below, without touching
anything in `lib/`.

## 2. Point the app at your backend

Pass the backend address when launching the app:

```bash
flutter run --dart-define=API_BASE_URL=http://<your-computer-LAN-IP>:3001/api
```

- Android emulator → `http://10.0.2.2:3001/api`
- iOS simulator → `http://127.0.0.1:3001/api`
- Physical device → `http://<your-computer-LAN-IP>:3001/api`
- Production → your deployed HTTPS API URL, including `/api`

Without an override, `lib/config/api_constants.dart` uses the current development
address `http://10.60.189.216:3001/api`. A LAN address can change when switching
networks. Keep the phone and computer on the same Wi-Fi, leave the backend
running, and allow local-network access on the phone. Relaunch Flutter when
changing `--dart-define`; an already installed build retains its previous URL.

To distinguish a network problem from an app problem, open
`http://<your-computer-LAN-IP>:3001/api/categories` in the phone's browser.
It should return JSON with the available services.

## 3. Configure Firebase (for push notifications)

1. Go to the [Firebase Console](https://console.firebase.google.com) → create a project.
2. Install the FlutterFire CLI: `dart pub global activate flutterfire_cli`
3. From the `flutter_app` folder, run: `flutterfire configure`
   — this registers your Android/iOS apps and generates
   `lib/firebase_options.dart` automatically.
4. In `lib/main.dart`, change:
   ```dart
   await Firebase.initializeApp();
   ```
   to:
   ```dart
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```
   and add `import 'firebase_options.dart';` at the top.
5. **Android**: `flutterfire configure` places `google-services.json` in
   `android/app/`. Make sure `android/build.gradle` and
   `android/app/build.gradle` have the Google Services plugin (the
   FlutterFire CLI does this automatically).
6. **iOS**: it places `GoogleService-Info.plist` in `ios/Runner/` — open
   `ios/Runner.xcworkspace` in Xcode once and confirm the file is added
   to the Runner target.
7. On the **backend**, download a service account key (Firebase Console →
   Project Settings → Service Accounts → Generate New Private Key), save
   it as `backend/firebase-service-account.json`, and set
   `FIREBASE_SERVICE_ACCOUNT_PATH` in `backend/.env`.

## 4. Configure Google Maps

1. In [Google Cloud Console](https://console.cloud.google.com), enable
   **Maps SDK for Android** and **Maps SDK for iOS** on the same project
   as your Firebase project (or a new one), then create an API key.
2. **Android** — open `android/app/src/main/AndroidManifest.xml` and add
   inside the `<application>` tag:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_ANDROID_MAPS_API_KEY" />
   ```
   Also add above `<application>`, inside `<manifest>`:
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```
3. **iOS** — open `ios/Runner/AppDelegate.swift` and add near the top:
   ```swift
   import GoogleMaps
   ```
   then inside `application(_:didFinishLaunchingWithOptions:)`, before `return`:
   ```swift
   GMSServices.provideAPIKey("YOUR_IOS_MAPS_API_KEY")
   ```
   Also add to `ios/Runner/Info.plist`:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need your location to match you with nearby workers</string>
   ```

## 5. Run it

```bash
flutter pub get
flutter run
```

Make sure the backend (see the `backend/` folder from earlier) is running
and reachable at the `baseUrl` you configured in step 2.

## 6. Three small backend endpoints this app expects

The Flutter app calls a few endpoints that weren't in the original backend
endpoint list — small, natural additions. See `BACKEND_ADDITIONS.md` for
the exact code to add (each is ~10-15 lines, following the same pattern as
the existing modules).
