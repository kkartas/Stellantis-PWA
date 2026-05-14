import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorBoundary extends ConsumerStatefulWidget {
  const ErrorBoundary({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  Object? _error;
  StackTrace? _stack;

  void _handleError(Object error, StackTrace stack) {
    setState(() {
      _error = error;
      _stack = stack;
    });
  }

  void _retry() {
    setState(() {
      _error = null;
      _stack = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error == null) {
      return ErrorBoundaryScope(
        onError: _handleError,
        child: widget.child,
      );
    }

    if (kDebugMode) {
      return _DebugErrorCard(error: _error!, stack: _stack, onRetry: _retry);
    }

    return _ReleaseErrorScreen(onRetry: _retry);
  }
}

class ErrorBoundaryScope extends InheritedWidget {
  const ErrorBoundaryScope({
    required super.child,
    required this.onError,
    super.key,
  });

  final void Function(Object error, StackTrace stack) onError;

  static ErrorBoundaryScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ErrorBoundaryScope>();

  @override
  bool updateShouldNotify(ErrorBoundaryScope old) => onError != old.onError;
}

class _DebugErrorCard extends StatelessWidget {
  const _DebugErrorCard({
    required this.error,
    required this.onRetry,
    this.stack,
  });

  final Object error;
  final StackTrace? stack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unhandled error (debug)',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text(error.toString()),
              if (stack != null) ...[
                const SizedBox(height: 8),
                Text(
                  stack.toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReleaseErrorScreen extends StatelessWidget {
  const _ReleaseErrorScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Something went wrong'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
