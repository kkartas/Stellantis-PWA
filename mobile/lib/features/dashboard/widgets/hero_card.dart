import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/features/dashboard/widgets/hero_car_rive.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/status_snapshot.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/vehicle_record.dart';
import 'package:stellantis_mobile/theme/brand_theme.dart';

/// Branded hero card shown at the top of the dashboard. Renders the brand
/// logo silhouette over a gradient that uses the active brand's primary +
/// secondary tokens, with the vehicle label and lock state stacked over it.
class HeroCard extends ConsumerWidget {
  const HeroCard({
    required this.vehicle,
    required this.status,
    super.key,
  });

  final VehicleRecord? vehicle;
  final StatusSnapshot? status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandThemeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            brand.primary,
            Color.lerp(brand.primary, brand.secondary ?? brand.primary, 0.7) ??
                brand.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: brand.primary.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Rive car (with SVG silhouette fallback while no .riv ships).
          Positioned(
            right: -10,
            bottom: -10,
            width: 200,
            height: 180,
            child: Opacity(
              opacity: 0.55,
              child: HeroCarRive(status: status, height: 180),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle?.label ?? 'My vehicle',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: brand.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (vehicle != null)
                  Text(
                    'VIN ${_redact(vehicle!.vin)}',
                    style: TextStyle(
                      color: brand.onPrimary.withAlpha(180),
                      fontSize: 12,
                    ),
                  ),
                const Spacer(),
                _StatusChips(
                  status: status,
                  onColor: brand.onPrimary,
                  backgroundColor: scheme.surface.withAlpha(40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChips extends StatelessWidget {
  const _StatusChips({
    required this.status,
    required this.onColor,
    required this.backgroundColor,
  });

  final StatusSnapshot? status;
  final Color onColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final mileage = status?.mileage;
    final charging = status?.chargingStatus;

    return Wrap(
      spacing: 8,
      children: [
        if (mileage != null)
          _Chip(
            icon: Icons.speed,
            label: '${mileage.toStringAsFixed(0)} km',
            onColor: onColor,
            backgroundColor: backgroundColor,
          ),
        if (charging != null && charging != 'disconnected')
          _Chip(
            icon: Icons.bolt,
            label: _humanizeCharging(charging),
            onColor: onColor,
            backgroundColor: backgroundColor,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.onColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color onColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: onColor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: onColor, fontSize: 13)),
        ],
      ),
    );
  }
}

String _redact(String vin) =>
    vin.length <= 6 ? vin : '••• ${vin.substring(vin.length - 6)}';

String _humanizeCharging(String raw) {
  switch (raw) {
    case 'inProgress':
      return 'Charging';
    case 'finished':
      return 'Charge complete';
    case 'stopped':
      return 'Charge stopped';
    case 'failure':
      return 'Charge failed';
    default:
      return raw;
  }
}
