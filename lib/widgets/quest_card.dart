import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/quest.dart';
import '../screens/quest_detail_screen.dart';
import '../services/auth_service.dart';
import '../services/quest_service.dart';

class QuestCard extends StatefulWidget {
  final Quest quest;
  final VoidCallback? onVoted;

  const QuestCard({
    super.key,
    required this.quest,
    this.onVoted,
  });

  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> {
  String? _userVote;
  bool _voteLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserVote();
  }

  Future<void> _loadUserVote() async {
    final uid = AuthService.currentUser?.id;
    if (uid == null) return;
    final vote = await QuestService().getUserVote(widget.quest.id, uid);
    if (mounted) setState(() => _userVote = vote);
  }

  String get _categoryLabel {
    switch (widget.quest.category) {
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
    if (_voteLoading) return;
    final uid = AuthService.currentUser?.id ?? '';
    setState(() => _voteLoading = true);
    try {
      if (_userVote == vote) {
        await QuestService().removeVote(widget.quest.id, uid);
        setState(() => _userVote = null);
      } else {
        await QuestService().voteQuest(widget.quest.id, uid, vote);
        setState(() => _userVote = vote);
      }
      widget.onVoted?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vote failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _voteLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.dmCard : AppColors.background;
    final borderColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final categoryColor =
        AppColors.categoryColor(widget.quest.category.value, darkMode: isDark);
    final titleColor =
        isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;
    final metaColor =
        isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => QuestDetailScreen(quest: widget.quest),
        ));
      },
      child: Container(
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
                      Row(
                        children: [
                          _CategoryPill(
                            label: _categoryLabel,
                            color: categoryColor,
                          ),
                          if (widget.quest.cityName != null) ...[
                            const SizedBox(width: AppSpacing.xs),
                            _CityPill(name: widget.quest.cityName!),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        widget.quest.title,
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
                _PointsBadge(points: widget.quest.currentPoints),
              ],
            ),
            if (widget.quest.description != null &&
                widget.quest.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.quest.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: metaColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (widget.quest.status == QuestStatus.pending) ...[
              const SizedBox(height: AppSpacing.md),
              _VoteRow(
                netVotes: widget.quest.netVotes,
                onUpvote: () => _vote(context, 'up'),
                onDownvote: () => _vote(context, 'down'),
                isDark: isDark,
                userVote: _userVote,
              ),
            ],
          ],
        ),
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
  final String? userVote;

  const _VoteRow({
    required this.netVotes,
    required this.onUpvote,
    required this.onDownvote,
    required this.isDark,
    required this.userVote,
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
          isActive: userVote == 'up',
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
          isActive: userVote == 'down',
        ),
      ],
    );
  }
}

class _CityPill extends StatelessWidget {
  const _CityPill({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.dmSecondaryBackground : AppColors.secondaryBackground;
    final fg = isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, size: 10, color: fg),
          const SizedBox(width: 3),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              color: fg,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
  final bool isActive;

  const _VotePill({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.borderColor,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: isActive ? color : borderColor),
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
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
