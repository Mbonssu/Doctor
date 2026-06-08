import 'dart:ui';
import 'package:flutter/material.dart';
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
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabCtrl;

  final _screens = const [
    DoctorDashboardScreen(),
    DoctorAppointmentsScreen(),
    DoctorScheduleScreen(),
    DoctorProfileScreen(),
  ];

  final _items = const [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'RDV'),
    _NavItem(icon: Icons.schedule_outlined, activeIcon: Icons.schedule_rounded, label: 'Horaires'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _fabCtrl.reset();
    _fabCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final _isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.isDark 
          ? AppColors.backgroundDark 
          : AppColors.background,
      body: Stack(
        children: [
          if (context.isDark)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF070E21),
                    Color(0xFF0D1730),
                    Color(0xFF1B2E5E),
                  ],
                ),
              ),
            ),
          
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.dividerColor, width: 1)),
          color: context.cardColor,
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: NavigationBar(
              elevation: 0,
              backgroundColor: context.cardColor.withValues(alpha: 0.7),
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabTap,
              indicatorColor: AppColors.primary.withValues(alpha: 0.1),
              destinations: _items.map((item) {
                return NavigationDestination(
                  icon: Icon(item.icon, color: context.mutedText),
                  selectedIcon: Icon(
                    item.activeIcon,
                    color: AppColors.primary,
                  ),
                  label: item.label,
                );
              }).toList(),
            ),
          ),
        ),
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
