import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import 'doctor_dashboard_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_schedule_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorMainNavigation extends StatefulWidget {
  const DoctorMainNavigation({super.key});

  @override
  State<DoctorMainNavigation> createState() => _DoctorMainNavigationState();
}

class _DoctorMainNavigationState extends State<DoctorMainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final List<AnimationController> _indicatorControllers;

  static const _screens = [
    DoctorDashboardScreen(),
    DoctorAppointmentsScreen(),
    DoctorScheduleScreen(),
    DoctorProfileScreen(),
  ];

  static const _items = [
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _NavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'RDV',
    ),
    _NavItem(
      icon: Icons.schedule_outlined,
      activeIcon: Icons.schedule_rounded,
      label: 'Horaires',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _indicatorControllers = List.generate(
      _items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 280),
      ),
    );
    _indicatorControllers[0].value = 1.0;
  }

  @override
  void dispose() {
    for (final c in _indicatorControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    _indicatorControllers[_currentIndex].reverse();
    _indicatorControllers[index].forward();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      extendBody: true,
      body: Stack(
        children: [
          // Dark mode mesh gradient background
          if (context.isDark)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(gradient: context.bgGradient),
              ),
            ),
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ],
      ),
      bottomNavigationBar: _GlassNavBar(
        currentIndex: _currentIndex,
        items: _items,
        indicatorControllers: _indicatorControllers,
        onTap: _onTabTap,
      ),
    );
  }
}

// ─── Glass bottom nav bar ────────────────────────────────────────────────────

class _GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final List<AnimationController> indicatorControllers;
  final ValueChanged<int> onTap;

  const _GlassNavBar({
    required this.currentIndex,
    required this.items,
    required this.indicatorControllers,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: context.isDark
                ? AppColors.cardBgDark.withValues(alpha: 0.85)
                : AppColors.surface.withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(
                color: context.dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: List.generate(items.length, (i) {
                  return Expanded(
                    child: _NavTab(
                      item: items[i],
                      isActive: currentIndex == i,
                      controller: indicatorControllers[i],
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final AnimationController controller;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.isActive,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    );
    final fadeAnim = CurvedAnimation(parent: controller, curve: Curves.easeOut);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: scaleAnim,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    size: 22,
                    color: isActive ? AppColors.primary : context.mutedText,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FadeTransition(
                opacity: fadeAnim,
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? AppColors.primary : context.mutedText,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
