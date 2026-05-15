import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

/// Named Lottie animation slots used across the app. Each [StateLottie]
/// value maps to an asset path under `assets/animations/`. The artwork
/// itself ships separately; until then this widget falls back to a static
/// icon so feature screens can adopt the API today without breaking the
/// build.
enum StateLottie {
  charging('assets/animations/charging.json', Icons.bolt),
  climateOn('assets/animations/climate_on.json', Icons.ac_unit),
  lockCycle('assets/animations/lock_cycle.json', Icons.lock);

  const StateLottie(this.asset, this.fallbackIcon);
  final String asset;
  final IconData fallbackIcon;
}

class StateLottieView extends StatefulWidget {
  const StateLottieView({
    super.key,
    required this.kind,
    this.size = 96,
    this.repeat = true,
  });

  final StateLottie kind;
  final double size;
  final bool repeat;

  @override
  State<StateLottieView> createState() => _StateLottieViewState();
}

class _StateLottieViewState extends State<StateLottieView> {
  late final Future<bool> _hasAsset = _probe();

  Future<bool> _probe() async {
    try {
      await rootBundle.load(widget.kind.asset);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FutureBuilder<bool>(
        future: _hasAsset,
        builder: (context, snap) {
          if (snap.data == true) {
            return Lottie.asset(
              widget.kind.asset,
              repeat: widget.repeat,
              fit: BoxFit.contain,
            );
          }
          return Icon(
            widget.kind.fallbackIcon,
            size: widget.size * 0.6,
            color: Theme.of(context).colorScheme.primary,
          );
        },
      ),
    );
  }
}
