import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/features/dashboard/data/quick_action_controller.dart';

class QuickActionsRow extends ConsumerWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quickActionControllerProvider);
    final controller = ref.read(quickActionControllerProvider.notifier);

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: QuickAction.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final action = QuickAction.values[i];
          final pending = state.isPending(action);
          return _QuickActionTile(
            icon: action.icon,
            label: action.label,
            pending: pending,
            onTap: pending ? null : () => controller.dispatch(action),
          );
        },
      ),
    );
  }
}

enum QuickAction {
  lock(Icons.lock_outline, 'Lock'),
  unlock(Icons.lock_open, 'Unlock'),
  climate(Icons.ac_unit, 'Climate'),
  charge(Icons.bolt, 'Charge'),
  horn(Icons.notifications_active_outlined, 'Horn'),
  lights(Icons.lightbulb_outline, 'Lights');

  const QuickAction(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.pending,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool pending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 88,
      child: Material(
        color: pending
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: pending
                    ? SizedBox(
                        key: const ValueKey('spinner'),
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: scheme.onPrimaryContainer,
                        ),
                      )
                    : Icon(
                        icon,
                        key: ValueKey('icon-$label'),
                        size: 28,
                        color: scheme.primary,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: pending
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
