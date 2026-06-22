import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/features/auth/otp_setup_page.dart';

import '../../support/test_harness.dart';

void main() {
  setUp(mockSecureStorage);

  testWidgets('renders the OTP setup form', (tester) async {
    await pumpScreen(tester, const OtpSetupPage());
    await tester.pump();

    expect(find.text('Enable remote commands'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'SMS code'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

// NOTE: SplashPage is intentionally not unit-tested here. Its only logic runs
// in a post-frame callback that performs routing (context.go) after a 500ms
// dwell timer; exercising it meaningfully needs a full GoRouter + session
// harness and is covered by the Task 7 patrol happy-path flow instead.
