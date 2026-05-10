import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../services/friend_service.dart';
import '../services/profile_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileData? _profile;
  bool _loading = true;
  Map<String, int> _activityData = {};
  PersonalRecords _records = const PersonalRecords(bestDayQuests: 0, bestDayPoints: 0);

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

  Future<void> _loadProfile() async {
    final user = AuthService.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    final profile = await ProfileService().getProfile(user.id);
    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
      });
    }
  }

  Future<void> _loadRecords() async {
    final user = AuthService.currentUser;
    if (user == null) return;
    final records = await ProfileService().getPersonalRecords(user.id);
    if (mounted) setState(() => _records = records);
  }

  Future<void> _loadActivityData() async {
    final user = AuthService.currentUser;
    if (user == null) return;
    final data = await ProfileService().getActivityData(user.id);
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
        title: const Text('Profile'),
        actions: [
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
            _ProfileHeader(profile: _profile, loading: _loading),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: _ActivityGraph(activityData: _activityData),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.base, 0, AppSpacing.base, AppSpacing.base),
              child: _PersonalRecords(records: _records, isDark: Theme.of(context).brightness == Brightness.dark),
            ),
            // Pending friend requests
            if (_pendingIncoming.isNotEmpty)
              _PendingRequestsCard(
                requests: _pendingIncoming,
                onAccept: _acceptRequest,
                onDecline: _declineRequest,
              ),
            // Friends & search
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
            ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Sign Out',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProfileData? profile;
  final bool loading;

  const _ProfileHeader({required this.profile, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryLight,
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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Avatar upload coming soon')),
                    );
                  },
                  child: CircleAvatar(
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
                const SizedBox(height: AppSpacing.xs),
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
    final startOfYear = DateTime(now.year, 1, 1);
    // Pad to start on Monday
    final startDay = startOfYear.subtract(
      Duration(days: (startOfYear.weekday - 1) % 7),
    );

    final List<List<DateTime?>> weeks = [];
    var current = startDay;
    while (!current.isAfter(now)) {
      final week = <DateTime?>[];
      for (int d = 0; d < 7; d++) {
        final day = current.add(Duration(days: d));
        week.add(day.isAfter(now) || day.isBefore(startOfYear) ? null : day);
      }
      weeks.add(week);
      current = current.add(const Duration(days: 7));
    }

    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const labelWidth = 28.0;
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double gap = 1.0;
              final cellSize = (constraints.maxWidth - labelWidth - (6 * gap)) / 7;

              return Column(
                children: List.generate(weeks.length, (weekIndex) {
                  final week = weeks[weekIndex];
                  final firstReal = week.firstWhere(
                    (d) => d != null,
                    orElse: () => null,
                  );
                  String? monthLabel;
                  if (firstReal != null) {
                    final hasFirstOfMonth = week.any((d) => d != null && d.day == 1);
                    if (weekIndex == 0 || hasFirstOfMonth) {
                      final labelDay = hasFirstOfMonth
                          ? week.firstWhere((d) => d != null && d.day == 1)!
                          : firstReal;
                      monthLabel = monthNames[labelDay.month - 1];
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: gap),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: labelWidth,
                          child: monthLabel != null
                              ? Text(
                                  monthLabel,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isDark
                                        ? AppColors.dmTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                )
                              : null,
                        ),
                        Row(
                          children: List.generate(7, (di) {
                            final day = week[di];
                            if (day == null) {
                              return SizedBox(
                                width: cellSize + (di < 6 ? gap : 0),
                                height: cellSize,
                              );
                            }
                            final key =
                                '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                            final count = activityData[key] ?? 0;
                            return Container(
                              width: cellSize,
                              height: cellSize,
                              margin: EdgeInsets.only(right: di < 6 ? gap : 0.0),
                              decoration: BoxDecoration(
                                color: _cellColor(count, isDark),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _cellColor(int count, bool isDark) {
    if (count == 0) return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE);
    if (count == 1) return AppColors.primary.withValues(alpha: 0.35);
    if (count == 2) return AppColors.primary.withValues(alpha: 0.6);
    return AppColors.primary;
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
            'Personal Records',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
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

