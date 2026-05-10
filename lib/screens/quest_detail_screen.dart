import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../config/app_theme.dart';
import '../models/quest.dart';
import '../services/auth_service.dart';
import '../services/city_service.dart';
import '../services/completion_service.dart';
import '../services/quest_service.dart';
import 'profile_screen.dart';

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

  Map<String, dynamic>? _completion;
  bool _loadingCompletion = true;

  @override
  void initState() {
    super.initState();
    _quest = widget.quest;
    _loadCity();
    _loadCompletion();
  }

  Future<void> _loadCompletion() async {
    final uid = AuthService.currentUser?.id;
    if (uid == null) {
      if (mounted) setState(() => _loadingCompletion = false);
      return;
    }
    Map<String, dynamic>? comp = await CompletionService().getCompletionForQuest(_quest.id, uid);
    
    if (comp == null) {
      comp = await CompletionService().getLatestCompletionForQuest(_quest.id);
    }

    if (mounted) {
      setState(() {
        _completion = comp;
        _loadingCompletion = false;
      });
    }
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
            // Hero image
            if (_quest.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: Image.network(
                  _quest.imageUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
            ],

            // Section D — Vote buttons (pending quests only)
            if (_quest.status == QuestStatus.pending) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
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
              const SizedBox(height: AppSpacing.base),
            ],

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
                        label: _completion != null 
                            ? '${_completion!['points_awarded']} pts earned' 
                            : '${_quest.currentPoints} pts',
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

            // Section C — User's Completion Data
            if (!_loadingCompletion && _completion != null) ...[
              const SizedBox(height: AppSpacing.base),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dmPrimary.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: green.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _completion!['user_id'] == AuthService.currentUser?.id
                                ? 'You completed this quest!'
                                : '${_completion!['users']?['username'] ?? 'Someone'} completed this quest!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_completion!['completion_tags'] != null && (_completion!['completion_tags'] as List).isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: 4,
                        children: [
                          Text('with:', style: TextStyle(fontSize: 13, color: secondaryColor)),
                          ...(_completion!['completion_tags'] as List).map((t) {
                            final user = t['users'];
                            if (user == null) return const SizedBox.shrink();
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ProfileScreen(userId: user['id'] as String)),
                                );
                              },
                              child: Text(
                                '@${user['username']}',
                                style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                    if (_completion!['tagline'] != null && _completion!['tagline'].toString().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '“${_completion!['tagline']}”',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                    if (_completion!['media_url'] != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      if (_completion!['media_type'] == 'image' || _completion!['media_type'] == 'photo')
                        GestureDetector(
                          onTap: () => _openMedia(_completion!['media_url']),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            child: Image.network(
                              _completion!['media_url'],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  color: Colors.black12,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 200,
                                color: Colors.black12,
                                child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.black26)),
                              ),
                            ),
                          ),
                        )
                      else if (_completion!['media_type'] == 'video')
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          child: _InlineVideoPlayer(url: _completion!['media_url']),
                        )
                      else
                        InkWell(
                          onTap: () => _openMedia(_completion!['media_url']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: green,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.file_present,
                                  color: isDark ? Colors.black : Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'View Attachment',
                                  style: TextStyle(
                                    color: isDark ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
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

  Future<void> _openMedia(String urlStr) async {
    try {
      final url = Uri.parse(urlStr);
      final success = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open media link.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening media: $e')),
        );
      }
    }
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

class _InlineVideoPlayer extends StatefulWidget {
  final String url;
  const _InlineVideoPlayer({required this.url});

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        width: double.infinity,
        height: 200,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          _ControlsOverlay(controller: _controller),
          VideoProgressIndicator(_controller, allowScrubbing: true),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 50.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
