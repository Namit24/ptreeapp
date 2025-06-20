import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/follow_provider.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      // Load current user's follow counts
      await ref.read(followProvider.notifier).loadUserCounts(authState.user!.id);
    }
  }

  Future<void> _refreshProfile() async {
    await ref.read(authProvider.notifier).refreshProfile();
    await _loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final followState = ref.watch(followProvider);

    if (authState.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryYellow),
        ),
      );
    }

    if (authState.user == null) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please log in to view your profile',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryYellow,
                  foregroundColor: AppTheme.darkBackground,
                ),
                child: Text('Log In'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = authState.profile;
    final userId = authState.user!.id;

    // Get real-time counts from follow provider
    final followerCount = followState.followerCounts[userId] ?? profile?['followers_count'] ?? 0;
    final followingCount = followState.followingCounts[userId] ?? profile?['following_count'] ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkerBackground,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppTheme.primaryYellow),
            onPressed: () => context.push('/edit-profile'),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: AppTheme.textWhite),
            onPressed: () {
              // Show settings menu
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: AppTheme.primaryYellow,
        backgroundColor: AppTheme.darkerBackground,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Row(
                children: [
                  // Profile Image
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.r),
                      border: Border.all(color: AppTheme.primaryYellow, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(37.r),
                      child: profile?['profile_image_url'] != null
                          ? CachedNetworkImage(
                        imageUrl: profile!['profile_image_url'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.primaryYellow.withOpacity(0.2),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryYellow,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
                      )
                          : _buildAvatarPlaceholder(),
                    ),
                  ),

                  SizedBox(width: 20.w),

                  // Profile Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?['full_name'] ?? 'Your Name',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textWhite,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '@${profile?['username'] ?? 'username'}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppTheme.primaryYellow,
                          ),
                        ),
                        if (profile?['location']?.isNotEmpty == true) ...[
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16.sp,
                                color: AppTheme.textGray,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                profile!['location'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppTheme.textGray,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push('/edit-profile'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryYellow),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: AppTheme.primaryYellow,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Stats - Show real-time counts
              Row(
                children: [
                  _buildStatItem('Followers', followerCount),
                  SizedBox(width: 32.w),
                  _buildStatItem('Following', followingCount),
                ],
              ),

              // Bio
              if (profile?['bio']?.isNotEmpty == true) ...[
                SizedBox(height: 20.h),
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  profile!['bio'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textWhite,
                    height: 1.5,
                  ),
                ),
              ],

              // Interests
              if ((profile?['interests'] as List?)?.isNotEmpty == true) ...[
                SizedBox(height: 20.h),
                Text(
                  'Interests',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite,
                  ),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: (profile!['interests'] as List).map((interest) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.3)),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.primaryYellow,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Skills
              if ((profile?['skills'] as List?)?.isNotEmpty == true) ...[
                SizedBox(height: 20.h),
                Text(
                  'Skills',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite,
                  ),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: (profile!['skills'] as List).map((skill) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppTheme.inputBackground,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppTheme.inputBorder),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              SizedBox(height: 40.h),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (mounted) {
                      context.go('/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;
    final name = profile?['full_name'] ?? profile?['first_name'] ?? 'U';
    final letter = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';

    return Container(
      color: AppTheme.primaryYellow.withOpacity(0.2),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryYellow,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textWhite,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.textGray,
          ),
        ),
      ],
    );
  }
}
