import 'package:supabase_flutter/supabase_flutter.dart';

import 'logger_service.dart';
import 'supabase_service.dart';

class CompletionService {
  static final _client = SupabaseService.client;

  /// Inserts a new completion row into the `completions` table.
  ///
  /// Returns the UUID of the newly created completion.
  Future<String> submitCompletion({
    required String questId,
    required String cityId, // 👈 Require the cityId
    required int pointsAwarded,
    required String userId,
    required int difficultyRating,
    String? tagline,
    String? mediaUrl,
    required String mediaType,
    List<String> taggedUserIds = const [],
  }) async {
    AppLogger.i(
      'CompletionService: submitting completion for quest=$questId '
      'user=$userId rating=$difficultyRating',
    );

    try {
      final data = await _client
          .from('completions')
          .insert({
            'quest_id': questId,
            'city_id': cityId,
            'user_id': userId,
            'points_awarded': pointsAwarded,
            'difficulty_rating': difficultyRating,
            'media_type': mediaType,
            if (tagline != null && tagline.isNotEmpty) 'tagline': tagline,
            if (mediaUrl != null) 'media_url': mediaUrl,
            if (taggedUserIds.isNotEmpty) 'tagged_user_ids': taggedUserIds,
          })
          .select('id')
          .single();

      final id = data['id'] as String;
      AppLogger.i('CompletionService: completion created id=$id');
      return id;
    } catch (e, st) {
      AppLogger.e(
        'CompletionService: submitCompletion failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Searches for users by username prefix (for the tag-friends picker).
  ///
  /// Excludes [excludeUserId] (the current user) from results.
  Future<List<Map<String, dynamic>>> searchUsers(
    String query, {
    required String excludeUserId,
    int limit = 10,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      final results = await _client
          .from('users')
          .select('id, username')
          .ilike('username', '%${query.trim()}%')
          .neq('id', excludeUserId)
          .limit(limit);

      AppLogger.i(
        'CompletionService: user search "$query" → ${results.length} results',
      );
      return List<Map<String, dynamic>>.from(results);
    } catch (e, st) {
      AppLogger.e(
        'CompletionService: searchUsers failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
