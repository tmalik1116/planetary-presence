import 'dart:math' as math;
import '../services/logger_service.dart';
import '../services/supabase_service.dart';

class CityData {
  final String id;
  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lng;

  const CityData({
    required this.id,
    required this.name,
    required this.country,
    this.state,
    required this.lat,
    required this.lng,
  });

  static CityData? tryFromMap(Map<String, dynamic> map) {
    final latRaw = map['lat'];
    final lngRaw = map['lng'];
    if (latRaw == null || lngRaw == null) return null;
    return CityData(
      id: map['id'] as String,
      name: map['name'] as String,
      country: map['country'] as String,
      state: map['state'] as String?,
      lat: (latRaw as num).toDouble(),
      lng: (lngRaw as num).toDouble(),
    );
  }
}

class CityService {
  Future<List<CityData>> getCities() async {
    try {
      AppLogger.i('CityService: fetching cities from Supabase');
      final response = await SupabaseService.client
          .from('cities')
          .select('id, name, country, state, lat, lng');

      final cities = (response as List<dynamic>)
          .map((row) => CityData.tryFromMap(row as Map<String, dynamic>))
          .whereType<CityData>()
          .toList();

      AppLogger.i('CityService: loaded ${cities.length} cities');
      return cities;
    } catch (e, st) {
      AppLogger.e('CityService: failed to fetch cities', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<CityData?> getNearestCity(double lat, double lng) async {
    final sw = Stopwatch()..start();

    final cities = await getCities();
    AppLogger.i('CityService: getCities took ${sw.elapsedMilliseconds}ms (${cities.length} cities)');

    if (cities.isEmpty) return null;

    final searchStart = sw.elapsedMilliseconds;
    CityData? nearest;
    double minDistance = double.infinity;

    for (final city in cities) {
      final distance = haversineMeters(lat, lng, city.lat, city.lng);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = city;
      }
    }

    AppLogger.i('CityService: haversine search took ${sw.elapsedMilliseconds - searchStart}ms');
    AppLogger.i('CityService: nearest city is ${nearest?.name} (total ${sw.elapsedMilliseconds}ms)');
    sw.stop();
    return nearest;
  }

  static double haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}
