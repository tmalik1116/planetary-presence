import '../models/quest.dart';
import 'supabase_service.dart';

class QuestService {
  Future<List<Quest>> getActiveQuests({String? cityId}) async {
    var query = SupabaseService.client
        .from('quests')
        .select()
        .eq('status', 'active');

    if (cityId != null) {
      query = query.eq('city_id', cityId);
    }

    final data = await query;
    return data.map((row) => Quest.fromJson(row)).toList();
  }

  Future<List<Quest>> getPendingQuests({String? cityId}) async {
    var query = SupabaseService.client
        .from('quests')
        .select()
        .eq('status', 'pending');

    if (cityId != null) {
      query = query.eq('city_id', cityId);
    }

    final data = await query;
    return data.map((row) => Quest.fromJson(row)).toList();
  }

  Future<Quest?> getQuestById(String id) async {
    final data = await SupabaseService.client
        .from('quests')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return Quest.fromJson(data);
  }

  Future<Quest> createQuest({
    required String title,
    String? description,
    required QuestCategory category,
    required String cityId,
    required String createdBy,
  }) async {
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

    return Quest.fromJson(data);
  }

  Future<Quest> updateQuest(
    String id, {
    String? title,
    String? description,
    QuestCategory? category,
  }) async {
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

    return Quest.fromJson(data);
  }

  Future<void> deleteQuest(String id) async {
    await SupabaseService.client.from('quests').delete().eq('id', id);
  }

  Future<void> voteQuest(
    String questId,
    String userId,
    String vote,
  ) async {
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
  }
}
