import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../home/home_screen.dart';
import '../doctors/doctors_screen.dart';
import '../appointments/appointments_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _fabCtrl;
  late final List<AnimationController> _tabControllers;

  static const _screens = [
    HomeScreen(),
    DoctorsScreen(),
    AppointmentsScreen(),
    ProfileScreen(),
  ];

  static const _items = [
    _NavItem(icon: Icons.home_outlined,           activeIcon: Icons.home_rounded,            label: 'Accueil'),
    _NavItem(icon: Icons.search_outlined,          activeIcon: Icons.search_rounded,           label: 'Médecins'),
    _NavItem(icon: Icons.calendar_month_outlined,  activeIcon: Icons.calendar_month_rounded,  label: 'RDV'),
    _NavItem(icon: Icons.person_outline_rounded,   activeIcon: Icons.person_rounded,           label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();

    _tabControllers = List.generate(
      _items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
      ),
    );
    _tabControllers[0].value = 1.0;
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    for (final c in _tabControllers) c.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    _tabControllers[_currentIndex].reverse();
    _tabControllers[index].forward();
    setState(() => _currentIndex = index);
    _fabCtrl.reset();
    _fabCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      extendBody: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Stack(
        children: [
          if (isDark)
            Positioned.fill(
              child: Container(decoration: BoxDecoration(gradient: context.bgGradient)),
            ),
          IndexedStack(index: _currentIndex, children: _screens),
        ],
      ),

      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fabCtrl, curve: Curves.elasticOut),
        child: GestureDetector(
          onTap: () => _onTabTap(2),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF4D7FFF)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.88),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    // Accueil + Médecins
                    ...[0, 1].map((i) => Expanded(
                          child: _NavButton(
                            item: _items[i],
                            isActive: _currentIndex == i,
                            controller: _tabControllers[i],
                            onTap: () => _onTabTap(i),
                          ),
                        )),

                    // Espace FAB
                    const SizedBox(width: 64),

                    // RDV + Profil
                    ...[2, 3].map((i) => Expanded(
                          child: _NavButton(
                            item: _items[i],
                            isActive: _currentIndex == i,
                            controller: _tabControllers[i],
                            onTap: () => _onTabTap(i),
                            badge: i == 2 ? '2' : null,
                          ),
                        )),
                  ],
                ),
              ),
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
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final AnimationController controller;
  final VoidCallback onTap;
  final String? badge;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.controller,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: scaleAnim,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive ? context.primaryLightColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      size: 22,
                      color: isActive ? AppColors.primary : context.mutedText,
                    ),
                    if (badge != null)
                      Positioned(
                        top: -4,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : context.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
