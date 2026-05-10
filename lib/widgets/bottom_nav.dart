import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../screens/map_screen.dart';
import '../screens/quests_screen.dart';
import '../screens/record_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/record/record_step1_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MapScreen(),
    QuestsScreen(),
    RecordScreen(),
    StatsScreen(),
    ProfileScreen(),
  ];

  void _onTap(int index) {
    if (index == 2) {
      // Open the Record sheet without switching tabs
      showRecordStep1Sheet(context);
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark
        ? AppColors.dmSecondaryBackground
        : AppColors.background;
    final activeColor = isDark ? AppColors.dmPrimary : AppColors.primary;
    final inactiveColor =
        isDark ? AppColors.dmTextMuted : const Color(0xFF777777);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        backgroundColor: navBg,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
      ),
    );
  }
}

class _AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;

  const _AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.backgroundColor,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? AppColors.dmBorder : AppColors.cardBorder;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: 'Map',
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: onTap,
              ),
              _NavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.list_alt_outlined,
                activeIcon: Icons.list_alt,
                label: 'Quests',
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: onTap,
              ),
              _CenterNavButton(
                isActive: currentIndex == 2,
                activeColor: activeColor,
                onTap: () => onTap(2),
              ),
              _NavItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart,
                label: 'Stats',
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: onTap,
              ),
              _NavItem(
                index: 4,
                currentIndex: currentIndex,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final color = isActive ? activeColor : inactiveColor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
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

class _CenterNavButton extends StatelessWidget {
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _CenterNavButton({
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, -6),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
