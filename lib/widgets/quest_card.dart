import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/quest.dart';
import '../services/auth_service.dart';
import '../services/quest_service.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onVoted;

  const QuestCard({
    super.key,
    required this.quest,
    this.onVoted,
  });

  String get _categoryLabel {
    switch (quest.category) {
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

  Future<void> _vote(BuildContext context, String vote) async {
    try {
      final uid = AuthService.currentUser?.id ?? '';
      await QuestService().voteQuest(quest.id, uid, vote);
      onVoted?.call();
    } catch (e) {
      if (context.mounted) {
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
    final categoryColor =
        AppColors.categoryColor(quest.category.value, darkMode: isDark);
    final titleColor =
        isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;
    final metaColor =
        isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryPill(
                        label: _categoryLabel,
                        color: categoryColor,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        quest.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _PointsBadge(points: quest.currentPoints),
              ],
            ),
            if (quest.description != null &&
                quest.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                quest.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: metaColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (quest.status == QuestStatus.pending) ...[
              const SizedBox(height: AppSpacing.md),
              _VoteRow(
                netVotes: quest.netVotes,
                onUpvote: () => _vote(context, 'up'),
                onDownvote: () => _vote(context, 'down'),
                isDark: isDark,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryPill({required this.label, required this.color});

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

class _PointsBadge extends StatelessWidget {
  final int points;

  const _PointsBadge({required this.points});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final green = isDark ? AppColors.dmPrimary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$points pts',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: green,
        ),
      ),
    );
  }
}

class _VoteRow extends StatelessWidget {
  final int netVotes;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final bool isDark;

  const _VoteRow({
    required this.netVotes,
    required this.onUpvote,
    required this.onDownvote,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final textColor =
        isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;

    return Row(
      children: [
        _VotePill(
          icon: Icons.thumb_up_outlined,
          label: 'Up',
          onTap: onUpvote,
          color: AppColors.categoryNature,
          borderColor: borderColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            '$netVotes',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        _VotePill(
          icon: Icons.thumb_down_outlined,
          label: 'Down',
          onTap: onDownvote,
          color: AppColors.categoryFood,
          borderColor: borderColor,
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
