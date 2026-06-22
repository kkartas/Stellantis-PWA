import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stellantis_mobile/app/app.dart';

/// End-to-end happy path for first launch, driven through the *real* app
/// router, theme, and localization — no provider overrides.
///
/// With an empty secure store there is no saved brand session, so the splash
/// screen's bootstrap routes the user to the brand picker. This exercises the
/// full boot → splash → route decision → first screen flow.
///
/// Run on a device/emulator with:  flutter test integration_test
/// (it also executes headless under `flutter test`). A patrol wrapper can
/// layer real OAuth/native interactions on top of this same flow.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    const channel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'readAll':
          return <String, String>{};
        case 'read':
        case 'write':
        case 'delete':
        case 'deleteAll':
          return null;
        case 'containsKey':
          return false;
        default:
          return null;
      }
    });
  });

  testWidgets('first launch boots through splash to the brand picker',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: StellantisApp()));

    // Splash holds for a minimum dwell, then the bootstrap decides the route.
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Choose your brand'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
