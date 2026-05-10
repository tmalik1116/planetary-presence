import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/quest.dart';
import '../services/auth_service.dart';
import '../services/city_service.dart';
import '../services/quest_service.dart';

class QuestDetailScreen extends StatefulWidget {
  final Quest quest;

  const QuestDetailScreen({super.key, required this.quest});

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends State<QuestDetailScreen> {
  CityData? _city;
  bool _loadingCity = true;
  late Quest _quest;

  @override
  void initState() {
    super.initState();
    _quest = widget.quest;
    _loadCity();
  }

  Future<void> _loadCity() async {
    try {
      final cities = await CityService().getCities();
      final match = cities.where((c) => c.id == widget.quest.cityId).firstOrNull;
      if (mounted) {
        setState(() {
          _city = match;
          _loadingCity = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingCity = false);
      }
    }
  }

  String get _categoryLabel {
    switch (_quest.category) {
      case QuestCategory.nature:
        return 'Nature';
      case QuestCategory.culture:
        return 'Culture';
      case QuestCategory.food:
        return 'Food';
      case QuestCategory.landmark:
        return 'Landmark';
    }
  }

  String get _cityLabel {
    if (_loadingCity) return 'Loading...';
    if (_city == null) return 'Unknown city';
    if (_city!.state != null && _city!.state!.isNotEmpty) {
      return '${_city!.name}, ${_city!.state}, ${_city!.country}';
    }
    return '${_city!.name}, ${_city!.country}';
  }

  Color _difficultyColor(double rating) {
    if (rating < 2.0) return const Color(0xFF2E9B1F);
    if (rating < 3.5) return const Color(0xFFFF9800);
    if (rating < 4.5) return const Color(0xFFE53935);
    return const Color(0xFFA855F7);
  }

  String _difficultyLabel(double rating) {
    if (rating < 2.0) return 'Easy';
    if (rating < 3.5) return 'Medium';
    if (rating < 4.5) return 'Hard';
    return 'Epic';
  }

  Future<void> _vote(String vote) async {
    try {
      final uid = AuthService.currentUser?.id ?? '';
      await QuestService().voteQuest(_quest.id, uid, vote);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vote recorded!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vote failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.dmCard : AppColors.background;
    final borderColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final titleColor = isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;
    final secondaryColor = isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;
    final scaffoldBg = isDark ? AppColors.dmSecondaryBackground : AppColors.secondaryBackground;
    final categoryColor = AppColors.categoryColor(_quest.category.value, darkMode: isDark);
    final green = isDark ? AppColors.dmPrimary : AppColors.primary;
    final diffColor = _difficultyColor(_quest.avgDifficultyRating);
    final diffLabel = _difficultyLabel(_quest.avgDifficultyRating);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          _quest.title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section A — Hero header
            Container(
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
                      _Pill(
                        label: _categoryLabel,
                        color: categoryColor,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _Pill(
                        label: diffLabel,
                        color: diffColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _quest.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: secondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _cityLabel,
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Row(
                    children: [
                      _StatChip(
                        label: '${_quest.currentPoints} pts',
                        color: green,
                        isDark: isDark,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StatChip(
                        label: '${_quest.completionCount} completions',
                        color: secondaryColor,
                        isDark: isDark,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StatChip(
                        label: '${_quest.netVotes > 0 ? '+' : ''}${_quest.netVotes} votes',
                        color: secondaryColor,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Section B — Description
            if (_quest.description != null && _quest.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.base),
              Container(
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
                      'About this Quest',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _quest.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: titleColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Section C — Info
            const SizedBox(height: AppSpacing.base),
            Container(
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
                    'Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(
                    icon: Icons.flag_outlined,
                    label: 'Status',
                    isDark: isDark,
                    trailing: _StatusBadge(status: _quest.status, isDark: isDark),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow(
                    icon: Icons.star_outline,
                    label: 'Avg difficulty',
                    isDark: isDark,
                    trailing: Text(
                      '${_quest.avgDifficultyRating.toStringAsFixed(1)} / 5.0'
                      '  (${_quest.ratingCount} ratings)',
                      style: TextStyle(fontSize: 13, color: secondaryColor),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Added',
                    isDark: isDark,
                    trailing: Text(
                      _formatDate(_quest.createdAt),
                      style: TextStyle(fontSize: 13, color: secondaryColor),
                    ),
                  ),
                ],
              ),
            ),

            // Section D — Vote buttons (pending quests only)
            if (_quest.status == QuestStatus.pending) ...[
              const SizedBox(height: AppSpacing.base),
              Container(
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
                      'Community Vote',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Vote to help this quest get approved. Quests reaching 100 net votes become active.',
                      style: TextStyle(fontSize: 13, color: secondaryColor),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _VotePill(
                          icon: Icons.thumb_up_outlined,
                          label: 'Upvote',
                          onTap: () => _vote('up'),
                          color: AppColors.categoryNature,
                          borderColor: borderColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm),
                          child: Text(
                            '${_quest.netVotes}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                        _VotePill(
                          icon: Icons.thumb_down_outlined,
                          label: 'Downvote',
                          onTap: () => _vote('down'),
                          color: AppColors.categoryFood,
                          borderColor: borderColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
  }

  String _monthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[month - 1];
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.dmBorder : AppColors.secondaryBackground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.trailing,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor =
        isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;

    return Row(
      children: [
        Icon(icon, size: 16, color: secondaryColor),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: secondaryColor,
          ),
        ),
        const Spacer(),
        trailing,
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final QuestStatus status;
  final bool isDark;

  const _StatusBadge({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isActive = status == QuestStatus.active;
    final color = isActive
        ? (isDark ? AppColors.dmPrimary : AppColors.primary)
        : (isDark ? AppColors.dmTextSecondary : AppColors.textSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        isActive ? 'Active' : 'Pending',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _VotePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color borderColor;

  const _VotePill({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
