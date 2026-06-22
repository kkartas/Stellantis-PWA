import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/l10n/app_localizations.dart';

/// Shared scaffolding for widget tests.
///
/// Many screens read preferences straight from `flutter_secure_storage`,
/// which has no implementation under the test binding. [mockSecureStorage]
/// installs a method-channel handler that behaves like an empty store, so the
/// real Riverpod providers run and resolve to their defaults without needing
/// per-provider fakes. Call it from `setUp`.
void mockSecureStorage([Map<String, String>? initial]) {
  final store = <String, String>{...?initial};
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
    final key = args['key'] as String?;
    switch (call.method) {
      case 'read':
        return store[key];
      case 'write':
        if (key != null) store[key] = args['value'] as String? ?? '';
        return null;
      case 'delete':
        store.remove(key);
        return null;
      case 'readAll':
        return Map<String, String>.from(store);
      case 'deleteAll':
        store.clear();
        return null;
      case 'containsKey':
        return store.containsKey(key);
      default:
        return null;
    }
  });
}

/// Pumps [child] inside a [ProviderScope] and a localized [MaterialApp].
///
/// Use [overrides] to inject fakes for repository/stream providers. The app
/// wires the generated [AppLocalizations] so any localized widget resolves.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
  // One extra frame lets AsyncNotifier/StreamProvider futures settle without
  // pumpAndSettle (which would hang on providers that never complete).
  await tester.pump();
}
