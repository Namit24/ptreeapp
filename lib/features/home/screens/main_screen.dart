import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import 'home_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../profile/screens/my_profile_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  final String location;

  const MainScreen({
    super.key,
    required this.location,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const MyProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _updateSelectedIndex();
    }
  }

  void _updateSelectedIndex() {
    switch (widget.location) {
      case '/home':
        _selectedIndex = 0;
        break;
      case '/search':
        _selectedIndex = 1;
        break;
      case '/profile':
        _selectedIndex = 2;
        break;
      default:
        _selectedIndex = 0;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 70, // Fixed height
        decoration: BoxDecoration(
          color: AppTheme.primaryWhite,
          border: Border(
            top: BorderSide(
              color: AppTheme.lightGray,
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home_filled,
              label: 'Home',
              index: 0,
              isSelected: _selectedIndex == 0,
            ),
            _buildNavItem(
              icon: Icons.search,
              label: 'Search',
              index: 1,
              isSelected: _selectedIndex == 1,
            ),
            _buildNavItem(
              icon: Icons.person,
              label: 'Profile',
              index: 2,
              isSelected: _selectedIndex == 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryYellow : AppTheme.neutralGray,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryYellow : AppTheme.neutralGray,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
