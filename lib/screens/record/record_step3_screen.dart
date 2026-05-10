import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/app_theme.dart';
import '../../models/quest.dart';
import '../../services/auth_service.dart';
import '../../services/completion_service.dart';
import '../../services/logger_service.dart';
import '../../services/media_upload_service.dart';

class RecordStep3Screen extends StatefulWidget {
  final Quest quest;
  final QuestCategory category;

  const RecordStep3Screen({
    super.key,
    required this.quest,
    required this.category,
  });

  @override
  State<RecordStep3Screen> createState() => _RecordStep3ScreenState();
}

class _RecordStep3ScreenState extends State<RecordStep3Screen> {
  final _taglineController = TextEditingController();
  final _friendSearchController = TextEditingController();
  final _completionService = CompletionService();
  final _mediaService = MediaUploadService();

  int _difficultyRating = 0;
  File? _pickedFile;
  bool _isVideo = false;
  bool _isUploading = false;
  bool _isSubmitting = false;

  // Tagged friends: list of {id, username}
  final List<Map<String, dynamic>> _taggedFriends = [];
  List<Map<String, dynamic>> _friendSearchResults = [];
  bool _searchingFriends = false;

  String get _categoryLabel {
    switch (widget.category) {
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

  @override
  void initState() {
    super.initState();
    _friendSearchController.addListener(_onFriendSearchChanged);
  }

  @override
  void dispose() {
    _taglineController.dispose();
    _friendSearchController.dispose();
    super.dispose();
  }

  // ─── Friend search ────────────────────────────────────────────────────────

  Future<void> _onFriendSearchChanged() async {
    final q = _friendSearchController.text.trim();
    if (q.isEmpty) {
      setState(() => _friendSearchResults = []);
      return;
    }
    setState(() => _searchingFriends = true);
    try {
      final results = await _completionService.searchUsers(
        q,
        excludeUserId: AuthService.currentUser!.id,
      );
      if (mounted) setState(() => _friendSearchResults = results);
    } catch (_) {
      if (mounted) setState(() => _friendSearchResults = []);
    } finally {
      if (mounted) setState(() => _searchingFriends = false);
    }
  }

  void _tagFriend(Map<String, dynamic> user) {
    final alreadyTagged = _taggedFriends.any((f) => f['id'] == user['id']);
    if (alreadyTagged) return;
    setState(() {
      _taggedFriends.add(user);
      _friendSearchController.clear();
      _friendSearchResults = [];
    });
  }

  void _untagFriend(String userId) {
    setState(() => _taggedFriends.removeWhere((f) => f['id'] == userId));
  }

  // ─── Media ────────────────────────────────────────────────────────────────

  Future<void> _pickMedia(ImageSource source, {bool video = false}) async {
    try {
      if (video) {
        final picked = await ImagePicker().pickVideo(
          source: source,
          maxDuration: const Duration(minutes: 3),
        );
        if (picked == null) return;
        setState(() {
          _pickedFile = File(picked.path);
          _isVideo = true;
        });
      } else {
        final picked = await ImagePicker().pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 2048,
          maxHeight: 2048,
        );
        if (picked == null) return;
        setState(() {
          _pickedFile = File(picked.path);
          _isVideo = false;
        });
      }
    } on MediaPickCancelledException {
      // user dismissed — no-op
    } catch (e) {
      AppLogger.e('Step3: media pick failed', error: e);
    }
  }

  void _removeMedia() => setState(() {
    _pickedFile = null;
    _isVideo = false;
  });

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_difficultyRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a difficulty rating')),
      );
      return;
    }

    // 👈 Add a validation check so the user can't skip the photo/video
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo or video as proof')),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final userId = AuthService.currentUser!.id;

    setState(() => _isSubmitting = true);
    try {
      String? mediaUrl;
      final String mediaType = _isVideo ? 'video' : 'photo';

      if (_pickedFile != null) {
        setState(() => _isUploading = true);
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();

        final result = await _mediaService.uploadFile(
          file: _pickedFile!,
          userId: userId,
          completionId: tempId,
          isVideo: _isVideo,
        );
        mediaUrl = result.publicUrl;

        if (mounted) setState(() => _isUploading = false);
      }

      await _completionService.submitCompletion(
        questId: widget.quest.id,
        cityId: widget.quest.cityId,
        pointsAwarded: widget.quest.currentPoints,
        userId: userId,
        difficultyRating: _difficultyRating,
        tagline: _taglineController.text.trim(),
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        taggedUserIds: _taggedFriends.map((f) => f['id'] as String).toList(),
      );

      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
      _switchToQuests(context);
    } catch (e) {
      AppLogger.e('Step3: submit failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isUploading = false;
        });
      }
    }
  }

  /// Navigates the root navigator to the Quests tab by pushing a named route
  /// or by finding the MainShell and calling its onTap.
  void _switchToQuests(BuildContext ctx) {
    // Fire-and-forget: after pop we can't reliably call into the shell.
    // The user lands on whichever tab was active — acceptable for MVP.
    // A proper solution would use a global nav controller (tracked in a future issue).
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.categoryColor(
      widget.category.value,
      darkMode: isDark,
    );
    final bg = isDark ? AppColors.dmBackground : AppColors.secondaryBackground;
    final navBg = isDark
        ? AppColors.dmSecondaryBackground
        : AppColors.background;
    final titleColor = isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;
    final subtitleColor = isDark
        ? AppColors.dmTextSecondary
        : AppColors.textSecondary;
    final borderColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final cardBg = isDark ? AppColors.dmCard : AppColors.background;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: navBg,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Record Quest'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header
          Container(
            color: navBg,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.sm,
              AppSpacing.base,
              AppSpacing.base,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepIndicator(isDark: isDark, currentStep: 3),
                const SizedBox(height: AppSpacing.base),
                _CategoryPill(label: _categoryLabel, color: color),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.quest.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Add your completion details',
                  style: TextStyle(fontSize: 13, color: subtitleColor),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // Scrollable form
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.base),
              children: [
                // ── Difficulty rating ─────────────────────────────────────
                _SectionLabel(label: 'Difficulty', isDark: isDark),
                const SizedBox(height: AppSpacing.sm),
                _DifficultyRow(
                  selected: _difficultyRating,
                  accentColor: color,
                  isDark: isDark,
                  onChanged: (v) => setState(() => _difficultyRating = v),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Media upload ──────────────────────────────────────────
                _SectionLabel(label: 'Photo / Video', isDark: isDark),
                const SizedBox(height: AppSpacing.sm),
                _MediaPicker(
                  pickedFile: _pickedFile,
                  isVideo: _isVideo,
                  isUploading: _isUploading,
                  accentColor: color,
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  onPickImage: (src) => _pickMedia(src),
                  onPickVideo: (src) => _pickMedia(src, video: true),
                  onRemove: _removeMedia,
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Tagline ───────────────────────────────────────────────
                _SectionLabel(label: 'Tagline', isDark: isDark, optional: true),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _taglineController,
                  maxLength: 120,
                  maxLines: 2,
                  style: TextStyle(fontSize: 15, color: titleColor),
                  decoration: InputDecoration(
                    hintText: 'A short caption for your completion…',
                    counterStyle: TextStyle(color: subtitleColor, fontSize: 11),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Tag friends ───────────────────────────────────────────
                _SectionLabel(
                  label: 'Tag Friends',
                  isDark: isDark,
                  optional: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (_taggedFriends.isNotEmpty) ...[
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: _taggedFriends.map((f) {
                      return Chip(
                        label: Text(
                          '@${f['username']}',
                          style: TextStyle(fontSize: 12, color: color),
                        ),
                        backgroundColor: color.withValues(alpha: 0.10),
                        side: BorderSide(color: color.withValues(alpha: 0.3)),
                        deleteIcon: Icon(Icons.close, size: 14, color: color),
                        onDeleted: () => _untagFriend(f['id'] as String),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                TextField(
                  controller: _friendSearchController,
                  style: TextStyle(fontSize: 15, color: titleColor),
                  decoration: InputDecoration(
                    hintText: 'Search by username…',
                    prefixIcon: Icon(
                      Icons.person_search_outlined,
                      size: 20,
                      color: subtitleColor,
                    ),
                    suffixIcon: _searchingFriends
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: color,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                if (_friendSearchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: _friendSearchResults.map((user) {
                        final alreadyTagged = _taggedFriends.any(
                          (f) => f['id'] == user['id'],
                        );
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: color.withValues(alpha: 0.12),
                            child: Text(
                              (user['username'] as String)[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Text(
                            '@${user['username']}',
                            style: TextStyle(fontSize: 14, color: titleColor),
                          ),
                          trailing: alreadyTagged
                              ? Icon(Icons.check, size: 16, color: color)
                              : null,
                          onTap: alreadyTagged ? null : () => _tagFriend(user),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),

          // Submit button
          Container(
            color: navBg,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.md,
              AppSpacing.base,
              AppSpacing.md + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: color.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(_isUploading ? 'Uploading…' : 'Submitting…'),
                        ],
                      )
                    : const Text('Submit Completion'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step Indicator (reused) ─────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final bool isDark;
  final int currentStep;

  const _StepIndicator({required this.isDark, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.dmPrimary : AppColors.primary;
    final doneColor = (isDark ? AppColors.dmPrimary : AppColors.primary)
        .withValues(alpha: 0.4);
    final inactiveColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final textColor = isDark ? AppColors.dmTextMuted : AppColors.textTertiary;

    Color dotColor(int s) {
      if (s < currentStep) return doneColor;
      if (s == currentStep) return activeColor;
      return inactiveColor;
    }

    Color lineColor(int after) =>
        after < currentStep ? doneColor : inactiveColor;

    return Row(
      children: [
        _Dot(active: currentStep == 1, color: dotColor(1), number: 1),
        Expanded(child: Container(height: 2, color: lineColor(1))),
        _Dot(active: currentStep == 2, color: dotColor(2), number: 2),
        Expanded(child: Container(height: 2, color: lineColor(2))),
        _Dot(active: currentStep == 3, color: dotColor(3), number: 3),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Step $currentStep of 3',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  final Color color;
  final int number;
  const _Dot({required this.active, required this.color, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: active ? color : Colors.transparent,
        border: active ? null : Border.all(color: color, width: 1.5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

// ─── Category Pill ───────────────────────────────────────────────────────────

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
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Section Label ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool optional;
  const _SectionLabel({
    required this.label,
    required this.isDark,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;
    final muted = isDark ? AppColors.dmTextMuted : AppColors.textTertiary;
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          Text('optional', style: TextStyle(fontSize: 11, color: muted)),
        ],
      ],
    );
  }
}

// ─── Difficulty Row ──────────────────────────────────────────────────────────

class _DifficultyRow extends StatelessWidget {
  final int selected;
  final Color accentColor;
  final bool isDark;
  final ValueChanged<int> onChanged;

  const _DifficultyRow({
    required this.selected,
    required this.accentColor,
    required this.isDark,
    required this.onChanged,
  });

  static const _labels = [
    '',
    'Easy',
    'Moderate',
    'Challenging',
    'Hard',
    'Epic',
  ];

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final textColor = isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;
    final muted = isDark ? AppColors.dmTextMuted : AppColors.textTertiary;

    return Row(
      children: List.generate(5, (i) {
        final value = i + 1;
        final isSelected = value == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? accentColor : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.button),
                border: Border.all(
                  color: isSelected ? accentColor : borderColor,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _labels[value],
                    style: TextStyle(
                      fontSize: 9,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.85)
                          : muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Media Picker ────────────────────────────────────────────────────────────

class _MediaPicker extends StatelessWidget {
  final File? pickedFile;
  final bool isVideo;
  final bool isUploading;
  final Color accentColor;
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final void Function(ImageSource) onPickImage;
  final void Function(ImageSource) onPickVideo;
  final VoidCallback onRemove;

  const _MediaPicker({
    required this.pickedFile,
    required this.isVideo,
    required this.isUploading,
    required this.accentColor,
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.onPickImage,
    required this.onPickVideo,
    required this.onRemove,
  });

  void _showSourceSheet(BuildContext context, {required bool video}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bg = isDark
            ? AppColors.dmSecondaryBackground
            : AppColors.background;
        final titleColor = isDark
            ? AppColors.dmTextPrimary
            : AppColors.textPrimary;
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.sm,
            AppSpacing.base,
            AppSpacing.lg + MediaQuery.of(ctx).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dmBorder : AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                video ? 'Record or Choose Video' : 'Take or Choose Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: accentColor),
                title: Text(
                  video ? 'Record video' : 'Take photo',
                  style: TextStyle(color: titleColor),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  video
                      ? onPickVideo(ImageSource.camera)
                      : onPickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: accentColor),
                title: Text(
                  video ? 'Choose from gallery' : 'Choose from gallery',
                  style: TextStyle(color: titleColor),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  video
                      ? onPickVideo(ImageSource.gallery)
                      : onPickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pickedFile != null) {
      return Stack(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: borderColor),
              color: cardBg,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.card - 1),
              child: isVideo
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam, size: 40, color: accentColor),
                          const SizedBox(height: 8),
                          Text(
                            'Video selected',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Image.file(
                      pickedFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
          if (isUploading)
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _MediaButton(
            icon: Icons.camera_alt_outlined,
            label: 'Photo',
            color: accentColor,
            cardBg: cardBg,
            borderColor: borderColor,
            onTap: () => _showSourceSheet(context, video: false),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MediaButton(
            icon: Icons.videocam_outlined,
            label: 'Video',
            color: accentColor,
            cardBg: cardBg,
            borderColor: borderColor,
            onTap: () => _showSourceSheet(context, video: true),
          ),
        ),
      ],
    );
  }
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color cardBg;
  final Color borderColor;
  final VoidCallback onTap;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.cardBg,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
