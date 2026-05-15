import 'package:flutter/material.dart';

/// Horizontally scrollable row of primary remote commands. The actual
/// command dispatch lands in 6.2 — this commit ships the layout so the
/// dashboard hero composition is reviewable on its own.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key, this.onAction});

  /// Tap callback. Each [QuickAction] identifies which command the user
  /// asked for; null while the row is presentational only.
  final void Function(QuickAction action)? onAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: QuickAction.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final action = QuickAction.values[i];
          return _QuickActionTile(
            icon: action.icon,
            label: action.label,
            onTap: onAction == null ? null : () => onAction!(action),
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
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: SizedBox(
        width: 88,
        child: Material(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28, color: scheme.primary),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
