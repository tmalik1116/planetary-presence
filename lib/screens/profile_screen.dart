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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ProfileHeader(profile: _profile, loading: _loading),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: _ActivityGraph(activityData: _activityData),
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
