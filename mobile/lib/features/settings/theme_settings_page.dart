import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';
import 'package:stellantis_mobile/theme/brand_detector.dart';
import 'package:stellantis_mobile/theme/brand_theme.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(brandOverrideProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'By default the app themes itself to match the brand of the '
              'car on your account. Pick a different brand below to force '
              'that theme instead.',
            ),
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
