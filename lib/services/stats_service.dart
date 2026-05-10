import 'supabase_service.dart';

class LeaderboardEntry {
  final String userId;
  final String username;
  final int totalPoints;
  final int questCount;
  final int rank;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.totalPoints,
    required this.questCount,
    required this.rank,
  });
}

class StatsService {
  static final _client = SupabaseService.client;

  static Future<List<LeaderboardEntry>> getGlobalLeaderboard() async {
    final rows = await _client
        .from('users')
        .select('id, username, total_points')
        .order('total_points', ascending: false)
        .limit(50);

    return List<LeaderboardEntry>.generate(rows.length, (i) {
      final row = rows[i] as Map<String, dynamic>;
      return LeaderboardEntry(
        userId: row['id'] as String,
        username: row['username'] as String? ?? 'Unknown',
        totalPoints: (row['total_points'] as int?) ?? 0,
        questCount: 0,
        rank: i + 1,
      );
    });
  }

  static Future<List<LeaderboardEntry>> getLeaderboard({
    required String scope,
    String? cityId,
    String? country,
  }) async {
    switch (scope) {
      case 'city':
        if (cityId == null) return [];
        final rows = await _client
            .from('users')
            .select('id, username, total_points')
            .eq('home_city_id', cityId)
            .order('total_points', ascending: false)
            .limit(50);
        return List<LeaderboardEntry>.generate(rows.length, (i) {
          final row = rows[i] as Map<String, dynamic>;
          return LeaderboardEntry(
            userId: row['id'] as String,
            username: row['username'] as String? ?? 'Unknown',
            totalPoints: (row['total_points'] as int?) ?? 0,
            questCount: 0,
            rank: i + 1,
          );
        });

      case 'country':
        if (country == null) return [];
        // Fetch all users with their city's country, then filter client-side.
        final rows = await _client
            .from('users')
            .select('id, username, total_points, cities!users_home_city_id_fkey(country)')
            .order('total_points', ascending: false)
            .limit(500);
        final filtered = (rows as List).where((r) {
          final cityData = r['cities'] as Map?;
          final c = cityData?['country'] as String?;
          return c == country;
        }).toList();
        return List<LeaderboardEntry>.generate(filtered.length, (i) {
          final row = filtered[i] as Map<String, dynamic>;
          return LeaderboardEntry(
            userId: row['id'] as String,
            username: row['username'] as String? ?? 'Unknown',
            totalPoints: (row['total_points'] as int?) ?? 0,
            questCount: 0,
            rank: i + 1,
          );
        });

      case 'global':
      default:
        return getGlobalLeaderboard();
    }
  }

  static Future<int> getUserQuestCount(String userId) async {
    final rows = await _client
        .from('completions')
        .select('id')
        .eq('user_id', userId);
    return (rows as List).length;
  }
}
