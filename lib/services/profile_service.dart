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
  final String? avatarUrl;

  const ProfileData({
    required this.username,
    required this.email,
    required this.totalPoints,
    required this.joinedAt,
    this.homeCityName,
    this.homeCityId,
    this.homeCityCountry,
    this.avatarUrl,
  });
}

class ProfileService {
  final _client = SupabaseService.client;

  Future<ProfileData?> getProfile(String userId) async {
    AppLogger.i('ProfileService: getProfile userId=$userId');
    try {
      final data = await _client
          .from('users')
          .select('username, email, total_points, joined_at, home_city_id, avatar_url')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        AppLogger.w('ProfileService: no profile found for userId=$userId');
        return null;
      }

      String? homeCityName;
      String? homeCityCountry;
      final homeCityId = data['home_city_id'] as String?;

      if (homeCityId != null) {
        final cityData = await _client
            .from('cities')
            .select('name, country')
            .eq('id', homeCityId)
            .maybeSingle();
        homeCityName = cityData?['name'] as String?;
        homeCityCountry = cityData?['country'] as String?;
      }

      return ProfileData(
        username: data['username'] as String? ?? '',
        email: data['email'] as String? ?? '',
        totalPoints: data['total_points'] as int? ?? 0,
        joinedAt: DateTime.parse(data['joined_at'] as String),
        homeCityName: homeCityName,
        homeCityId: homeCityId,
        homeCityCountry: homeCityCountry,
        avatarUrl: data['avatar_url'] as String?,
      );
    } catch (e, st) {
      AppLogger.e('ProfileService: getProfile failed', error: e, stackTrace: st);
      return null;
    }
  }

  Future<Map<String, int>> getActivityData(String userId) async {
    AppLogger.i('ProfileService: getActivityData userId=$userId');
    try {
      final since = DateTime.now().subtract(const Duration(days: 49));
      final data = await _client
          .from('completions')
          .select('completed_at')
          .eq('user_id', userId)
          .gte('completed_at', since.toIso8601String());
      final Map<String, int> counts = {};
      for (final row in data) {
        final dt = DateTime.parse(row['completed_at'] as String).toLocal();
        final key =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        counts[key] = (counts[key] ?? 0) + 1;
      }
      return counts;
    } catch (e, st) {
      AppLogger.e('ProfileService: getActivityData failed', error: e, stackTrace: st);
      return {};
    }
  }
}
