import 'logger_service.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

enum FriendshipStatus { none, pendingSent, pendingReceived, friends }

class FriendUser {
  final String id;
  final String username;
  final int totalPoints;
  final String? avatarUrl;
  final String? requestId; // friend_requests.id, if applicable

  const FriendUser({
    required this.id,
    required this.username,
    required this.totalPoints,
    this.avatarUrl,
    this.requestId,
  });

  factory FriendUser.fromJson(Map<String, dynamic> json, {String? requestId}) {
    return FriendUser(
      id: json['id'] as String,
      username: json['username'] as String? ?? 'Unknown',
      totalPoints: json['total_points'] as int? ?? 0,
      avatarUrl: json['avatar_url'] as String?,
      requestId: requestId,
    );
  }
}

class FriendService {
  static final _client = SupabaseService.client;

  String get _currentUserId => AuthService.currentUser!.id;

  // ─── Request actions ──────────────────────────────────────────────────────

  Future<void> sendRequest(String targetUserId) async {
    AppLogger.i('FriendService: sendRequest to $targetUserId');
    try {
      await _client.from('friend_requests').insert({
        'sender_id': _currentUserId,
        'receiver_id': targetUserId,
        'status': 'pending',
      });
    } catch (e, st) {
      AppLogger.e('FriendService: sendRequest failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> acceptRequest(String requestId) async {
    AppLogger.i('FriendService: acceptRequest $requestId');
    try {
      await _client
          .from('friend_requests')
          .update({'status': 'accepted'})
          .eq('id', requestId);
    } catch (e, st) {
      AppLogger.e('FriendService: acceptRequest failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> declineRequest(String requestId) async {
    AppLogger.i('FriendService: declineRequest $requestId');
    try {
      await _client
          .from('friend_requests')
          .update({'status': 'declined'})
          .eq('id', requestId);
    } catch (e, st) {
      AppLogger.e('FriendService: declineRequest failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> cancelRequest(String targetUserId) async {
    AppLogger.i('FriendService: cancelRequest to $targetUserId');
    try {
      await _client
          .from('friend_requests')
          .delete()
          .eq('sender_id', _currentUserId)
          .eq('receiver_id', targetUserId);
    } catch (e, st) {
      AppLogger.e('FriendService: cancelRequest failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> unfriend(String targetUserId) async {
    AppLogger.i('FriendService: unfriend $targetUserId');
    try {
      // Delete in either direction
      await _client
          .from('friend_requests')
          .delete()
          .or(
            'and(sender_id.eq.$_currentUserId,receiver_id.eq.$targetUserId),'
            'and(sender_id.eq.$targetUserId,receiver_id.eq.$_currentUserId)',
          );
    } catch (e, st) {
      AppLogger.e('FriendService: unfriend failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ─── Queries ──────────────────────────────────────────────────────────────

  /// Returns the friendship status between the current user and [targetUserId].
  Future<FriendshipStatus> getFriendshipStatus(String targetUserId) async {
    try {
      final rows = await _client
          .from('friend_requests')
          .select('id, sender_id, receiver_id, status')
          .or(
            'and(sender_id.eq.$_currentUserId,receiver_id.eq.$targetUserId),'
            'and(sender_id.eq.$targetUserId,receiver_id.eq.$_currentUserId)',
          );

      if (rows.isEmpty) return FriendshipStatus.none;

      final row = rows.first as Map<String, dynamic>;
      final status = row['status'] as String;

      if (status == 'accepted') return FriendshipStatus.friends;
      if (status == 'pending') {
        return row['sender_id'] == _currentUserId
            ? FriendshipStatus.pendingSent
            : FriendshipStatus.pendingReceived;
      }
      return FriendshipStatus.none;
    } catch (e, st) {
      AppLogger.e('FriendService: getFriendshipStatus failed', error: e, stackTrace: st);
      return FriendshipStatus.none;
    }
  }

  /// Returns all accepted friends of [userId].
  Future<List<FriendUser>> getFriends(String userId) async {
    AppLogger.i('FriendService: getFriends userId=$userId');
    try {
      final rows = await _client
          .from('friend_requests')
          .select('id, sender_id, receiver_id, sender:users!sender_id(id,username,total_points,avatar_url), receiver:users!receiver_id(id,username,total_points,avatar_url)')
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .eq('status', 'accepted');

      return (rows as List).map((row) {
        final isSender = row['sender_id'] == userId;
        final friendData = isSender
            ? row['receiver'] as Map<String, dynamic>
            : row['sender'] as Map<String, dynamic>;
        return FriendUser.fromJson(friendData, requestId: row['id'] as String);
      }).toList();
    } catch (e, st) {
      AppLogger.e('FriendService: getFriends failed', error: e, stackTrace: st);
      return [];
    }
  }

  /// Returns incoming pending requests (sent TO the current user).
  Future<List<FriendUser>> getPendingIncoming() async {
    try {
      final rows = await _client
          .from('friend_requests')
          .select('id, sender:users!sender_id(id,username,total_points,avatar_url)')
          .eq('receiver_id', _currentUserId)
          .eq('status', 'pending');

      return (rows as List).map((row) {
        final senderData = row['sender'] as Map<String, dynamic>;
        return FriendUser.fromJson(senderData, requestId: row['id'] as String);
      }).toList();
    } catch (e, st) {
      AppLogger.e('FriendService: getPendingIncoming failed', error: e, stackTrace: st);
      return [];
    }
  }

  /// Searches users by username prefix, excluding the current user.
  Future<List<FriendUser>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final results = await _client
          .from('users')
          .select('id, username, total_points, avatar_url')
          .ilike('username', '%${query.trim()}%')
          .neq('id', _currentUserId)
          .limit(15);

      return (results as List)
          .map((r) => FriendUser.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.e('FriendService: searchUsers failed', error: e, stackTrace: st);
      return [];
    }
  }

  /// Returns the IDs of all accepted friends (used for filtering).
  Future<List<String>> getFriendIds(String userId) async {
    final friends = await getFriends(userId);
    return friends.map((f) => f.id).toList();
  }
}
