import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/features/auth/data/brand_session.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';
import 'package:stellantis_mobile/theme/brand_detector.dart';
import 'package:stellantis_mobile/theme/brand_theme.dart';

/// Brands that have working OAuth credentials wired into [BrandConstants].
const _authenticatableBrands = <Brand>[
  Brand.peugeot,
  Brand.citroen,
  Brand.ds,
  Brand.opel,
  Brand.vauxhall,
];

/// Country options offered for the auth flow. Driven by BrandSecrets keys
/// in tools/extract_secrets — keep aligned when new countries are added.
const _countries = <_Country>[
  _Country('AT', 'Austria'),
  _Country('BE', 'Belgium'),
  _Country('HR', 'Croatia'),
  _Country('CZ', 'Czechia'),
  _Country('DK', 'Denmark'),
  _Country('FI', 'Finland'),
  _Country('FR', 'France'),
  _Country('DE', 'Germany'),
  _Country('GR', 'Greece'),
  _Country('HU', 'Hungary'),
  _Country('IE', 'Ireland'),
  _Country('IT', 'Italy'),
  _Country('LU', 'Luxembourg'),
  _Country('NL', 'Netherlands'),
  _Country('NO', 'Norway'),
  _Country('PL', 'Poland'),
  _Country('PT', 'Portugal'),
  _Country('RO', 'Romania'),
  _Country('SK', 'Slovakia'),
  _Country('SI', 'Slovenia'),
  _Country('ES', 'Spain'),
  _Country('SE', 'Sweden'),
  _Country('CH', 'Switzerland'),
  _Country('TR', 'Turkey'),
  _Country('GB', 'United Kingdom'),
];

class BrandPickerPage extends ConsumerStatefulWidget {
  const BrandPickerPage({super.key});

  @override
  ConsumerState<BrandPickerPage> createState() => _BrandPickerPageState();
}

class _BrandPickerPageState extends ConsumerState<BrandPickerPage> {
  Brand? _brand;
  String _country = 'FR';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your brand')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Which car brand do you drive?',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'We support Peugeot, Citroën, DS, Opel and Vauxhall accounts.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: _authenticatableBrands.length,
                  itemBuilder: (context, index) {
                    final brand = _authenticatableBrands[index];
                    final brandTheme =
                        BrandTheme.perBrand[brand] ?? BrandTheme.neutral;
                    final selected = _brand == brand;
                    return _BrandTile(
                      brand: brand,
                      theme: brandTheme,
                      selected: selected,
                      onTap: () => setState(() => _brand = brand),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _country,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final c in _countries)
                    DropdownMenuItem(value: c.code, child: Text(c.label)),
                ],
                onChanged: (v) => setState(() => _country = v ?? 'FR'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _brand == null ? null : _onContinue,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onContinue() async {
    final brand = _brand;
    if (brand == null) return;
    final session = BrandSession(brand: brand, countryCode: _country);
    ref.read(selectedBrandSessionProvider.notifier).state = session;
    ref.read(brandOverrideProvider.notifier).state = brand;
    ref.read(brandThemeProvider.notifier).state =
        BrandTheme.perBrand[brand] ?? BrandTheme.neutral;
    await ref.read(brandSessionStoreProvider).save(session);
    if (!mounted) return;
    context.go('/login');
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({
    required this.brand,
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final Brand brand;
  final BrandTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? theme.primary : theme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: selected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? theme.primary : theme.onSurface.withAlpha(40),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(theme.logoAsset, height: 36),
              const SizedBox(height: 8),
              Text(
                _labelFor(brand),
                style: TextStyle(
                  color: selected ? theme.onPrimary : theme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _labelFor(Brand brand) {
  switch (brand) {
    case Brand.peugeot:
      return 'Peugeot';
    case Brand.citroen:
      return 'Citroën';
    case Brand.ds:
      return 'DS';
    case Brand.opel:
      return 'Opel';
    case Brand.vauxhall:
      return 'Vauxhall';
    case Brand.fiat:
      return 'Fiat';
    case Brand.lancia:
      return 'Lancia';
    case Brand.alfaRomeo:
      return 'Alfa Romeo';
    case Brand.jeep:
      return 'Jeep';
    case Brand.maserati:
      return 'Maserati';
    case Brand.chrysler:
      return 'Chrysler';
    case Brand.dodge:
      return 'Dodge';
    case Brand.ram:
      return 'Ram';
  }
}

class _Country {
  const _Country(this.code, this.label);
  final String code;
  final String label;
}
