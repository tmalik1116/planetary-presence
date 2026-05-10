import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/stats_service.dart';

enum _LeaderboardScope { global, city, country }

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  _LeaderboardScope _scope = _LeaderboardScope.global;
  List<LeaderboardEntry> _leaderboard = [];
  bool _loading = true;
  String? _error;

  ProfileData? _profile;
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    }
    setState(() => _profileLoaded = true);
    await _loadLeaderboard();
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

  bool get _needsHomeCity =>
      _scope != _LeaderboardScope.global &&
      (_scope == _LeaderboardScope.city
          ? _profile?.homeCityId == null
          : _profile?.homeCityCountry == null);

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Points'),
            Tab(text: 'Quests'),
          ],
        ),
      ),
      body: Column(
        children: [
          _ScopeFilterRow(
            selected: _scope,
            onSelected: _setScope,
          ),
          Expanded(
            child: _profileLoaded && _needsHomeCity
                ? _NoCityMessage(
                    scope: _scope == _LeaderboardScope.city ? 'city' : 'country',
                  )
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
                              ),
                              _LeaderboardList(
                                entries: _leaderboard,
                                currentUserId: currentUserId,
                                valueLabel: 'pts',
                                getValue: (e) => e.totalPoints,
                                onRefresh: _loadLeaderboard,
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}

class _ScopeFilterRow extends StatelessWidget {
  final _LeaderboardScope selected;
  final ValueChanged<_LeaderboardScope> onSelected;

  const _ScopeFilterRow({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
        ],
      ),
    );
  }
}

class _ScopePill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ScopePill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          color: active ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _NoCityMessage extends StatelessWidget {
  final String scope;

  const _NoCityMessage({required this.scope});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_city_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Set a home city in your profile to see $scope leaderboards',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String? currentUserId;
  final String valueLabel;
  final int Function(LeaderboardEntry) getValue;
  final Future<void> Function() onRefresh;

  const _LeaderboardList({
    required this.entries,
    required this.currentUserId,
    required this.valueLabel,
    required this.getValue,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(child: Text('No data yet'));
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.base,
        ),
        itemCount: entries.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _LeaderboardRow(
            entry: entry,
            value: getValue(entry),
            valueLabel: valueLabel,
            isCurrentUser: entry.userId == currentUserId,
          );
        },
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final int value;
  final String valueLabel;
  final bool isCurrentUser;

  const _LeaderboardRow({
    required this.entry,
    required this.value,
    required this.valueLabel,
    required this.isCurrentUser,
  });

  Color get _rankColor {
    switch (entry.rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.primaryLight : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _rankColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              entry.username,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$value $valueLabel',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
