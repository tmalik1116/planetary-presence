import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../services/friend_service.dart';
import '../services/profile_service.dart';
import '../services/stats_service.dart';

enum _LeaderboardScope { global, city, country, friends }

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  _LeaderboardScope _scope = _LeaderboardScope.global;
  bool _lastMonth = false;

  String _chartPeriod = 'week';
  Map<String, Map<String, int>> _xpSeries = {};
  List<FriendUser> _friends = [];
  bool _chartLoading = false;

  List<LeaderboardEntry> _leaderboard = [];
  bool _loading = true;
  String? _error;

  ProfileData? _profile;
  bool _profileLoaded = false;
  List<String> _friendIds = [];
  int _friendCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 2 && _xpSeries.isEmpty) {
        _loadChart();
      }
    });
    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final userId = AuthService.currentUser?.id;
    if (userId != null) {
      _profile = await ProfileService().getProfile(userId);
      final friendIds = await FriendService().getFriendIds(userId);
      _friendCount = friendIds.length;
      // Include self so the current user appears in their own friends leaderboard
      _friendIds = [userId, ...friendIds];
    }
    setState(() => _profileLoaded = true);
    await _loadLeaderboard();
    await _loadChart();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final entries = await StatsService.getLeaderboard(
        scope: _scope.name,
        cityId: _profile?.homeCityId,
        country: _profile?.homeCityCountry,
        friendIds: _friendIds,
        lastMonth: _lastMonth,
      );
      setState(() {
        _leaderboard = entries;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _setScope(_LeaderboardScope scope) {
    if (_scope == scope) return;
    setState(() => _scope = scope);
    _loadLeaderboard();
  }

  void _toggleLastMonth(bool val) {
    setState(() => _lastMonth = val);
    _loadLeaderboard();
  }

  Future<void> _loadChart() async {
    final userId = AuthService.currentUser?.id;
    if (userId == null) return;
    setState(() => _chartLoading = true);
    try {
      final friends = await FriendService().getFriends(userId);
      final ids = [userId, ...friends.map((f) => f.id)];
      final series = await StatsService.getXpTimeSeries(
        userIds: ids,
        period: _chartPeriod,
      );
      if (mounted) {
        setState(() {
          _friends = friends;
          _xpSeries = series;
          _chartLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _chartLoading = false);
    }
  }

  bool get _needsHomeCity =>
      _scope != _LeaderboardScope.global &&
      _scope != _LeaderboardScope.friends &&
      (_scope == _LeaderboardScope.city
          ? _profile?.homeCityId == null
          : _profile?.homeCityCountry == null);

  bool get _noFriends =>
      _scope == _LeaderboardScope.friends && _friendCount == 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = AuthService.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: isDark ? AppColors.dmPrimary : AppColors.primary,
          unselectedLabelColor:
              isDark ? AppColors.dmTextSecondary : AppColors.textSecondary,
          indicatorColor: isDark ? AppColors.dmPrimary : AppColors.primary,
          tabs: const [
            Tab(text: 'Points'),
            Tab(text: 'Quests'),
            Tab(text: 'Chart'),
          ],
        ),
      ),
      body: Column(
        children: [
          _HeroCard(
            profile: _profile,
            leaderboard: _leaderboard,
            currentUserId: currentUserId,
            loading: _loading,
            isDark: isDark,
          ),
          _ScopeFilterRow(
            selected: _scope,
            onSelected: _setScope,
          ),
          // Last Month / All Time toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base, AppSpacing.xs, AppSpacing.base, 0),
            child: Row(
              children: [
                _ToggleChip(
                  label: 'All Time',
                  active: !_lastMonth,
                  onTap: () => _toggleLastMonth(false),
                ),
                const SizedBox(width: AppSpacing.sm),
                _ToggleChip(
                  label: 'Last 30 Days',
                  active: _lastMonth,
                  onTap: () => _toggleLastMonth(true),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: _profileLoaded && _needsHomeCity
                ? _NoCityMessage(
                    scope: _scope == _LeaderboardScope.city ? 'city' : 'country',
                  )
                : _noFriends
                    ? const _NoFriendsMessage()
                    : _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  _LeaderboardList(
                                    entries: _leaderboard,
                                    currentUserId: currentUserId,
                                    valueLabel: 'pts',
                                    getValue: (e) => e.totalPoints,
                                    onRefresh: _loadLeaderboard,
                                    isDark: isDark,
                                  ),
                                  _LeaderboardList(
                                    entries: List.from(_leaderboard)
                                      ..sort((a, b) =>
                                          b.questCount.compareTo(a.questCount)),
                                    currentUserId: currentUserId,
                                    valueLabel: 'quests',
                                    getValue: (e) => e.questCount,
                                    onRefresh: _loadLeaderboard,
                                    isDark: isDark,
                                    rerank: true,
                                  ),
                                  _XpChartTab(
                                    userId: AuthService.currentUser?.id ?? '',
                                    friends: _friends,
                                    xpSeries: _xpSeries,
                                    period: _chartPeriod,
                                    loading: _chartLoading,
                                    isDark: isDark,
                                    onPeriodChanged: (p) {
                                      setState(() => _chartPeriod = p);
                                      _loadChart();
                                    },
                                  ),
                                ],
                              ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final ProfileData? profile;
  final List<LeaderboardEntry> leaderboard;
  final String? currentUserId;
  final bool loading;
  final bool isDark;

  const _HeroCard({
    required this.profile,
    required this.leaderboard,
    required this.currentUserId,
    required this.loading,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    LeaderboardEntry? myEntry;
    if (currentUserId != null) {
      try {
        myEntry = leaderboard.firstWhere((e) => e.userId == currentUserId);
      } catch (_) {
        myEntry = null;
      }
    }

    final rankText = myEntry != null ? '#${myEntry.rank}' : '—';
    final pointsText = myEntry != null ? '${myEntry.totalPoints} pts' : '—';

    final gradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF1A3A10), Color(0xFF0D1F08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [AppColors.primary, Color(0xFF165200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Container(
      margin: const EdgeInsets.all(AppSpacing.base),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: loading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Ranking',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rankText,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Opacity(
                  opacity: 0.3,
                  child: Icon(Icons.emoji_events, color: Colors.white, size: 40),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Points',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pointsText,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Scope Filter Row ─────────────────────────────────────────────────────────

class _ScopeFilterRow extends StatelessWidget {
  final _LeaderboardScope selected;
  final ValueChanged<_LeaderboardScope> onSelected;

  const _ScopeFilterRow({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dmCard : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dmBorder : AppColors.divider,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ScopePill(
              label: 'Global',
              active: selected == _LeaderboardScope.global,
              onTap: () => onSelected(_LeaderboardScope.global),
            ),
            const SizedBox(width: AppSpacing.sm),
            _ScopePill(
              label: 'City',
              active: selected == _LeaderboardScope.city,
              onTap: () => onSelected(_LeaderboardScope.city),
            ),
            const SizedBox(width: AppSpacing.sm),
            _ScopePill(
              label: 'Country',
              active: selected == _LeaderboardScope.country,
              onTap: () => onSelected(_LeaderboardScope.country),
            ),
            const SizedBox(width: AppSpacing.sm),
            _ScopePill(
              label: 'Friends',
              active: selected == _LeaderboardScope.friends,
              onTap: () => onSelected(_LeaderboardScope.friends),
              icon: Icons.people_outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScopePill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;

  const _ScopePill({
    required this.label,
    required this.active,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.dmPrimary : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: active
              ? activeColor
              : (isDark ? AppColors.dmCard : Colors.white),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: active
                ? activeColor
                : (isDark ? AppColors.dmBorder : AppColors.cardBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: active
                    ? Colors.white
                    : (isDark
                        ? AppColors.dmTextSecondary
                        : AppColors.textSecondary),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active
                    ? Colors.white
                    : (isDark
                        ? AppColors.dmTextSecondary
                        : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.dmPrimary : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: active
                ? activeColor
                : (isDark ? AppColors.dmBorder : AppColors.cardBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active
                ? activeColor
                : (isDark ? AppColors.dmTextSecondary : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

// ─── Empty States ─────────────────────────────────────────────────────────────

class _NoCityMessage extends StatelessWidget {
  final String scope;
  const _NoCityMessage({required this.scope});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_city_outlined,
              size: 48,
              color: isDark ? AppColors.dmTextSecondary : AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Set a home city in your profile to see $scope leaderboards',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.dmTextSecondary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NoFriendsMessage extends StatelessWidget {
  const _NoFriendsMessage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: 48,
              color: isDark ? AppColors.dmTextSecondary : AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No friends yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.dmTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Find people to add from your Profile page',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.dmTextSecondary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Leaderboard List ─────────────────────────────────────────────────────────

class _LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String? currentUserId;
  final String valueLabel;
  final int Function(LeaderboardEntry) getValue;
  final Future<void> Function() onRefresh;
  final bool isDark;
  final bool rerank;

  const _LeaderboardList({
    required this.entries,
    required this.currentUserId,
    required this.valueLabel,
    required this.getValue,
    required this.onRefresh,
    required this.isDark,
    this.rerank = false,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined,
                size: 48,
                color:
                    isDark ? AppColors.dmTextSecondary : AppColors.textTertiary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No rankings yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.dmTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Complete quests to appear on the leaderboard',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.dmTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.base,
        ),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _LeaderboardRow(
            entry: entry,
            value: getValue(entry),
            valueLabel: valueLabel,
            isCurrentUser: entry.userId == currentUserId,
            // If reranked (Quests tab), use index+1 as the visual rank
            displayRank: rerank ? index + 1 : entry.rank,
          );
        },
      ),
    );
  }
}

// ─── Leaderboard Row ──────────────────────────────────────────────────────────

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final int value;
  final String valueLabel;
  final bool isCurrentUser;
  final int displayRank;

  const _LeaderboardRow({
    required this.entry,
    required this.value,
    required this.valueLabel,
    required this.isCurrentUser,
    required this.displayRank,
  });

  Color _rankColor(bool isDark) {
    switch (displayRank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;
    }
  }

  Widget _buildRankWidget(bool isDark) {
    switch (displayRank) {
      case 1:
        return const Text('🥇', style: TextStyle(fontSize: 24), textAlign: TextAlign.center);
      case 2:
        return const Text('🥈', style: TextStyle(fontSize: 24), textAlign: TextAlign.center);
      case 3:
        return const Text('🥉', style: TextStyle(fontSize: 24), textAlign: TextAlign.center);
      default:
        return Text(
          '$displayRank',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _rankColor(isDark),
          ),
          textAlign: TextAlign.center,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTop3 = displayRank <= 3;
    final initials = entry.username.isNotEmpty
        ? entry.username[0].toUpperCase()
        : '?';
    final verticalPadding = isTop3 ? AppSpacing.base + 4 : AppSpacing.md;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? (isDark
                ? AppColors.dmPrimary.withValues(alpha: 0.18)
                : AppColors.primaryLight)
            : (isDark ? AppColors.dmCard : Colors.white),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isCurrentUser
              ? (isDark ? AppColors.dmPrimary : AppColors.primary)
                  .withValues(alpha: 0.4)
              : (isDark ? AppColors.dmBorder : AppColors.cardBorder),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 32, child: _buildRankWidget(isDark)),
          const SizedBox(width: AppSpacing.md),
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.dmPrimary : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    entry.username,
                    style: TextStyle(
                      fontSize: isTop3 ? 16.0 : 15.0,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.dmTextPrimary
                          : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCurrentUser) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '(You)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppColors.dmTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '$value $valueLabel',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.dmPrimary : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── XP Chart Tab ─────────────────────────────────────────────────────────────

class _XpChartTab extends StatelessWidget {
  final String userId;
  final List<FriendUser> friends;
  final Map<String, Map<String, int>> xpSeries;
  final String period;
  final bool loading;
  final bool isDark;
  final ValueChanged<String> onPeriodChanged;

  const _XpChartTab({
    required this.userId,
    required this.friends,
    required this.xpSeries,
    required this.period,
    required this.loading,
    required this.isDark,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: ['day', 'week', 'month'].map((p) {
              final active = period == p;
              final label = p == 'day' ? '24h' : p == 'week' ? '7d' : '30d';
              final green = isDark ? AppColors.dmPrimary : AppColors.primary;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => onPeriodChanged(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: active ? green.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: active ? green : (isDark ? AppColors.dmBorder : AppColors.cardBorder),
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? green : labelColor,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.base),
          if (loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (xpSeries.isEmpty || xpSeries.values.every((m) => m.isEmpty))
            Expanded(
              child: Center(
                child: Text(
                  'No activity in this period.',
                  style: TextStyle(color: labelColor, fontSize: 14),
                ),
              ),
            )
          else
            Expanded(
              child: _XpChart(
                userId: userId,
                friends: friends,
                xpSeries: xpSeries,
                period: period,
                isDark: isDark,
              ),
            ),
        ],
      ),
    );
  }
}

class _XpChart extends StatelessWidget {
  final String userId;
  final List<FriendUser> friends;
  final Map<String, Map<String, int>> xpSeries;
  final String period;
  final bool isDark;

  const _XpChart({
    required this.userId,
    required this.friends,
    required this.xpSeries,
    required this.period,
    required this.isDark,
  });

  List<String> _buildBuckets() {
    final now = DateTime.now();
    final buckets = <String>[];
    if (period == 'day') {
      for (int h = 23; h >= 0; h--) {
        final t = now.subtract(Duration(hours: h));
        buckets.add('${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} ${t.hour.toString().padLeft(2, '0')}');
      }
    } else {
      final days = period == 'week' ? 6 : 29;
      for (int d = days; d >= 0; d--) {
        final t = now.subtract(Duration(days: d));
        buckets.add('${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}');
      }
    }
    return buckets;
  }

  @override
  Widget build(BuildContext context) {
    final buckets = _buildBuckets();
    final green = isDark ? AppColors.dmPrimary : AppColors.primary;
    final gridColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final labelColor = isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;

    final friendColors = [
      Colors.orange, Colors.purple, Colors.cyan, Colors.pink,
      Colors.amber, Colors.teal,
    ];

    LineChartBarData buildLine(String uid, Color color, {bool isMe = false}) {
      final data = xpSeries[uid] ?? {};
      final spots = buckets.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), (data[e.value] ?? 0).toDouble());
      }).toList();
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: isMe ? 2.5 : 1.5,
        dotData: const FlDotData(show: false),
        belowBarData: isMe
            ? BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.08),
              )
            : BarAreaData(show: false),
      );
    }

    final lines = <LineChartBarData>[
      buildLine(userId, green, isMe: true),
      ...friends.asMap().entries.map((e) =>
          buildLine(e.value.id, friendColors[e.key % friendColors.length])),
    ];

    final legendItems = <Widget>[
      _LegendDot(color: green, label: 'You'),
      ...friends.asMap().entries.map((e) => _LegendDot(
            color: friendColors[e.key % friendColors.length],
            label: e.value.username,
          )),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: gridColor,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (val, meta) => Text(
                      val.toInt().toString(),
                      style: TextStyle(fontSize: 9, color: labelColor),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: period == 'day' ? 4 : period == 'week' ? 1 : 5,
                    getTitlesWidget: (val, meta) {
                      final idx = val.toInt();
                      if (idx < 0 || idx >= buckets.length) return const SizedBox.shrink();
                      final key = buckets[idx];
                      final label = period == 'day'
                          ? '${key.split(' ')[1]}h'
                          : key.substring(8);
                      return Text(label, style: TextStyle(fontSize: 9, color: labelColor));
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: lines,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: legendItems,
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.dmTextSecondary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
