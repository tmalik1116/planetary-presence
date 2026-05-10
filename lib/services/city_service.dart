import 'package:geolocator/geolocator.dart';
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
    final cities = await getCities();
    if (cities.isEmpty) return null;

    CityData? nearest;
    double minDistance = double.infinity;

    for (final city in cities) {
      final distance = Geolocator.distanceBetween(lat, lng, city.lat, city.lng);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = city;
      }
    }
    
    AppLogger.i('CityService: nearest city is ${nearest?.name}');
    return nearest;
  }
}
