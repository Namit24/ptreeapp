import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'home_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../posts/screens/create_post_screen.dart';
import '../../messages/screens/messages_screen.dart';
import '../../profile/screens/my_profile_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late List<AnimationController> _iconControllers;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const CreatePostScreen(),
    const MessagesScreen(),
    const MyProfileScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(Icons.home_filled, Icons.home_outlined, 'Home'),
    NavItem(Icons.search, Icons.search_outlined, 'Search'),
    NavItem(Icons.add_circle, Icons.add_circle_outline, 'Create'),
    NavItem(Icons.chat_bubble, Icons.chat_bubble_outline, 'Messages'),
    NavItem(Icons.person, Icons.person_outline, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _iconControllers = List.generate(
      5,
          (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    // Animate the initial selected tab
    _iconControllers[0].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      // Animate out current tab
      _iconControllers[_currentIndex].reverse();
      // Animate in new tab
      _iconControllers[index].forward();

      setState(() => _currentIndex = index);

      // Smooth page transition
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (_currentIndex != index) {
            _iconControllers[_currentIndex].reverse();
            _iconControllers[index].forward();
            setState(() => _currentIndex = index);
          }
        },
        children: _screens,
      ),
      // FIXED: Modern dark navbar with proper sizing
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkerBackground,
              AppTheme.darkBackground,
            ],
          ),
          border: Border(
            top: BorderSide(
              color: AppTheme.inputBorder,
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60.h, // FIXED: Reduced height to prevent overflow
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h), // FIXED: Reduced padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;

                return _buildNavItem(item, index, isSelected);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItem item, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedBuilder(
        animation: _iconControllers[index],
        builder: (context, child) {
          final animationValue = _iconControllers[index].value;

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w, // FIXED: Reduced padding
              vertical: 6.h,    // FIXED: Reduced padding
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryYellow.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16.r), // FIXED: Smaller radius
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Special handling for create button
                if (index == 2)
                  _buildCreateButton(isSelected, animationValue)
                else
                  Transform.scale(
                    scale: 1.0 + (animationValue * 0.1),
                    child: Icon(
                      isSelected ? item.activeIcon : item.inactiveIcon,
                      size: 22.sp, // FIXED: Smaller icon size
                      color: isSelected
                          ? AppTheme.primaryYellow
                          : AppTheme.textGray,
                    ),
                  ),

                SizedBox(height: 2.h), // FIXED: Smaller spacing

                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.poppins(
                    fontSize: isSelected ? 10.sp : 9.sp, // FIXED: Smaller font
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppTheme.primaryYellow
                        : AppTheme.textGray,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ).animate(target: isSelected ? 1 : 0)
              .shimmer(
            duration: const Duration(milliseconds: 300),
            color: AppTheme.primaryYellow.withOpacity(0.3),
          );
        },
      ),
    );
  }

  Widget _buildCreateButton(bool isSelected, double animationValue) {
    return Container(
      width: 28.w, // FIXED: Smaller size
      height: 28.h, // FIXED: Smaller size
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryYellow,
            AppTheme.primaryYellow.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r), // FIXED: Smaller radius
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryYellow.withOpacity(0.4),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Transform.scale(
        scale: 1.0 + (animationValue * 0.1),
        child: Icon(
          Icons.add_rounded,
          color: AppTheme.darkBackground,
          size: 18.sp, // FIXED: Smaller icon
        ),
      ),
    );
  }
}

class NavItem {
  final IconData inactiveIcon;
  final IconData activeIcon;
  final String label;

  NavItem(this.inactiveIcon, this.activeIcon, this.label);
}
