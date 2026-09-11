# ServiceHub gap review

Reviewed 10 September 2026. Findings are from the local Flutter, Express, and SQL source. The remote database, SMS delivery, push delivery, and live device booking flow were not tested. Existing booking/location edits were preserved. Backend findings below remain open.

## Fix before a public launch

| Priority | Gap and user impact | Code evidence | Next change | Confidence |
| --- | --- | --- | --- | --- |
| Critical | Login does not send SMS. OTPs are logged and returned to clients outside production; the in-memory store has no attempt limit or request throttling. | `service-marketplace-backend/src/modules/auth/auth.service.js`: `sendOtp`, `verifyOtp`; `src/app.js` | Use real phone verification, stop logging OTPs, add resend/verification limits and server-side verification of identity. | High |
| Critical | Workers receive the customer's job OTP. The assigned worker can read it without asking the customer, defeating the arrival check. | `src/modules/works/work.service.js`: `getWorkById` returns `w.*` to workers; `src/modules/workers/worker.service.js`: `acceptWork` returns `SELECT * FROM works`. | Return role-specific fields; expose the job OTP only to its customer. Add authorization/response-shape tests. | High |
| Critical | Any authenticated worker with a profile can accept a known open job ID. Acceptance does not require a notified assignment, matching category, or availability. | `src/modules/workers/worker.service.js`: `acceptWork` | Check eligible assignment and availability in the same transaction as acceptance. | High |
| High | Workers cannot open the available-job details used by the app before accepting. The details route only permits the owning customer or already assigned worker. | `flutter_app/lib/screens/worker/available_works_screen.dart`, `work_details_screen.dart`; backend `getWorkById` | Permit invited workers to read a limited job preview, excluding the OTP and unnecessary private data. | High |
| High | The history and push-token API calls have no backend routes. History fails; devices cannot register their push token through the app. | `flutter_app/lib/config/api_constants.dart`: `/workers/history`, `/users/fcm-token`; backend `src/routes/index.js`, `src/modules/workers/worker.routes.js` | Implement authenticated endpoints and test the client/server contract. | High |
| High | Edit/cancel and job transitions check status before a separate unconditional update. A concurrent accept can race with cancellation; creation and history writes can partially succeed. | `src/modules/works/work.service.js`: `updateWork`, `cancelWork`, `createWork`; `src/modules/workers/worker.service.js`: `verifyWorkOtp`, `completeWork` | Use transactions and conditional updates against the expected state; check affected rows. | High |
| High | The mobile app depends on a local HTTP backend. MySQL is remote, but certificate verification is disabled. | `flutter_app/lib/config/api_constants.dart`: `baseUrl`; `service-marketplace-backend/src/config/db.js`: `rejectUnauthorized: false` | Deploy an HTTPS API, configure URLs per environment, and validate the database certificate using the provider CA. | High |
| High | Choosing a photo only creates a local preview; every booking submits `photoUrl: null`. | `flutter_app/lib/screens/customer/add_work_screen.dart`: `_pickPhoto`, `_submit` | Add an authenticated upload flow and persist the returned URL; show progress and upload errors. | High |

Backend paths in the evidence column are relative to `service-marketplace-backend/` unless written in full.

## Complete the day-to-day workflows

| Gap | Evidence and effect | Next change |
| --- | --- | --- |
| Worker service selections do not reload | `select_categories_screen.dart` starts with an empty set. The backend only exposes a write endpoint; saving replaces the existing categories. | Return the saved profile/categories and initialize the editor from them. |
| Active work is not restored after restart | `WorkerProvider.acceptedWork` is memory-only; there is no active-job endpoint. | Fetch assigned active work on login/resume and route to its current step. |
| Tracking shows states workers cannot set | `WORKER_ON_THE_WAY` and `ARRIVED` exist in the model/schema but have no transition endpoints. | Implement authorized state changes and align OTP verification with the agreed lifecycle. |
| Unmatched requests can remain open indefinitely | `findAndNotifyNearestWorkers` only runs during creation. | Add retry/rematching, expiry, and a clear customer fallback when nobody accepts. |
| Availability/location handling is incomplete | Matching uses `is_available`; the app has no availability control or location freshness cutoff. Updates rely on a foreground stream. | Add online/offline controls, stale-location exclusion, and a deliberate foreground/background location policy. |
| Session and push lifecycle need work | Tokens are stored in SharedPreferences. Session restoration trusts the saved user. FCM setup runs only after OTP login; foreground/tap handlers are not wired into navigation. | Use protected token storage, handle expired sessions, refresh push registration on session restore, and manage listeners and sign-out cleanup. |
| Some older detail/list screens still hide errors | Several screens show an empty state or spinner when an API request fails. Worker history cards have an empty tap callback. | Add explicit loading/error/empty states and working history details. |
| Marketplace features are still absent | No completed flows for quotes/pricing, payments, reviews, scheduling, disputes, or profile editing were found in the routes/screens. | Agree which are required for the MVP, then build complete flows instead of placeholder controls. |
| Backend validation and regression coverage are limited | Coordinates and payloads have basic presence checks; no backend test suite is configured. | Validate types, limits, ranges, and IDs; test authorization and competing state transitions. |

## UI refinement completed

- Blue primary palette, soft neutral surfaces, Manrope typography bundled with its license, consistent spacing and rounded controls.
- Illustrated welcome/sign-in screen and updated splash.
- Customer home with one service banner action, direct category booking, and active bookings. Duplicate shortcut rows, header account buttons, home search launcher, and home "See all" links are removed. Full lists and account access live in the bottom navigation. The same cleanup applies to the worker home.
- Searchable service grid with selectable real API categories, empty results, loading, and retry.
- Worker home and service-selection grid using the same visual language.
- Customer and worker navigation, account details/sign-out, and illustrated booking cards.
- Category requests now have separate loading/error state; the customer home refreshes bookings after returning from its booking/detail actions.
- Worker location listeners guard disposed screens and surface location errors. The map controller is disposed when its screen closes.
- Booking tracking now prioritizes the current status, four milestones, a booking summary, and the next relevant action. Edit/cancel, location, and start-code routes are retained. Failed refreshes label the last known status, unrelated cached bookings are hidden, and polling pauses on covered/background screens and terminal states. The edit form validates input and preserves changes when saving fails.

Previews render the actual Flutter widgets using test fixtures, not live customer records:

[Welcome](ui-welcome.png) · [Customer home](ui-home.png) · [Services](ui-services.png) · [Worker home](ui-worker.png) · [Booking tracking](ui-tracking.png) · [Assigned booking](ui-tracking-assigned.png)

Validation: five Flutter widget tests cover service search and booking arguments, failed-request recovery and empty search, main navigation, welcome/worker rendering, and layouts at 320 × 568 with 160% text size. Screenshots are rendered at 390 × 844 logical pixels. These tests replace the unrelated starter counter test and do not validate remote integrations.

Six additional tracking tests cover status refresh and teardown, validated editing and failed-save recovery, cancellation confirmation, failed loads and stale status, location/start-code navigation, and terminal states at enlarged text size. Together the UI suite contains 11 tests.

Run from `flutter_app/`:

```sh
flutter analyze --no-pub
flutter test --no-pub
# Regenerate the previews with fixture data:
flutter test --no-pub --dart-define=UPDATE_PREVIEWS=true
```
