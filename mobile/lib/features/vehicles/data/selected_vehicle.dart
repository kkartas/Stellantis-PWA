import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kSelectedVinKey = 'selected_vin';

final selectedVehicleStoreProvider = Provider<SelectedVehicleStore>(
  (_) => const SelectedVehicleStore(),
);

/// Persists the VIN of the currently active vehicle across launches.
class SelectedVehicleStore {
  const SelectedVehicleStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> load() => _storage.read(key: _kSelectedVinKey);

  Future<void> save(String vin) =>
      _storage.write(key: _kSelectedVinKey, value: vin);

  Future<void> clear() => _storage.delete(key: _kSelectedVinKey);
}

/// In-memory active VIN. The shell reads this to know which car to render.
final selectedVinProvider = StateProvider<String?>((_) => null);
