// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:learning_tracker/Screens/courseScreen.dart';
import 'package:learning_tracker/Screens/dashBoard.dart';
import 'package:learning_tracker/Screens/profileScreen.dart';
import 'package:learning_tracker/Screens/sessionScreen.dart';
import 'package:learning_tracker/constants/appTheme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _pages = [
    DashboardPage(),
    CoursesPage(),
    StudySessionPage(),
    ProfilePage(),
  ];

  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      color: AppColors.primary,
    ),
    _NavigationItem(
      icon: Icons.book_outlined,
      activeIcon: Icons.book,
      label: 'Courses',
      color: AppColors.secondary,
    ),
    _NavigationItem(
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer,
      label: 'Study',
      color: AppColors.accent,
    ),
    _NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      color: AppColors.success,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });

      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navigationItems.length,
                (index) => _buildNavItem(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navigationItems[index];
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? AppSpacing.lg : AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? item.color.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(isSelected ? AppSpacing.xs : 0),
              decoration: BoxDecoration(
                color: isSelected ? item.color : Colors.transparent,
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color:
                    isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textTertiary,
                size: 22,
              ),
            ),

            // Animated label
            AnimatedSize(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child:
                  isSelected
                      ? Container(
                        margin: EdgeInsets.only(left: AppSpacing.sm),
                        child: Text(
                          item.label,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: item.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class for navigation items
class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
