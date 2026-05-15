import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/features/auth/data/brand_session.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/storage/app_database.dart';
import 'package:stellantis_mobile/theme/brand_detector.dart';
import 'package:stellantis_mobile/theme/brand_theme.dart';

const _log = AppLogger('SessionService');

final sessionServiceProvider = Provider<SessionService>(SessionService.new);

/// Wipes every piece of state tied to the signed-in account so the next
/// account that logs in starts from a clean slate.
///
/// Cleared:
///   - flutter_secure_storage: OAuth tokens, brand session, selected VIN,
///     OTP iWebo blob (everything we write is under this single store)
///   - Isar: every collection (vehicles, status, trips, charges, …)
///   - Riverpod in-memory state for selected brand / VIN / theme
class SessionService {
  SessionService(this._ref);

  final Ref _ref;

  Future<void> logout() async {
    _log.i('Logging out and wiping local session state');

    // Secure storage: deleteAll is safe because every key in this app is
    // namespaced under flutter_secure_storage and belongs to the user.
    await const FlutterSecureStorage().deleteAll();

    // Isar: clear every collection. Keep the database open — the user may
    // re-authenticate without restarting the app.
    final isar = await _ref.read(isarProvider.future);
    await isar.writeTxn(isar.clear);

    // In-memory Riverpod state.
    _ref.read(selectedBrandSessionProvider.notifier).state = null;
    _ref.read(selectedVinProvider.notifier).state = null;
    _ref.read(brandOverrideProvider.notifier).state = null;
    _ref.read(brandThemeProvider.notifier).state = BrandTheme.neutral;
  }
}
