import '../models/quest.dart';
import 'logger_service.dart';
import 'supabase_service.dart';

class QuestService {
  Future<List<Quest>> getActiveQuests({String? cityId}) async {
    try {
      var query = SupabaseService.client
          .from('quests')
          .select()
          .eq('status', 'active');

      if (cityId != null) {
        query = query.eq('city_id', cityId);
      }

      final data = await query;
      final quests = data.map((row) => Quest.fromJson(row)).toList();
      AppLogger.i('Fetched ${quests.length} active quests');
      return quests;
    } catch (e, st) {
      AppLogger.e('Failed to fetch active quests', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<List<Quest>> getPendingQuests({String? cityId}) async {
    try {
      var query = SupabaseService.client
          .from('quests')
          .select()
          .eq('status', 'pending');

      if (cityId != null) {
        query = query.eq('city_id', cityId);
      }

      final data = await query;
      final quests = data.map((row) => Quest.fromJson(row)).toList();
      AppLogger.i('Fetched ${quests.length} pending quests');
      return quests;
    } catch (e, st) {
      AppLogger.e('Failed to fetch pending quests', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Quest?> getQuestById(String id) async {
    try {
      final data = await SupabaseService.client
          .from('quests')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) {
        AppLogger.i('Quest not found: $id');
        return null;
      }
      final quest = Quest.fromJson(data);
      AppLogger.i('Fetched quest: $id');
      return quest;
    } catch (e, st) {
      AppLogger.e('Failed to fetch quest: $id', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Quest> createQuest({
    required String title,
    String? description,
    required QuestCategory category,
    required String cityId,
    required String createdBy,
  }) async {
    try {
      final data = await SupabaseService.client
          .from('quests')
          .insert({
            'title': title,
            'description': description,
            'category': category.value,
            'city_id': cityId,
            'created_by': createdBy,
          })
          .select()
          .single();

      final quest = Quest.fromJson(data);
      AppLogger.i('Quest created: ${quest.id}');
      return quest;
    } catch (e, st) {
      AppLogger.e('Failed to create quest', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<Quest> updateQuest(
    String id, {
    String? title,
    String? description,
    QuestCategory? category,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (category != null) updates['category'] = category.value;

      final data = await SupabaseService.client
          .from('quests')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      final quest = Quest.fromJson(data);
      AppLogger.i('Quest updated: $id');
      return quest;
    } catch (e, st) {
      AppLogger.e('Failed to update quest: $id', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> deleteQuest(String id) async {
    try {
      await SupabaseService.client.from('quests').delete().eq('id', id);
      AppLogger.i('Quest deleted: $id');
    } catch (e, st) {
      AppLogger.e('Failed to delete quest: $id', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<String?> getUserVote(String questId, String userId) async {
    try {
      final data = await SupabaseService.client
          .from('quest_votes')
          .select('vote')
          .eq('quest_id', questId)
          .eq('user_id', userId)
          .maybeSingle();
      return data?['vote'] as String?;
    } catch (e, st) {
      AppLogger.e('Failed to get user vote', error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> removeVote(String questId, String userId) async {
    try {
      await SupabaseService.client
          .from('quest_votes')
          .delete()
          .eq('quest_id', questId)
          .eq('user_id', userId);
      final upVotes = await SupabaseService.client
          .from('quest_votes')
          .select()
          .eq('quest_id', questId)
          .eq('vote', 'up');
      final downVotes = await SupabaseService.client
          .from('quest_votes')
          .select()
          .eq('quest_id', questId)
          .eq('vote', 'down');
      await SupabaseService.client
          .from('quests')
          .update({'net_votes': upVotes.length - downVotes.length})
          .eq('id', questId);
      AppLogger.i('Vote removed for quest: $questId');
    } catch (e, st) {
      AppLogger.e('Failed to remove vote', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> voteQuest(
    String questId,
    String userId,
    String vote,
  ) async {
    try {
      await SupabaseService.client.from('quest_votes').upsert({
        'quest_id': questId,
        'user_id': userId,
        'vote': vote,
      });

      final upVotes = await SupabaseService.client
          .from('quest_votes')
          .select()
          .eq('quest_id', questId)
          .eq('vote', 'up');

      final downVotes = await SupabaseService.client
          .from('quest_votes')
          .select()
          .eq('quest_id', questId)
          .eq('vote', 'down');

      final netVotes = upVotes.length - downVotes.length;

      final updatePayload = <String, dynamic>{'net_votes': netVotes};
      if (netVotes >= 100) {
        updatePayload['status'] = 'active';
      }

      await SupabaseService.client
          .from('quests')
          .update(updatePayload)
          .eq('id', questId);

      AppLogger.i('Vote recorded for quest: $questId ($vote, net: $netVotes)');
    } catch (e, st) {
      AppLogger.e('Failed to vote on quest: $questId', error: e, stackTrace: st);
      rethrow;
    }
  }
}
