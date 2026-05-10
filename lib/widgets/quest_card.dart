import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../services/quest_service.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  final String testUserId;
  final VoidCallback? onVoted;

  const QuestCard({
    super.key,
    required this.quest,
    required this.testUserId,
    this.onVoted,
  });

  String get _categoryEmoji {
    switch (quest.category) {
      case QuestCategory.nature:
        return '🌿';
      case QuestCategory.culture:
        return '🎭';
      case QuestCategory.food:
        return '🍜';
      case QuestCategory.landmark:
        return '🏛️';
    }
  }

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

  Color get _statusColor {
    switch (quest.status) {
      case QuestStatus.active:
        return Colors.green;
      case QuestStatus.pending:
        return Colors.orange;
    }
  }

  Future<void> _vote(BuildContext context, String vote) async {
    try {
      await QuestService().voteQuest(quest.id, testUserId, vote);
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    quest.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Text(
                    '${quest.currentPoints} pts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  '$_categoryEmoji $_categoryLabel',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _statusColor),
                  ),
                  child: Text(
                    quest.status.value.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (quest.description != null && quest.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                quest.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (quest.status == QuestStatus.pending) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Votes: ${quest.netVotes}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _vote(context, 'up'),
                    icon: const Icon(Icons.thumb_up_outlined, size: 16),
                    label: const Text('Upvote'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _vote(context, 'down'),
                    icon: const Icon(Icons.thumb_down_outlined, size: 16),
                    label: const Text('Downvote'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
