import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'home_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../projects/screens/create_project_screen.dart';
import '../../messages/screens/messages_screen.dart';
import '../../profile/screens/my_profile_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const CreateProjectScreen(),
    const MessagesScreen(),
    const MyProfileScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(Icons.home_outlined, Icons.home, 'Home'),
    NavItem(Icons.search_outlined, Icons.search, 'Explore'),
    NavItem(Icons.add_circle_outline, Icons.add_circle, 'Create'),
    NavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 'Messages'),
    NavItem(Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryWhite,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
    );
  }

  Widget _buildNavItem(NavItem item, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryYellow.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.activeIcon : item.inactiveIcon,
                key: ValueKey(isSelected),
                size: 24.sp,
                color: isSelected ? AppTheme.primaryYellow : AppTheme.neutralGray,
              ),
            ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(0.8, 0.8)),
            
            SizedBox(height: 4.h),
            
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? AppTheme.primaryYellow : AppTheme.neutralGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class NavItem {
  final IconData inactiveIcon;
  final IconData activeIcon;
  final String label;

  NavItem(this.inactiveIcon, this.activeIcon, this.label);
}
