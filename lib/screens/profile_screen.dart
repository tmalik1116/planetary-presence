import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadActivityData();
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

  Future<void> _loadActivityData() async {
    final user = AuthService.currentUser;
    if (user == null) return;
    final data = await ProfileService().getActivityData(user.id);
    if (mounted) {
      setState(() => _activityData = data);
    }
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
      body: Column(
        children: [
          _ProfileHeader(profile: _profile, loading: _loading),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: _ActivityGraph(activityData: _activityData),
          ),
          const Spacer(),
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

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Color _cellColor(int count, bool isDark) {
    if (count == 0) {
      return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE);
    } else if (count == 1) {
      return AppColors.primary.withValues(alpha: 0.3);
    } else if (count == 2) {
      return AppColors.primary.withValues(alpha: 0.6);
    } else {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build 49-day grid: 7 weeks (columns) × 7 days (rows, Mon=0..Sun=6)
    // Start from the Monday of the week 7 weeks ago
    final now = DateTime.now();
    // Find the most recent Sunday as end anchor
    // We want 49 cells total: columns = weeks (oldest left), rows = Mon..Sun
    // Calculate the start date: 48 days before today, adjusted to Monday
    final todayWeekday = now.weekday; // 1=Mon..7=Sun
    // Align so the last column ends with the current week (including today)
    final daysFromMonday = todayWeekday - 1;
    final weekStart = now.subtract(Duration(days: daysFromMonday));
    final gridStart = weekStart.subtract(const Duration(days: 42)); // 6 full weeks back

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels column
            Column(
              children: List.generate(7, (dayIndex) {
                return SizedBox(
                  height: 16,
                  child: Text(
                    _dayLabels[dayIndex],
                    style: const TextStyle(
                      fontSize: 8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: AppSpacing.xs),
            // 7 columns (weeks)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(7, (weekIndex) {
                  return Column(
                    children: List.generate(7, (dayIndex) {
                      final cellDate = gridStart.add(
                        Duration(days: weekIndex * 7 + dayIndex),
                      );
                      // Don't render future days
                      final isFuture = cellDate.isAfter(now);
                      final key =
                          '${cellDate.year}-${cellDate.month.toString().padLeft(2, '0')}-${cellDate.day.toString().padLeft(2, '0')}';
                      final count = isFuture ? 0 : (activityData[key] ?? 0);
                      return Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isFuture
                              ? Colors.transparent
                              : _cellColor(count, isDark),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
