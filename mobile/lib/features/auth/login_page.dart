import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/features/auth/data/brand_session.dart';
import 'package:stellantis_mobile/stellantis/auth/oauth_service.dart';
import 'package:stellantis_mobile/theme/brand_theme.dart';

const _log = AppLogger('LoginPage');

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(selectedBrandSessionProvider);
    final brandTheme = ref.watch(brandThemeProvider);
    final theme = Theme.of(context);

    if (session == null) {
      // Defensive: should never happen — splash routes here only after a
      // brand has been selected. Push the user back to the picker.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/brand-picker');
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              SvgPicture.asset(
                brandTheme.logoAsset,
                height: 80,
                colorFilter: ColorFilter.mode(
                  brandTheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sign in to your ${_brandName(session)} account',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "You'll be redirected to ${_brandName(session)} to sign in. "
                "After approving access, you'll come back here automatically.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                _ErrorPanel(message: _error!, onRetry: _busy ? null : _login),
              ],
              const Spacer(),
              FilledButton(
                onPressed: _busy ? null : _login,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign in'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _busy ? null : _changeBrand,
                child: const Text('Use a different brand'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final session = ref.read(selectedBrandSessionProvider);
    if (session == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref.read(oauthServiceProvider).login(
            brand: session.brand,
            countryCode: session.countryCode,
          );
      if (!mounted) return;
      context.go('/otp-setup');
    } on PlatformException catch (e) {
      _log.w('OAuth cancelled or failed: ${e.code}');
      if (!mounted) return;
      setState(() {
        _error = e.code == 'CANCELED'
            ? 'Sign-in was cancelled.'
            : 'Sign-in failed: ${e.message ?? e.code}';
      });
    } on Exception catch (e, st) {
      _log.e('OAuth failed', e, st);
      if (!mounted) return;
      setState(() => _error = 'Sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _changeBrand() {
    context.go('/brand-picker');
  }

  String _brandName(BrandSession session) => _displayBrandName(session);
}

String _displayBrandName(BrandSession session) {
  final name = session.brand.name;
  if (name == 'alfaRomeo') return 'Alfa Romeo';
  return name[0].toUpperCase() + name.substring(1);
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
