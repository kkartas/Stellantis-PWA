import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/stellantis/otp/otp_service.dart';

const _log = AppLogger('OtpSetupPage');

class OtpSetupPage extends ConsumerStatefulWidget {
  const OtpSetupPage({super.key});

  @override
  ConsumerState<OtpSetupPage> createState() => _OtpSetupPageState();
}

class _OtpSetupPageState extends ConsumerState<OtpSetupPage> {
  final _smsController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _smsController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Enable remote commands')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _InfoCard(
                  icon: Icons.lock_outline,
                  text:
                      'Remote commands (lock, climate, charge) need a second '
                      'factor. Stellantis will send a one-time code to your '
                      'phone number on file.',
                  theme: theme,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _smsController,
                  decoration: const InputDecoration(
                    labelText: 'SMS code',
                    hintText: 'From the text message',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      (v == null || v.trim().length < 4)
                          ? 'Enter the code from the SMS'
                          : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pinController,
                  decoration: const InputDecoration(
                    labelText: 'PIN',
                    hintText: '4 digits — used for every remote command',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.length < 4) return 'PIN must be at least 4 digits';
                    return null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorCard(message: _error!, theme: theme),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _activate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Activate'),
                  ),
                ),
                TextButton(
                  onPressed: _busy ? null : _skip,
                  child: const Text('Skip for now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _activate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final ok = await ref.read(otpServiceProvider).activate(
            _smsController.text.trim(),
            _pinController.text.trim(),
          );
      if (!mounted) return;
      if (ok) {
        context.go('/vehicle-picker');
      } else {
        setState(() {
          _error = 'Could not activate. Check the SMS code and try again.';
        });
      }
    } catch (e, st) {
      _log.e('OTP activation threw', e, st);
      if (!mounted) return;
      setState(() => _error = 'Activation failed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _skip() {
    context.go('/vehicle-picker');
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.text,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.theme});

  final String message;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              color: theme.colorScheme.onErrorContainer),
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
