import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_theme.dart';
import '../../models/quest.dart';
import '../../services/quest_service.dart';
import 'record_step3_screen.dart';

class RecordStep2Screen extends StatefulWidget {
  final QuestCategory category;
  final String? cityId;

  const RecordStep2Screen({super.key, required this.category, this.cityId});

  @override
  State<RecordStep2Screen> createState() => _RecordStep2ScreenState();
}

class _RecordStep2ScreenState extends State<RecordStep2Screen> {
  final _searchController = TextEditingController();
  final _questService = QuestService();

  late Future<List<Quest>> _questsFuture;
  Quest? _selectedQuest;
  String _searchQuery = '';

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
    _questsFuture = _questService.getActiveQuestsByCategory(
      widget.category,
      cityId: widget.cityId,
    );
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Quest> _filtered(List<Quest> quests) {
    if (_searchQuery.isEmpty) return quests;
    return quests.where((q) {
      return q.title.toLowerCase().contains(_searchQuery) ||
          (q.description?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  void _onQuestSelected(Quest quest) {
    HapticFeedback.selectionClick();
    setState(() => _selectedQuest = quest);
  }

  void _onContinue() {
    if (_selectedQuest == null) return;
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, secAnim) => RecordStep3Screen(
          quest: _selectedQuest!,
          category: widget.category,
        ),
        transitionsBuilder: (ctx, anim, secAnim, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        AppColors.categoryColor(widget.category.value, darkMode: isDark);
    final bg = isDark ? AppColors.dmBackground : AppColors.secondaryBackground;
    final titleColor =
        isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;
    final subtitleColor =
        isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;
    final inputBg = isDark ? AppColors.dmInput : AppColors.background;
    final borderColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final navBg =
        isDark ? AppColors.dmSecondaryBackground : AppColors.background;

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
          // ── Step indicator + header ──────────────────────────────────
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
                _StepIndicator(isDark: isDark, currentStep: 2),
                const SizedBox(height: AppSpacing.base),
                Row(
                  children: [
                    // Category pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _categoryIcon(widget.category),
                            size: 12,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _categoryLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Select a Quest',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Which quest did you complete?',
                  style: TextStyle(fontSize: 14, color: subtitleColor),
                ),
                const SizedBox(height: AppSpacing.base),
                // Search bar
                TextField(
                  controller: _searchController,
                  style: TextStyle(
                    fontSize: 15,
                    color: titleColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search quests…',
                    filled: true,
                    fillColor: inputBg,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: subtitleColor,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () => _searchController.clear(),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: subtitleColor,
                            ),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.md,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.button),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.button),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.button),
                      borderSide: BorderSide(color: color, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // ── Quest list ───────────────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<Quest>>(
              future: _questsFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: color,
                      strokeWidth: 2,
                    ),
                  );
                }
                if (snap.hasError) {
                  return _ErrorState(
                    isDark: isDark,
                    onRetry: () => setState(() {
                      _questsFuture = _questService
                          .getActiveQuestsByCategory(widget.category);
                    }),
                  );
                }

                final quests = _filtered(snap.data ?? []);

                if (quests.isEmpty) {
                  return _EmptyState(
                    isDark: isDark,
                    hasSearch: _searchQuery.isNotEmpty,
                    category: _categoryLabel,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: quests.length,
                  separatorBuilder: (ctx, i) => Divider(
                    height: 1,
                    thickness: 1,
                    color: borderColor,
                    indent: AppSpacing.base,
                    endIndent: AppSpacing.base,
                  ),
                  itemBuilder: (context, i) {
                    final quest = quests[i];
                    final isSelected = _selectedQuest?.id == quest.id;
                    return _QuestRow(
                      quest: quest,
                      isSelected: isSelected,
                      isDark: isDark,
                      accentColor: color,
                      onTap: () => _onQuestSelected(quest),
                    );
                  },
                );
              },
            ),
          ),
          // ── Continue button ──────────────────────────────────────────
          Container(
            color: navBg,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.md,
              AppSpacing.base,
              AppSpacing.md +
                  MediaQuery.of(context).padding.bottom,
            ),
            child: AnimatedOpacity(
              opacity: _selectedQuest != null ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedQuest != null ? _onContinue : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: color,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _categoryIcon(QuestCategory cat) {
  switch (cat) {
    case QuestCategory.nature:
      return Icons.park_outlined;
    case QuestCategory.culture:
      return Icons.theater_comedy_outlined;
    case QuestCategory.food:
      return Icons.restaurant_outlined;
    case QuestCategory.landmark:
      return Icons.location_city_outlined;
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final bool isDark;
  final int currentStep;

  const _StepIndicator({required this.isDark, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.dmPrimary : AppColors.primary;
    final doneColor =
        (isDark ? AppColors.dmPrimary : AppColors.primary).withValues(alpha: 0.4);
    final inactiveColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final textColor = isDark ? AppColors.dmTextMuted : AppColors.textTertiary;

    Color dotColor(int step) {
      if (step < currentStep) return doneColor;
      if (step == currentStep) return activeColor;
      return inactiveColor;
    }

    Color lineColor(int afterStep) =>
        afterStep < currentStep ? doneColor : inactiveColor;

    return Row(
      children: [
        _StepDot(active: currentStep == 1, color: dotColor(1), number: 1),
        Expanded(child: Container(height: 2, color: lineColor(1))),
        _StepDot(active: currentStep == 2, color: dotColor(2), number: 2),
        Expanded(child: Container(height: 2, color: lineColor(2))),
        _StepDot(active: currentStep == 3, color: dotColor(3), number: 3),
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

class _StepDot extends StatelessWidget {
  final bool active;
  final Color color;
  final int number;

  const _StepDot(
      {required this.active, required this.color, required this.number});

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

// ─── Quest Row ───────────────────────────────────────────────────────────────

class _QuestRow extends StatefulWidget {
  final Quest quest;
  final bool isSelected;
  final bool isDark;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuestRow({
    required this.quest,
    required this.isSelected,
    required this.isDark,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_QuestRow> createState() => _QuestRowState();
}

class _QuestRowState extends State<_QuestRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
      value: 0.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleColor =
        widget.isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;
    final metaColor =
        widget.isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;
    final rowBg = widget.isSelected
        ? widget.accentColor.withValues(alpha: 0.06)
        : Colors.transparent;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          color: rowBg,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Radio circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? widget.accentColor
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.accentColor
                        : (widget.isDark
                            ? AppColors.dmBorder
                            : AppColors.cardBorder),
                    width: 1.5,
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              // Quest info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.quest.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    if (widget.quest.description != null &&
                        widget.quest.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.quest.description!,
                        style: TextStyle(fontSize: 13, color: metaColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Points badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '${widget.quest.currentPoints} pts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: widget.accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty & Error States ────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final bool hasSearch;
  final String category;

  const _EmptyState({
    required this.isDark,
    required this.hasSearch,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? AppColors.dmTextMuted : AppColors.textTertiary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch ? Icons.search_off_rounded : Icons.inbox_outlined,
              size: 48,
              color: muted,
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              hasSearch
                  ? 'No quests match your search'
                  : 'No $category quests yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: muted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              hasSearch
                  ? 'Try a different search term'
                  : 'Check back soon or submit one!',
              style: TextStyle(fontSize: 13, color: muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const _ErrorState({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? AppColors.dmTextMuted : AppColors.textTertiary;
    final primary = isDark ? AppColors.dmPrimary : AppColors.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: muted),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Failed to load quests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: muted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Try again',
                style: TextStyle(color: primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
