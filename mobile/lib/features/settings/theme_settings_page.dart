import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stellantis_mobile/features/settings/data/theme_mode_preference.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';
import 'package:stellantis_mobile/theme/brand_detector.dart';
import 'package:stellantis_mobile/theme/brand_theme.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(brandOverrideProvider);
    final themeMode =
        ref.watch(themeModeControllerProvider).valueOrNull ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Appearance and brand identity. Light / dark applies to the '
              'whole app; the brand below tints the palette.',
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Appearance',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          RadioGroup<ThemeMode>(
            groupValue: themeMode,
            onChanged: (v) {
              if (v == null) return;
              ref.read(themeModeControllerProvider.notifier).set(v);
            },
            child: const Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: Text('Match system'),
                  secondary: Icon(Icons.brightness_auto),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title: Text('Light'),
                  secondary: Icon(Icons.light_mode_outlined),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title: Text('Dark'),
                  secondary: Icon(Icons.dark_mode_outlined),
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Brand',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          RadioGroup<Brand?>(
            groupValue: override,
            onChanged: (_) {
              ref.read(brandOverrideProvider.notifier).state = null;
              ref.read(brandThemeProvider.notifier).state = BrandTheme.neutral;
            },
            child: const RadioListTile<Brand?>(
              value: null,
              title: Text('Auto (match vehicle brand)'),
              secondary: Icon(Icons.auto_awesome),
            ),
          ),
          const Divider(),
          for (final entry in BrandTheme.perBrand.entries)
            RadioGroup<Brand>(
              groupValue: override,
              onChanged: (v) {
                if (v == null) return;
                ref.read(brandOverrideProvider.notifier).state = v;
                ref.read(brandThemeProvider.notifier).state = entry.value;
              },
              child: RadioListTile<Brand>(
                value: entry.key,
                title: Text(_brandLabel(entry.key)),
                secondary: SizedBox(
                  width: 32,
                  height: 32,
                  child: SvgPicture.asset(
                    entry.value.logoAsset,
                    colorFilter: ColorFilter.mode(
                      entry.value.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _brandLabel(Brand b) {
  switch (b) {
    case Brand.alfaRomeo:
      return 'Alfa Romeo';
    case Brand.chrysler:
      return 'Chrysler';
    case Brand.citroen:
      return 'Citroën';
    case Brand.dodge:
      return 'Dodge';
    case Brand.ds:
      return 'DS';
    case Brand.fiat:
      return 'Fiat';
    case Brand.jeep:
      return 'Jeep';
    case Brand.lancia:
      return 'Lancia';
    case Brand.maserati:
      return 'Maserati';
    case Brand.opel:
      return 'Opel';
    case Brand.peugeot:
      return 'Peugeot';
    case Brand.ram:
      return 'Ram';
    case Brand.vauxhall:
      return 'Vauxhall';
  }
}
