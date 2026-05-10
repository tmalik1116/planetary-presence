import 'package:geolocator/geolocator.dart';
import 'auth_service.dart';
import 'logger_service.dart';
import 'supabase_service.dart';

class LocationService {
  static Future<Position?> getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        AppLogger.w('LocationService: permission denied ($permission)');
        return null;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      AppLogger.i(
        'LocationService: position=${position.latitude},${position.longitude}',
      );
      return position;
    } catch (e, st) {
      AppLogger.e('LocationService: getCurrentPosition failed', error: e, stackTrace: st);
      return null;
    }
  }

  static Future<bool> hasPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e, st) {
      AppLogger.e('LocationService: hasPermission failed', error: e, stackTrace: st);
      return false;
    }
  }

  static Future<void> updateUserCoordinates() async {
    final user = AuthService.currentUser;
    if (user == null) {
      AppLogger.w('LocationService: updateUserCoordinates — no logged-in user');
      return;
    }
    try {
      final position = await getCurrentPosition();
      if (position == null) {
        AppLogger.w('LocationService: updateUserCoordinates — location unavailable');
        return;
      }
      final wkt = 'POINT(${position.longitude} ${position.latitude})';
      await SupabaseService.client
          .from('users')
          .update({'coordinates': wkt})
          .eq('id', user.id);
      AppLogger.i('LocationService: updated coordinates for uid=${user.id} → $wkt');
    } catch (e, st) {
      AppLogger.e('LocationService: updateUserCoordinates failed', error: e, stackTrace: st);
    }
  }
}
