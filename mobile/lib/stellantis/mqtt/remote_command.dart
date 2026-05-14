/// Sealed hierarchy representing every PSA remote command.
///
/// Pass an instance to the MQTT service's `sendCommand` to dispatch.
sealed class RemoteCommand {
  const RemoteCommand({required this.vin});

  /// Vehicle VIN targeted by this command.
  final String vin;
}

/// Sound the horn once.
final class HornCommand extends RemoteCommand {
  const HornCommand({required super.vin});
}

/// Flash the headlights for 10 seconds.
final class LightsCommand extends RemoteCommand {
  const LightsCommand({required super.vin});
}

/// Poll vehicle state (wakeup / charge-state refresh).
final class WakeupCommand extends RemoteCommand {
  const WakeupCommand({required super.vin});
}

/// Lock all doors.
final class LockCommand extends RemoteCommand {
  const LockCommand({required super.vin});
}

/// Unlock all doors.
final class UnlockCommand extends RemoteCommand {
  const UnlockCommand({required super.vin});
}

/// Start climate preconditioning.
final class ClimateOnCommand extends RemoteCommand {
  const ClimateOnCommand({required super.vin});
}

/// Stop climate preconditioning.
final class ClimateOffCommand extends RemoteCommand {
  const ClimateOffCommand({required super.vin});
}

/// Start charging immediately.
final class ChargeOnCommand extends RemoteCommand {
  const ChargeOnCommand({required super.vin});
}

/// Stop (or delay) charging.
final class ChargeOffCommand extends RemoteCommand {
  const ChargeOffCommand({required super.vin});
}

/// Set the delayed-charge schedule to [hour]:[minute].
final class SetChargeScheduleCommand extends RemoteCommand {
  const SetChargeScheduleCommand({
    required super.vin,
    required this.hour,
    required this.minute,
  });

  final int hour;
  final int minute;
}
