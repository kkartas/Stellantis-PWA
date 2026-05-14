import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashPlaceholderPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardPlaceholderPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPlaceholderPage(),
      ),
    ],
  );
});

class DashboardPlaceholderPage extends StatelessWidget {
  const DashboardPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Dashboard')),
    );
  }
}

class LoginPlaceholderPage extends StatelessWidget {
  const LoginPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Login')),
    );
  }
}

/// Temporary placeholder replaced by SplashPage in step 1.6.
class _SplashPlaceholderPage extends StatelessWidget {
  const _SplashPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Splash')),
    );
  }
}
