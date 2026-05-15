import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kThemeMode = 'theme_mode';

final themeModeControllerProvider =
    AsyncNotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  static const _storage = FlutterSecureStorage();

  @override
  Future<ThemeMode> build() async {
    final raw = await _storage.read(key: _kThemeMode);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> set(ThemeMode mode) async {
    await _storage.write(key: _kThemeMode, value: mode.name);
    state = AsyncData(mode);
  }
}
