import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_theme.dart';
import '../../models/quest.dart';
import 'record_step2_screen.dart';

/// Shows the Step 1 category sheet from any [BuildContext].
Future<void> showRecordStep1Sheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    isScrollControlled: false,
    isDismissible: true,
    enableDrag: true,
    builder: (_) => const _RecordStep1Sheet(),
  );
}

class _RecordStep1Sheet extends StatefulWidget {
  const _RecordStep1Sheet();

  @override
  State<_RecordStep1Sheet> createState() => _RecordStep1SheetState();
}

class _RecordStep1SheetState extends State<_RecordStep1Sheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onCategoryTapped(BuildContext context, QuestCategory category) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(); // close sheet
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, secAnim) =>
            RecordStep2Screen(category: category),
        transitionsBuilder: (ctx, anim, secAnim, child) {
          final curved =
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 320),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg =
        isDark ? AppColors.dmSecondaryBackground : AppColors.background;
    final handleColor = isDark ? AppColors.dmBorder : AppColors.cardBorder;
    final titleColor =
        isDark ? AppColors.dmTextPrimary : AppColors.textPrimary;
    final subtitleColor =
        isDark ? AppColors.dmTextSecondary : AppColors.textSecondary;

    return FadeTransition(
      opacity: _fade,
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        // Let the sheet size itself to its content + safe area
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.sm,
              AppSpacing.base,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                // Header
                Text(
                  'Choose a Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'What type of quest did you complete?',
                  style: TextStyle(fontSize: 14, color: subtitleColor),
                ),
                const SizedBox(height: AppSpacing.base),
                // 2×2 grid — fixed-height rows
                _CategoryGrid(
                  isDark: isDark,
                  onTap: (cat) => _onCategoryTapped(context, cat),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 2×2 Category Grid ───────────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  final bool isDark;
  final void Function(QuestCategory) onTap;

  const _CategoryGrid({required this.isDark, required this.onTap});

  static const _categories = [
    (QuestCategory.nature, 'Nature', Icons.park_outlined),
    (QuestCategory.culture, 'Culture', Icons.theater_comedy_outlined),
    (QuestCategory.food, 'Food', Icons.restaurant_outlined),
    (QuestCategory.landmark, 'Landmark', Icons.location_city_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _CategoryTile(
                category: _categories[0].$1,
                label: _categories[0].$2,
                icon: _categories[0].$3,
                isDark: isDark,
                onTap: () => onTap(_categories[0].$1),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _CategoryTile(
                category: _categories[1].$1,
                label: _categories[1].$2,
                icon: _categories[1].$3,
                isDark: isDark,
                onTap: () => onTap(_categories[1].$1),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _CategoryTile(
                category: _categories[2].$1,
                label: _categories[2].$2,
                icon: _categories[2].$3,
                isDark: isDark,
                onTap: () => onTap(_categories[2].$1),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _CategoryTile(
                category: _categories[3].$1,
                label: _categories[3].$2,
                icon: _categories[3].$3,
                isDark: isDark,
                onTap: () => onTap(_categories[3].$1),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Category Tile ───────────────────────────────────────────────────────────

class _CategoryTile extends StatefulWidget {
  final QuestCategory category;
  final String label;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.label,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 180),
      value: 0.0,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) => _pressCtrl.forward();
  void _up(TapUpDetails _) {
    _pressCtrl.reverse();
    widget.onTap();
  }
  void _cancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(
      widget.category.value,
      darkMode: widget.isDark,
    );
    final cardBg = widget.isDark ? AppColors.dmCard : AppColors.background;
    final borderColor =
        widget.isDark ? AppColors.dmBorder : AppColors.cardBorder;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: _down,
        onTapUp: _up,
        onTapCancel: _cancel,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: widget.isDark ? 0.22 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Ghost background icon
              Positioned(
                right: -6,
                bottom: -6,
                child: Icon(
                  widget.icon,
                  size: 72,
                  color: color.withValues(alpha: 0.07),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.icon, size: 20, color: color),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: widget.isDark
                                ? AppColors.dmTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
