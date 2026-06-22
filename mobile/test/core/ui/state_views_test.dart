import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/core/ui/state_views.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('LoadingStateView', () {
    testWidgets('always shows a spinner', (tester) async {
      await _pump(tester, const LoadingStateView());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows the optional message', (tester) async {
      await _pump(tester, const LoadingStateView(message: 'Waking the car…'));
      expect(find.text('Waking the car…'), findsOneWidget);
    });
  });

  group('ErrorStateView', () {
    testWidgets('renders title and message', (tester) async {
      await _pump(tester, const ErrorStateView(message: 'Boom'));
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Boom'), findsOneWidget);
    });

    testWidgets('hides the retry button when onRetry is null', (tester) async {
      await _pump(tester, const ErrorStateView(message: 'Boom'));
      expect(find.widgetWithText(FilledButton, 'Retry'), findsNothing);
    });

    testWidgets('invokes onRetry when the button is tapped', (tester) async {
      var retried = false;
      await _pump(
        tester,
        ErrorStateView(message: 'Boom', onRetry: () => retried = true),
      );
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });
  });

  group('EmptyStateView', () {
    testWidgets('renders its message', (tester) async {
      await _pump(tester, const EmptyStateView(message: 'No trips yet'));
      expect(find.text('No trips yet'), findsOneWidget);
    });
  });

  group('mapErrorToStateView', () {
    testWidgets('maps SocketException to the offline view', (tester) async {
      await _pump(
        tester,
        mapErrorToStateView(const SocketException('no route')),
      );
      expect(find.text("You're offline"), findsOneWidget);
    });

    testWidgets('maps a Dio connection error to the offline view',
        (tester) async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/status'),
        type: DioExceptionType.connectionError,
      );
      await _pump(tester, mapErrorToStateView(error));
      expect(find.text("You're offline"), findsOneWidget);
    });

    testWidgets('maps an HTTP status error to the generic error view',
        (tester) async {
      final error = DioException(
        requestOptions: RequestOptions(path: '/status'),
        type: DioExceptionType.badResponse,
        response: Response<void>(
          requestOptions: RequestOptions(path: '/status'),
          statusCode: 500,
        ),
      );
      await _pump(tester, mapErrorToStateView(error));
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.textContaining('500'), findsOneWidget);
    });
  });
}
