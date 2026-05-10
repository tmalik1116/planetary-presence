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

  factory CityData.fromMap(Map<String, dynamic> map) {
    final wkt = map['coordinates'] as String;
    final inner = wkt.substring(wkt.indexOf('(') + 1, wkt.indexOf(')'));
    final parts = inner.split(' ');
    final lng = double.parse(parts[0]);
    final lat = double.parse(parts[1]);
    return CityData(
      id: map['id'] as String,
      name: map['name'] as String,
      country: map['country'] as String,
      state: map['state'] as String?,
      lat: lat,
      lng: lng,
    );
  }
}

class CityService {
  Future<List<CityData>> getCities() async {
    try {
      AppLogger.i('CityService: fetching cities from Supabase');
      final response = await SupabaseService.client
          .from('cities')
          .select('id, name, country, state, coordinates');

      final cities = (response as List<dynamic>)
          .map((row) => CityData.fromMap(row as Map<String, dynamic>))
          .toList();

      AppLogger.i('CityService: loaded ${cities.length} cities');
      return cities;
    } catch (e, st) {
      AppLogger.e('CityService: failed to fetch cities', error: e, stackTrace: st);
      rethrow;
    }
  }
}
