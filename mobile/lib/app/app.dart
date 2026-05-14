import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root application widget. Wired up fully in step 1.5.
class StellantisApp extends ConsumerWidget {
  const StellantisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Stellantis')),
      ),
    );
  }
}
