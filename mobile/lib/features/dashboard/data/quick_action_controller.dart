import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/features/dashboard/widgets/quick_actions_row.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/mqtt/mqtt_client_service.dart';
import 'package:stellantis_mobile/stellantis/mqtt/remote_command.dart';

const _log = AppLogger('QuickAction');

/// Per-action lifecycle the UI watches to paint optimistic state.
enum QuickActionStatus { idle, pending, success, failure }

/// State exposed to the UI: which actions are pending right now plus the
/// most recent terminal outcome (used to show a one-shot snackbar).
class QuickActionState {
  const QuickActionState({
    this.pending = const {},
    this.lastResult,
    this.lastAction,
    this.lastError,
  });

  /// Actions currently in flight.
  final Set<QuickAction> pending;

  /// Outcome of the most recent completed action. `null` if nothing has
  /// completed since the UI last consumed [lastResult].
  final QuickActionStatus? lastResult;

  /// The action that produced [lastResult].
  final QuickAction? lastAction;

  /// Error message captured on failure, displayed in the snackbar.
  final String? lastError;

  bool isPending(QuickAction action) => pending.contains(action);

  QuickActionState copyWith({
    Set<QuickAction>? pending,
    QuickActionStatus? lastResult,
    QuickAction? lastAction,
    String? lastError,
    bool clearLastResult = false,
  }) {
    return QuickActionState(
      pending: pending ?? this.pending,
      lastResult: clearLastResult ? null : (lastResult ?? this.lastResult),
      lastAction: clearLastResult ? null : (lastAction ?? this.lastAction),
      lastError: clearLastResult ? null : (lastError ?? this.lastError),
    );
  }
}

final quickActionControllerProvider =
    NotifierProvider<QuickActionController, QuickActionState>(
  QuickActionController.new,
);

/// Dispatches user-initiated remote commands with optimistic feedback:
/// the tile shows a spinner while the MQTT publish is in flight, then
/// surfaces success or failure to the dashboard via [QuickActionState].
class QuickActionController extends Notifier<QuickActionState> {
  @override
  QuickActionState build() => const QuickActionState();

  Future<void> dispatch(QuickAction action) async {
    final vin = ref.read(selectedVinProvider);
    if (vin == null) {
      _log.w('dispatch($action) skipped — no active VIN');
      return;
    }
    if (state.pending.contains(action)) {
      _log.d('dispatch($action) ignored — already pending');
      return;
    }

    state = state.copyWith(
      pending: {...state.pending, action},
      clearLastResult: true,
    );

    final mqtt = ref.read(mqttClientServiceProvider);
    final command = _toCommand(action, vin);

    try {
      await mqtt.sendCommand(command);
      _log.i('$action succeeded for $vin');
      state = state.copyWith(
        pending: {...state.pending}..remove(action),
        lastResult: QuickActionStatus.success,
        lastAction: action,
      );
    } catch (e, st) {
      _log.e('$action failed', e, st);
      state = state.copyWith(
        pending: {...state.pending}..remove(action),
        lastResult: QuickActionStatus.failure,
        lastAction: action,
        lastError: e.toString(),
      );
    }
  }

  /// Mark the current [lastResult] as consumed so the snackbar doesn't fire
  /// again on the next rebuild.
  void acknowledgeLastResult() {
    state = state.copyWith(clearLastResult: true);
  }

  RemoteCommand _toCommand(QuickAction action, String vin) => switch (action) {
        QuickAction.lock => LockCommand(vin: vin),
        QuickAction.unlock => UnlockCommand(vin: vin),
        QuickAction.climate => ClimateOnCommand(vin: vin),
        QuickAction.charge => ChargeOnCommand(vin: vin),
        QuickAction.horn => HornCommand(vin: vin),
        QuickAction.lights => LightsCommand(vin: vin),
      };
}
