import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Shared visual primitives for the three "non-happy-path" states every
/// feature screen needs:
///
/// - [LoadingStateView]  — fetching for the first time, no cache yet
/// - [ErrorStateView]    — request failed and we have nothing to show
/// - [OfflineStateView]  — request failed because the device is offline
/// - [EmptyStateView]    — request succeeded but returned nothing
///
/// Phase 6 screens use these directly so error + retry surfaces stay
/// visually consistent regardless of which feature surfaced them.

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    required this.message,
    super.key,
    this.title = 'Something went wrong',
    this.icon = Icons.error_outline,
    this.onRetry,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OfflineStateView extends StatelessWidget {
  const OfflineStateView({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorStateView(
      icon: Icons.cloud_off,
      title: "You're offline",
      message:
          "We're showing the last known state. Reconnect to refresh from "
          'the cloud.',
      onRetry: onRetry,
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.message,
    super.key,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Maps any thrown error to the visual that best matches it. Phase 6
/// `.when(...)` blocks call this so transient network errors land on the
/// offline view rather than a generic red panel.
Widget mapErrorToStateView(Object error, {VoidCallback? onRetry}) {
  if (_looksOffline(error)) {
    return OfflineStateView(onRetry: onRetry);
  }
  return ErrorStateView(
    message: _describe(error),
    onRetry: onRetry,
  );
}

bool _looksOffline(Object error) {
  if (error is SocketException) return true;
  if (error is DioException) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }
  return false;
}

String _describe(Object error) {
  if (error is DioException) {
    final code = error.response?.statusCode;
    if (code != null) return 'Request failed ($code). Please try again.';
    return 'Network error. Please try again.';
  }
  return 'Unexpected error. Please try again.';
}
