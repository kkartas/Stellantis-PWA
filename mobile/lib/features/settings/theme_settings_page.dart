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
            child: Text('Appearance', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: themeMode,
            title: const Text('Match system'),
            secondary: const Icon(Icons.brightness_auto),
            onChanged: (v) => v == null
                ? null
                : ref
                    .read(themeModeControllerProvider.notifier)
                    .set(v),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: themeMode,
            title: const Text('Light'),
            secondary: const Icon(Icons.light_mode_outlined),
            onChanged: (v) => v == null
                ? null
                : ref
                    .read(themeModeControllerProvider.notifier)
                    .set(v),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: themeMode,
            title: const Text('Dark'),
            secondary: const Icon(Icons.dark_mode_outlined),
            onChanged: (v) => v == null
                ? null
                : ref
                    .read(themeModeControllerProvider.notifier)
                    .set(v),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('Brand', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          RadioListTile<Brand?>(
            value: null,
            groupValue: override,
            title: const Text('Auto (match vehicle brand)'),
            secondary: const Icon(Icons.auto_awesome),
            onChanged: (_) {
              ref.read(brandOverrideProvider.notifier).state = null;
              ref.read(brandThemeProvider.notifier).state = BrandTheme.neutral;
            },
          ),
          const Divider(),
          for (final entry in BrandTheme.perBrand.entries)
            RadioListTile<Brand>(
              value: entry.key,
              groupValue: override,
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
              onChanged: (v) {
                if (v == null) return;
                ref.read(brandOverrideProvider.notifier).state = v;
                ref.read(brandThemeProvider.notifier).state = entry.value;
              },
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
