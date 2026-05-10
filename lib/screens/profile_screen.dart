import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../services/friend_service.dart';
import '../services/profile_service.dart';
import '../services/media_upload_service.dart';
import '../services/quest_service.dart';
import 'quest_detail_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileData? _profile;
  bool _loading = true;
  Map<String, int> _activityData = {};
  PersonalRecords _records = const PersonalRecords(
    bestDayQuests: 0, bestDayPoints: 0, totalQuests: 0, totalCities: 0, highestPointQuest: 0
  );

  List<Map<String, dynamic>> _questsTogether = [];
  FriendshipStatus _friendshipStatus = FriendshipStatus.none;

  // Friends state
  List<FriendUser> _friends = [];
  List<FriendUser> _pendingIncoming = [];
  final _friendService = FriendService();
  final _searchController = TextEditingController();
  List<FriendUser> _searchResults = [];
  bool _searching = false;
  final Map<String, FriendshipStatus> _statusCache = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadActivityData();
    _loadRecords();
    _loadFriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _targetUserId => widget.userId ?? AuthService.currentUser?.id ?? '';
  bool get _isCurrentUser => widget.userId == null || widget.userId == AuthService.currentUser?.id;

  Future<void> _loadProfile() async {
    final uid = _targetUserId;
    if (uid.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final profile = await ProfileService().getProfile(uid);
    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
      });
    }

    if (!_isCurrentUser) {
      final currentUid = AuthService.currentUser?.id;
      if (currentUid != null) {
        final status = await _friendService.getFriendshipStatus(uid);
        final together = await ProfileService().getQuestsTogether(currentUid, uid);
        if (mounted) {
          setState(() {
            _friendshipStatus = status;
            _questsTogether = together;
          });
        }
      }
    }
  }

  Future<void> _uploadAvatar() async {
    if (!_isCurrentUser) return;
    try {
      final res = await MediaUploadService().pickAndUploadAvatar(userId: _targetUserId);
      await ProfileService().updateAvatarUrl(_targetUserId, res.publicUrl);
      if (mounted) {
        setState(() {
          if (_profile != null) {
            _profile = ProfileData(
              username: _profile!.username,
              email: _profile!.email,
              totalPoints: _profile!.totalPoints,
              joinedAt: _profile!.joinedAt,
              homeCityName: _profile!.homeCityName,
              homeCityId: _profile!.homeCityId,
              homeCityCountry: _profile!.homeCityCountry,
              avatarUrl: res.publicUrl,
            );
          }
        });
      }
    } on MediaPickCancelledException {
      // do nothing
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
  }

  Future<void> _loadRecords() async {
    final uid = _targetUserId;
    if (uid.isEmpty) return;
    final records = await ProfileService().getPersonalRecords(uid);
    if (mounted) setState(() => _records = records);
  }

  Future<void> _loadActivityData() async {
    final uid = _targetUserId;
    if (uid.isEmpty) return;
    final data = await ProfileService().getActivityData(uid);
    if (mounted) {
      setState(() => _activityData = data);
    }
  }

  Future<void> _loadFriends() async {
    final uid = AuthService.currentUser?.id;
    if (uid == null) return;
    final friends = await _friendService.getFriends(uid);
    final incoming = await _friendService.getPendingIncoming();
    if (mounted) {
      setState(() {
        _friends = friends;
        _pendingIncoming = incoming;
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    final results = await _friendService.searchUsers(query);
    // Fetch status for each result
    for (final user in results) {
      _statusCache[user.id] = await _friendService.getFriendshipStatus(user.id);
    }
    if (mounted) setState(() {
      _searchResults = results;
      _searching = false;
    });
  }

  Future<void> _sendRequest(FriendUser user) async {
    await _friendService.sendRequest(user.id);
    setState(() => _statusCache[user.id] = FriendshipStatus.pendingSent);
  }

  Future<void> _cancelRequest(FriendUser user) async {
    await _friendService.cancelRequest(user.id);
    setState(() => _statusCache[user.id] = FriendshipStatus.none);
  }

  Future<void> _acceptRequest(FriendUser user) async {
    if (user.requestId == null) return;
    await _friendService.acceptRequest(user.requestId!);
    await _loadFriends();
  }

  Future<void> _declineRequest(FriendUser user) async {
    if (user.requestId == null) return;
    await _friendService.declineRequest(user.requestId!);
    await _loadFriends();
  }

  Future<void> _unfriend(FriendUser user) async {
    await _friendService.unfriend(user.id);
    await _loadFriends();
    setState(() => _statusCache[user.id] = FriendshipStatus.none);
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCurrentUser ? 'Profile' : (_profile?.username ?? 'Profile')),
        actions: [
          if (_isCurrentUser)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ProfileHeader(
              profile: _profile, 
              loading: _loading,
              isCurrentUser: _isCurrentUser,
              onAvatarTap: _uploadAvatar,
              friendshipStatus: _friendshipStatus,
              onAddFriend: () => _friendService.sendRequest(_targetUserId).then((_) => _loadProfile()),
              onUnfriend: () => _friendService.unfriend(_targetUserId).then((_) => _loadProfile()),
              onCancelRequest: () => _friendService.cancelRequest(_targetUserId).then((_) => _loadProfile()),
              topCategory: _records.topCategory,
            ),
            if (!_isCurrentUser && _questsTogether.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: _QuestsTogetherSection(quests: _questsTogether),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: _ActivityGraph(activityData: _activityData),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.base, 0, AppSpacing.base, AppSpacing.base),
              child: _PersonalRecords(records: _records, isDark: Theme.of(context).brightness == Brightness.dark),
            ),
            if (_isCurrentUser) ...[
              if (_pendingIncoming.isNotEmpty)
                _PendingRequestsCard(
                  requests: _pendingIncoming,
                  onAccept: _acceptRequest,
                  onDecline: _declineRequest,
                ),
              _FriendsCard(
                friends: _friends,
                searchController: _searchController,
                searchResults: _searchResults,
                searching: _searching,
                statusCache: _statusCache,
                onSearch: _searchUsers,
                onSendRequest: _sendRequest,
                onCancelRequest: _cancelRequest,
                onUnfriend: _unfriend,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.base),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProfileData? profile;
  final bool loading;
  final bool isCurrentUser;
  final VoidCallback onAvatarTap;
  final FriendshipStatus friendshipStatus;
  final VoidCallback onAddFriend;
  final VoidCallback onUnfriend;
  final VoidCallback onCancelRequest;
  final String? topCategory;

  const _ProfileHeader({
    required this.profile,
    required this.loading,
    required this.isCurrentUser,
    required this.onAvatarTap,
    required this.friendshipStatus,
    required this.onAddFriend,
    required this.onUnfriend,
    required this.onCancelRequest,
    this.topCategory,
  });

  String _getSubtitle(String category) {
    switch (category) {
      case 'nature': return 'Expert Naturalist';
      case 'culture': return 'Person of Culture';
      case 'food': return 'Certified Foodie';
      case 'landmark': return 'Resident Architect';
      default: return 'Explorer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = topCategory != null 
        ? AppColors.categoryColor(topCategory!, darkMode: isDark).withValues(alpha: isDark ? 0.15 : 0.2)
        : (isDark ? AppColors.dmPrimary.withValues(alpha: 0.1) : AppColors.primaryLight);

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.lg,
      ),
      child: loading
          ? const Center(
              heightFactor: 3,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            )
          : Column(
              children: [
                GestureDetector(
                  onTap: isCurrentUser ? onAvatarTap : null,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary,
                        backgroundImage: (profile?.avatarUrl != null &&
                                profile!.avatarUrl!.isNotEmpty)
                            ? NetworkImage(profile!.avatarUrl!)
                            : null,
                        child: (profile?.avatarUrl == null ||
                                profile!.avatarUrl!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white, size: 32)
                            : null,
                      ),
                      if (isCurrentUser)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  profile?.username.isNotEmpty == true
                      ? profile!.username
                      : 'Explorer',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (topCategory != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getSubtitle(topCategory!),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.categoryColor(topCategory!, darkMode: isDark),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                if (!isCurrentUser) ...[
                  _buildFriendshipButton(),
                  const SizedBox(height: AppSpacing.md),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      profile?.homeCityName ?? 'No home city set',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatChip(
                      label: profile != null
                          ? '${profile!.totalPoints} pts'
                          : '0 pts',
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _StatChip(
                      label: profile != null
                          ? 'Joined ${_formatMonth(profile!.joinedAt)}'
                          : 'Joined —',
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  static String _formatMonth(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildFriendshipButton() {
    switch (friendshipStatus) {
      case FriendshipStatus.friends:
        return ElevatedButton.icon(
          onPressed: onUnfriend,
          icon: const Icon(Icons.check),
          label: const Text('Friends'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        );
      case FriendshipStatus.pendingSent:
        return OutlinedButton.icon(
          onPressed: onCancelRequest,
          icon: const Icon(Icons.access_time),
          label: const Text('Request Sent'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
          ),
        );
      case FriendshipStatus.pendingReceived:
        return const Text('Pending request from them', style: TextStyle(fontStyle: FontStyle.italic));
      case FriendshipStatus.none:
        return ElevatedButton.icon(
          onPressed: onAddFriend,
          icon: const Icon(Icons.person_add),
          label: const Text('Add Friend'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        );
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;

  const _StatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ActivityGraph extends StatelessWidget {
  final Map<String, int> activityData;

  const _ActivityGraph({required this.activityData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    const weeksToShow = 20; // 20 weeks looks good on a mobile screen
    
    // Find the Sunday of the week 'weeksToShow' weeks ago
    final daysSinceSunday = now.weekday % 7; 
    final startDay = now.subtract(Duration(days: daysSinceSunday + (weeksToShow - 1) * 7));

    final List<List<DateTime?>> weeks = [];
    var current = startDay;
    for (int w = 0; w < weeksToShow; w++) {
      final week = <DateTime?>[];
      for (int d = 0; d < 7; d++) {
        if (current.isAfter(now)) {
          week.add(null);
        } else {
          week.add(current);
        }
        current = current.add(const Duration(days: 1));
      }
      weeks.add(week);
    }

    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const cellSize = 12.0;
    const gap = 3.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: Text(
            'Activity',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.dmTextSecondary : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true, // scroll to the most recent end
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Months row
              Row(
                children: List.generate(weeks.length, (weekIndex) {
                  final week = weeks[weekIndex];
                  final firstReal = week.firstWhere((d) => d != null, orElse: () => null);
                  bool isFirstWeekOfMonth = false;
                  if (firstReal != null) {
                    if (weekIndex == 0) {
                      isFirstWeekOfMonth = true;
                    } else {
                      final prevWeek = weeks[weekIndex - 1];
                      final prevReal = prevWeek.lastWhere((d) => d != null, orElse: () => null);
                      if (prevReal != null && firstReal.month != prevReal.month) {
                        isFirstWeekOfMonth = true;
                      }
                    }
                  }
                  
                  return SizedBox(
                    width: cellSize + gap,
                    child: isFirstWeekOfMonth && firstReal != null
                        ? Text(
                            monthNames[firstReal.month - 1],
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.dmTextSecondary : AppColors.textSecondary,
                            ),
                            softWrap: false,
                            overflow: TextOverflow.visible,
                          )
                        : null,
                  );
                }),
              ),
              const SizedBox(height: 4),
              // Grid of days
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(weeks.length, (weekIndex) {
                  final week = weeks[weekIndex];
                  return Padding(
                    padding: const EdgeInsets.only(right: gap),
                    child: Column(
                      children: List.generate(7, (di) {
                        final day = week[di];
                        if (day == null) {
                          return SizedBox(width: cellSize, height: cellSize + gap);
                        }
                        final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                        final count = activityData[key] ?? 0;
                        return Container(
                          width: cellSize,
                          height: cellSize,
                          margin: const EdgeInsets.only(bottom: gap),
                          decoration: BoxDecoration(
                            color: _cellColor(count, isDark),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _cellColor(int count, bool isDark) {
    if (count == 0) return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEBEDF0);
    if (count == 1) return const Color(0xFF9BE9A8);
    if (count == 2) return const Color(0xFF40C463);
    if (count == 3) return const Color(0xFF30A14E);
    return const Color(0xFF216E39);
  }
}

class _PersonalRecords extends StatelessWidget {
  final PersonalRecords records;
  final bool isDark;

  const _PersonalRecords({required this.records, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.dmCard : AppColors.background;
    final borderColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final labelColor = isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stats & Records',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _StatBadge(
                icon: Icons.check_circle_outline,
                label: 'Total Quests',
                value: '${records.totalQuests}',
                isDark: isDark,
              ),
              _StatBadge(
                icon: Icons.location_city_outlined,
                label: 'Cities Visited',
                value: '${records.totalCities}',
                isDark: isDark,
              ),
              _StatBadge(
                icon: Icons.military_tech_outlined,
                label: 'High Score',
                value: '${records.highestPointQuest} pts',
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _RecordTile(
                  icon: Icons.emoji_events_outlined,
                  label: 'Best Day (Quests)',
                  value: records.bestDayQuests == 0 ? '—' : '${records.bestDayQuests}',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _RecordTile(
                  icon: Icons.stars_outlined,
                  label: 'Best Day (Points)',
                  value: records.bestDayPoints == 0 ? '—' : '${records.bestDayPoints} pts',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.dmSecondaryBackground : AppColors.secondaryBackground;
    final valueColor = isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;
    final green = isDark ? AppColors.dmPrimary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: green),
          const SizedBox(width: 6),
          Text(
            '$value ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.dmTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _RecordTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.dmSecondaryBackground : AppColors.secondaryBackground;
    final labelColor = isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;
    final valueColor = isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;
    final green = isDark ? AppColors.dmPrimary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: green),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: labelColor),
          ),
        ],
      ),
    );
  }
}

// ─── Pending Requests Card ────────────────────────────────────────────────────

class _PendingRequestsCard extends StatelessWidget {
  final List<FriendUser> requests;
  final Future<void> Function(FriendUser) onAccept;
  final Future<void> Function(FriendUser) onDecline;

  const _PendingRequestsCard({
    required this.requests,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.dmCard : AppColors.background;
    final borderColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final green = isDark ? AppColors.dmPrimary : AppColors.primary;
    final labelColor = isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;
    final titleColor = isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.base, 0, AppSpacing.base, AppSpacing.base),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: green.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_add_outlined, size: 16, color: green),
              const SizedBox(width: 6),
              Text(
                'Friend Requests (${requests.length})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...requests.map((req) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: green.withValues(alpha: 0.15),
                  child: Text(
                    req.username.isNotEmpty ? req.username[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: green),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(req.username,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: titleColor)),
                ),
                TextButton(
                  onPressed: () => onDecline(req),
                  style: TextButton.styleFrom(
                    foregroundColor: labelColor,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Decline'),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: () => onAccept(req),
                  style: FilledButton.styleFrom(
                    backgroundColor: green,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Accept'),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Friends Card ─────────────────────────────────────────────────────────────

class _FriendsCard extends StatelessWidget {
  final List<FriendUser> friends;
  final TextEditingController searchController;
  final List<FriendUser> searchResults;
  final bool searching;
  final Map<String, FriendshipStatus> statusCache;
  final Future<void> Function(String) onSearch;
  final Future<void> Function(FriendUser) onSendRequest;
  final Future<void> Function(FriendUser) onCancelRequest;
  final Future<void> Function(FriendUser) onUnfriend;

  const _FriendsCard({
    required this.friends,
    required this.searchController,
    required this.searchResults,
    required this.searching,
    required this.statusCache,
    required this.onSearch,
    required this.onSendRequest,
    required this.onCancelRequest,
    required this.onUnfriend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.dmCard : AppColors.background;
    final borderColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final green = isDark ? AppColors.dmPrimary : AppColors.primary;
    final labelColor = isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;
    final titleColor = isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;
    final inputBg = isDark ? AppColors.dmSecondaryBackground : AppColors.secondaryBackground;

    final showSearch = searchController.text.isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.base, 0, AppSpacing.base, AppSpacing.base),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friends${friends.isNotEmpty ? " (${friends.length})" : ""}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: labelColor),
          ),
          const SizedBox(height: AppSpacing.md),
          // Search field
          TextField(
            controller: searchController,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Search people by username…',
              hintStyle: TextStyle(fontSize: 13, color: labelColor),
              filled: true,
              fillColor: inputBg,
              prefixIcon: Icon(Icons.search, size: 18, color: labelColor),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, size: 18, color: labelColor),
                      onPressed: () {
                        searchController.clear();
                        onSearch('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                borderSide: BorderSide(color: green),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (showSearch) ...[
            if (searching)
              const Center(child: Padding(
                padding: EdgeInsets.all(AppSpacing.base),
                child: CircularProgressIndicator(strokeWidth: 2),
              ))
            else if (searchResults.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Text('No users found', style: TextStyle(color: labelColor, fontSize: 13)),
              ))
            else
              ...searchResults.map((user) {
                final status = statusCache[user.id] ?? FriendshipStatus.none;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProfileScreen(userId: user.id)),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: green.withValues(alpha: 0.15),
                            child: Text(
                              user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: green),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.username,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: titleColor)),
                                Text('${user.totalPoints} pts',
                                  style: TextStyle(fontSize: 11, color: labelColor)),
                              ],
                            ),
                          ),
                          _FriendActionButton(
                            status: status,
                            onSend: () => onSendRequest(user),
                            onCancel: () => onCancelRequest(user),
                            onUnfriend: () => onUnfriend(user),
                            green: green,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ] else ...[
            // Friends list
            if (friends.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Text('No friends yet. Search above to find people!',
                  style: TextStyle(color: labelColor, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ))
            else
              ...friends.map((friend) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen(userId: friend.id)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: green.withValues(alpha: 0.15),
                          child: Text(
                            friend.username.isNotEmpty ? friend.username[0].toUpperCase() : '?',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: green),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(friend.username,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: titleColor)),
                              Text('${friend.totalPoints} pts',
                                style: TextStyle(fontSize: 11, color: labelColor)),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => onUnfriend(friend),
                          style: TextButton.styleFrom(
                            foregroundColor: labelColor,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Unfriend'),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
          ],
        ],
      ),
    );
  }
}

class _FriendActionButton extends StatelessWidget {
  final FriendshipStatus status;
  final VoidCallback onSend;
  final VoidCallback onCancel;
  final VoidCallback onUnfriend;
  final Color green;
  final bool isDark;

  const _FriendActionButton({
    required this.status,
    required this.onSend,
    required this.onCancel,
    required this.onUnfriend,
    required this.green,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case FriendshipStatus.friends:
        return TextButton(
          onPressed: onUnfriend,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.categoryFood,
            visualDensity: VisualDensity.compact,
          ),
          child: const Text('Unfriend'),
        );
      case FriendshipStatus.pendingSent:
        return TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: isDark ? AppColors.dmTextSecondary : AppColors.textSecondary,
            visualDensity: VisualDensity.compact,
          ),
          child: const Text('Pending…'),
        );
      case FriendshipStatus.pendingReceived:
        return FilledButton(
          onPressed: onSend, // will trigger the respond flow from the parent
          style: FilledButton.styleFrom(
            backgroundColor: green,
            visualDensity: VisualDensity.compact,
          ),
          child: const Text('Respond'),
        );
      case FriendshipStatus.none:
      default:
        return FilledButton(
          onPressed: onSend,
          style: FilledButton.styleFrom(
            backgroundColor: green,
            visualDensity: VisualDensity.compact,
          ),
          child: const Text('Add'),
        );
    }
  }
}

class _QuestsTogetherSection extends StatelessWidget {
  final List<Map<String, dynamic>> quests;

  const _QuestsTogetherSection({required this.quests});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.dmCard : AppColors.background;
    final borderColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.handshake, size: 20, color: isDark ? AppColors.dmPrimary : AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Quests Done Together',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...quests.map((q) {
            final dt = DateTime.parse(q['completed_at'] as String).toLocal();
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                  image: q['media_url'] != null
                      ? DecorationImage(
                          image: NetworkImage(q['media_url'] as String),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: q['media_url'] == null
                    ? const Icon(Icons.image, color: Colors.white)
                    : null,
              ),
              title: Text(q['quest_title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${dt.month}/${dt.day}/${dt.year} • ${q['points_awarded']} pts'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final questData = await QuestService().getQuestById(q['quest_id'] as String);
                if (questData != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuestDetailScreen(quest: questData)),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to load quest details.')),
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }
}

