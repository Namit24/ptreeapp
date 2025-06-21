import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
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
      _iconControllers[_currentIndex].reverse();
      _iconControllers[index].forward();

      setState(() => _currentIndex = index);

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
      // COMPLETELY SAFE BOTTOM NAVIGATION - NO RESPONSIVE SIZING
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
          child: SizedBox(
            height: 80, // FIXED: Use fixed double, not .h
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // FIXED: Use fixed EdgeInsets
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = _currentIndex == index;

                  return Expanded( // FIXED: Use Expanded instead of Flexible
                    child: _buildNavItem(item, index, isSelected),
                  );
                }).toList(),
              ),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // FIXED: Use fixed EdgeInsets
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryYellow.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Special handling for create button
                if (index == 2)
                  _buildCreateButton(isSelected, animationValue)
                else
                  Transform.scale(
                    scale: 1.0 + (animationValue * 0.1),
                    child: Icon(
                      isSelected ? item.activeIcon : item.inactiveIcon,
                      size: 24, // FIXED: Use fixed double, not .sp
                      color: isSelected
                          ? AppTheme.primaryYellow
                          : AppTheme.textGray,
                    ),
                  ),

                const SizedBox(height: 4), // FIXED: Use fixed SizedBox

                // COMPLETELY SAFE TEXT STYLE - NO RESPONSIVE SIZING
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.poppins(
                    fontSize: isSelected ? 12.0 : 11.0, // FIXED: Use fixed double values
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppTheme.primaryYellow
                        : AppTheme.textGray,
                  ),
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
      width: 32, // FIXED: Use fixed double, not .w
      height: 32, // FIXED: Use fixed double, not .h
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryYellow,
            AppTheme.primaryYellow.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
          size: 20, // FIXED: Use fixed double, not .sp
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
