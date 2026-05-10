import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Convert Map<String, int> to Map<DateTime, int>
    final Map<DateTime, int> datasets = {};
    for (final entry in activityData.entries) {
      try {
        datasets[DateTime.parse(entry.key)] = entry.value;
      } catch (_) {}
    }

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
        HeatMap(
          datasets: datasets,
          colorMode: ColorMode.opacity,
          defaultColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
          textColor: isDark ? AppColors.dmTextSecondary : AppColors.textSecondary,
          showColorTip: false,
          showText: false,
          scrollable: true,
          size: 14,
          colorsets: {
            1: AppColors.primary.withValues(alpha: 0.3),
            2: AppColors.primary.withValues(alpha: 0.5),
            3: AppColors.primary.withValues(alpha: 0.7),
            5: AppColors.primary,
          },
        ),
      ],
    );
  }
}
