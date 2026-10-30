import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'control_screen.dart';
import 'guide_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ControlScreen(),
    GuideScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navBg = isDark ? const Color(0xFF141422) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF222236)
        : const Color(0xFFE5E7EB);
    final activeColor = AppColors.primary;
    final inactiveColor =
        isDark ? const Color(0xFF8888A0) : const Color(0xFF94A3B8);

    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(color: borderColor, width: 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDockItem(
                  index: 0,
                  label: 'Devices',
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  isSelected: _currentIndex == 0,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildDockItem(
                  index: 1,
                  label: 'Instructions',
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book_rounded,
                  isSelected: _currentIndex == 1,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildDockItem(
                  index: 2,
                  label: 'Profile',
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  isSelected: _currentIndex == 2,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required bool isSelected,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        splashColor: activeColor.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
