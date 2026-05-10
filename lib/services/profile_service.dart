import 'supabase_service.dart';
import 'logger_service.dart';

class ProfileData {
  final String username;
  final String email;
  final int totalPoints;
  final DateTime joinedAt;
  final String? homeCityName;
  final String? homeCityId;
  final String? homeCityCountry;

  const ProfileData({
    required this.username,
    required this.email,
    required this.totalPoints,
    required this.joinedAt,
    this.homeCityName,
    this.homeCityId,
    this.homeCityCountry,
  });
}

class ProfileService {
  final _client = SupabaseService.client;

  Future<ProfileData?> getProfile(String userId) async {
    AppLogger.i('ProfileService: getProfile userId=$userId');
    try {
      final data = await _client
          .from('users')
          .select('username, email, total_points, joined_at, home_city_id, cities(name, country)')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        AppLogger.w('ProfileService: no profile found for userId=$userId');
        return null;
      }

      final cityMap = data['cities'] as Map?;
      return ProfileData(
        username: data['username'] as String? ?? '',
        email: data['email'] as String? ?? '',
        totalPoints: data['total_points'] as int? ?? 0,
        joinedAt: DateTime.parse(data['joined_at'] as String),
        homeCityName: cityMap?['name'] as String?,
        homeCityId: data['home_city_id'] as String?,
        homeCityCountry: cityMap?['country'] as String?,
      );
    } catch (e, st) {
      AppLogger.e('ProfileService: getProfile failed', error: e, stackTrace: st);
      return null;
    }
  }
}
