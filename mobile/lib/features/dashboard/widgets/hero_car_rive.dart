import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/status_snapshot.dart';
import 'package:stellantis_mobile/theme/brand_theme.dart';

const _heroCarAsset = 'assets/animations/hero_car.riv';
const _stateMachineName = 'State';

/// Branded hero car visual. Tries to play `assets/animations/hero_car.riv`
/// with inputs bound to lock + door state. Falls back to the static brand
/// SVG silhouette if the .riv file is absent or fails to load.
///
/// The .riv artwork itself ships separately — this widget defines the
/// integration contract (state-machine name, input names) so the artwork
/// just needs to expose:
///   - bool input `locked`
///   - bool input `charging`
///   - number input `doorsOpen` (count of open doors, 0–6)
class HeroCarRive extends ConsumerStatefulWidget {
  const HeroCarRive({super.key, required this.status, this.height = 160});

  final StatusSnapshot? status;
  final double height;

  @override
  ConsumerState<HeroCarRive> createState() => _HeroCarRiveState();
}

class _HeroCarRiveState extends ConsumerState<HeroCarRive> {
  late final Future<bool> _hasAsset = _probeAsset();
  Artboard? _artboard;
  StateMachineController? _machine;
  SMIBool? _locked;
  SMIBool? _charging;
  SMINumber? _doorsOpen;

  Future<bool> _probeAsset() async {
    try {
      await rootBundle.load(_heroCarAsset);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, _stateMachineName);
    if (controller == null) return;
    artboard.addController(controller);
    _machine = controller;
    _locked = controller.findInput<bool>('locked') as SMIBool?;
    _charging = controller.findInput<bool>('charging') as SMIBool?;
    _doorsOpen = controller.findInput<double>('doorsOpen') as SMINumber?;
    _artboard = artboard;
    _pushInputs();
  }

  void _pushInputs() {
    final s = widget.status;
    final isCharging = s?.chargingStatus == 'inProgress';
    // Lock + door state are not stored on StatusSnapshot today. Default to
    // 'locked / no doors open' so the artwork has sensible inputs; richer
    // values feed in once the schema or liveVehicleStatusProvider exposes
    // them to this widget.
    _locked?.value = true;
    _charging?.value = isCharging;
    _doorsOpen?.value = 0;
  }

  @override
  void didUpdateWidget(HeroCarRive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) _pushInputs();
  }

  @override
  void dispose() {
    _machine?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = ref.watch(brandThemeProvider);

    return SizedBox(
      height: widget.height,
      child: FutureBuilder<bool>(
        future: _hasAsset,
        builder: (context, snap) {
          if (snap.data == true) {
            return RiveAnimation.asset(
              _heroCarAsset,
              fit: BoxFit.contain,
              stateMachines: const [_stateMachineName],
              onInit: _onRiveInit,
            );
          }
          // Fallback: brand-tinted silhouette of the static logo.
          return Center(
            child: SvgPicture.asset(
              brand.logoAsset,
              height: widget.height * 0.7,
              colorFilter: ColorFilter.mode(brand.onPrimary, BlendMode.srcIn),
            ),
          );
        },
      ),
    );
  }
}
