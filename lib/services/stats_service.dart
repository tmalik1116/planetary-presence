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

  static Future<int> getUserQuestCount(String userId) async {
    final rows = await _client
        .from('completions')
        .select('id')
        .eq('user_id', userId);
    return (rows as List).length;
  }
}
