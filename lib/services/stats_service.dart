import 'supabase_service.dart';
import 'logger_service.dart';

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

  static Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    bool lastMonth = false,
  }) async {
    if (!lastMonth) {
      // Simple case: use denormalised total_points on users table
      final rows = await _client
          .from('users')
          .select('id, username, total_points')
          .order('total_points', ascending: false)
          .limit(50);

      // Fetch quest counts in one query
      final questCounts = await _fetchQuestCounts(
        userIds: (rows as List).map((r) => r['id'] as String).toList(),
      );

      return List<LeaderboardEntry>.generate(rows.length, (i) {
        final row = rows[i] as Map<String, dynamic>;
        final uid = row['id'] as String;
        return LeaderboardEntry(
          userId: uid,
          username: row['username'] as String? ?? 'Unknown',
          totalPoints: (row['total_points'] as int?) ?? 0,
          questCount: questCounts[uid] ?? 0,
          rank: i + 1,
        );
      });
    } else {
      return _getLeaderboardFromCompletions(
        userFilter: null,
        lastMonth: true,
      );
    }
  }

  static Future<List<LeaderboardEntry>> getLeaderboard({
    required String scope,
    String? cityId,
    String? country,
    List<String>? friendIds,
    bool lastMonth = false,
  }) async {
    switch (scope) {
      case 'friends':
        if (friendIds == null || friendIds.isEmpty) return [];
        // Include the current user's own entry alongside friends
        final currentUserId = friendIds.isNotEmpty ? null : null; // resolved via caller
        final allIds = [...friendIds];
        return _getLeaderboardFromCompletions(
          userFilter: allIds,
          lastMonth: lastMonth,
        );

      case 'city':
        if (cityId == null) return [];
        if (!lastMonth) {
          final rows = await _client
              .from('users')
              .select('id, username, total_points')
              .eq('home_city_id', cityId)
              .order('total_points', ascending: false)
              .limit(50);

          final questCounts = await _fetchQuestCounts(
            userIds: (rows as List).map((r) => r['id'] as String).toList(),
          );

          return List<LeaderboardEntry>.generate(rows.length, (i) {
            final row = rows[i] as Map<String, dynamic>;
            final uid = row['id'] as String;
            return LeaderboardEntry(
              userId: uid,
              username: row['username'] as String? ?? 'Unknown',
              totalPoints: (row['total_points'] as int?) ?? 0,
              questCount: questCounts[uid] ?? 0,
              rank: i + 1,
            );
          });
        } else {
          // For last-month city, fetch users in city then filter completions
          final cityUsers = await _client
              .from('users')
              .select('id')
              .eq('home_city_id', cityId);
          final ids = (cityUsers as List).map((r) => r['id'] as String).toList();
          return _getLeaderboardFromCompletions(
            userFilter: ids,
            lastMonth: true,
          );
        }

      case 'country':
        if (country == null) return [];
        final rows = await _client
            .from('users')
            .select('id, username, total_points, cities!users_home_city_id_fkey(country)')
            .order('total_points', ascending: false)
            .limit(500);
        final filtered = (rows as List).where((r) {
          final cityData = r['cities'] as Map?;
          return (cityData?['country'] as String?) == country;
        }).toList();

        if (!lastMonth) {
          final questCounts = await _fetchQuestCounts(
            userIds: filtered.map((r) => r['id'] as String).toList(),
          );
          return List<LeaderboardEntry>.generate(filtered.length, (i) {
            final row = filtered[i] as Map<String, dynamic>;
            final uid = row['id'] as String;
            return LeaderboardEntry(
              userId: uid,
              username: row['username'] as String? ?? 'Unknown',
              totalPoints: (row['total_points'] as int?) ?? 0,
              questCount: questCounts[uid] ?? 0,
              rank: i + 1,
            );
          });
        } else {
          final ids = filtered.map((r) => r['id'] as String).toList();
          return _getLeaderboardFromCompletions(
            userFilter: ids,
            lastMonth: true,
          );
        }

      case 'global':
      default:
        return getGlobalLeaderboard(lastMonth: lastMonth);
    }
  }

  /// Builds a leaderboard from the completions table.
  /// Used for last-month and friends scopes.
  static Future<List<LeaderboardEntry>> _getLeaderboardFromCompletions({
    List<String>? userFilter,
    required bool lastMonth,
  }) async {
    try {
      var query = _client
          .from('completions')
          .select('user_id, points_awarded, completed_at, users!completions_user_id_fkey(id, username)');

      if (lastMonth) {
        final cutoff = DateTime.now().subtract(const Duration(days: 30));
        query = query.gte('completed_at', cutoff.toIso8601String());
      }

      if (userFilter != null && userFilter.isNotEmpty) {
        query = query.inFilter('user_id', userFilter);
      }

      final rows = await query;

      // Aggregate per user
      final Map<String, String> usernames = {};
      final Map<String, int> points = {};
      final Map<String, int> quests = {};

      for (final row in (rows as List)) {
        final uid = row['user_id'] as String;
        final userData = row['users'] as Map<String, dynamic>?;
        usernames[uid] = userData?['username'] as String? ?? 'Unknown';
        points[uid] = (points[uid] ?? 0) + (row['points_awarded'] as int? ?? 0);
        quests[uid] = (quests[uid] ?? 0) + 1;
      }

      // Sort by total points descending
      final sorted = points.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return List<LeaderboardEntry>.generate(sorted.length, (i) {
        final uid = sorted[i].key;
        return LeaderboardEntry(
          userId: uid,
          username: usernames[uid] ?? 'Unknown',
          totalPoints: sorted[i].value,
          questCount: quests[uid] ?? 0,
          rank: i + 1,
        );
      });
    } catch (e, st) {
      AppLogger.e('StatsService: _getLeaderboardFromCompletions failed',
          error: e, stackTrace: st);
      return [];
    }
  }

  /// Fetches quest completion counts for a list of user IDs.
  static Future<Map<String, int>> _fetchQuestCounts({
    required List<String> userIds,
  }) async {
    if (userIds.isEmpty) return {};
    try {
      final rows = await _client
          .from('completions')
          .select('user_id')
          .inFilter('user_id', userIds);

      final Map<String, int> counts = {};
      for (final row in (rows as List)) {
        final uid = row['user_id'] as String;
        counts[uid] = (counts[uid] ?? 0) + 1;
      }
      return counts;
    } catch (e, st) {
      AppLogger.e('StatsService: _fetchQuestCounts failed', error: e, stackTrace: st);
      return {};
    }
  }

  /// Returns XP earned per time bucket for a list of userIds.
  /// period: 'day' (last 24h, hourly), 'week' (last 7d, daily), 'month' (last 30d, daily)
  /// Returns Map<userId, Map<bucketKey, points>>
  /// bucketKey format: 'YYYY-MM-DD' for week/month, 'YYYY-MM-DD HH' for day
  static Future<Map<String, Map<String, int>>> getXpTimeSeries({
    required List<String> userIds,
    required String period,
  }) async {
    if (userIds.isEmpty) return {};
    try {
      final now = DateTime.now();
      final since = period == 'day'
          ? now.subtract(const Duration(hours: 24))
          : period == 'week'
              ? now.subtract(const Duration(days: 7))
              : now.subtract(const Duration(days: 30));

      final data = await SupabaseService.client
          .from('completions')
          .select('user_id, points_awarded, completed_at')
          .inFilter('user_id', userIds)
          .gte('completed_at', since.toIso8601String());

      final Map<String, Map<String, int>> result = {};
      for (final uid in userIds) {
        result[uid] = {};
      }

      for (final row in data) {
        final uid = row['user_id'] as String;
        final pts = row['points_awarded'] as int;
        final dt = DateTime.parse(row['completed_at'] as String).toLocal();
        final key = period == 'day'
            ? '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}'
            : '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        result[uid]?[key] = (result[uid]?[key] ?? 0) + pts;
      }
      return result;
    } catch (e, st) {
      AppLogger.e('StatsService: getXpTimeSeries failed', error: e, stackTrace: st);
      return {};
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
