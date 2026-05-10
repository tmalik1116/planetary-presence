import 'supabase_service.dart';
import 'logger_service.dart';

class ProfileData {
  final String username;
  final String email;
  final int totalPoints;
  final DateTime joinedAt;
  final String? homeCityName;

  const ProfileData({
    required this.username,
    required this.email,
    required this.totalPoints,
    required this.joinedAt,
    this.homeCityName,
  });
}

class ProfileService {
  final _client = SupabaseService.client;

  Future<ProfileData?> getProfile(String userId) async {
    AppLogger.i('ProfileService: getProfile userId=$userId');
    try {
      final data = await _client
          .from('users')
          .select('username, email, total_points, joined_at, cities(name)')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        AppLogger.w('ProfileService: no profile found for userId=$userId');
        return null;
      }

      return ProfileData(
        username: data['username'] as String? ?? '',
        email: data['email'] as String? ?? '',
        totalPoints: data['total_points'] as int? ?? 0,
        joinedAt: DateTime.parse(data['joined_at'] as String),
        homeCityName: (data['cities'] as Map?)?['name'] as String?,
      );
    } catch (e, st) {
      AppLogger.e('ProfileService: getProfile failed', error: e, stackTrace: st);
      return null;
    }
  }
}
