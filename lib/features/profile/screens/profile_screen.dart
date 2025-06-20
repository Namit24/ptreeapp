import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../widgets/follow_button.dart';
import '../providers/follow_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final profile = await SupabaseService.getProfile(widget.userId);

      if (profile != null) {
        // Load follow status and counts
        await ref.read(followProvider.notifier).checkFollowStatus(widget.userId);
        await ref.read(followProvider.notifier).loadUserCounts(widget.userId);

        setState(() {
          userProfile = profile;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Profile not found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshProfile() async {
    // Don't show loading indicator for refresh
    try {
      final profile = await SupabaseService.getProfile(widget.userId);

      if (profile != null) {
        // Refresh follow status and counts
        await ref.read(followProvider.notifier).checkFollowStatus(widget.userId);
        await ref.read(followProvider.notifier).loadUserCounts(widget.userId);

        setState(() {
          userProfile = profile;
        });
      }
    } catch (e) {
      // Show error but don't change loading state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkerBackground,
        elevation: 0,
        title: Text(
          userProfile?['username'] ?? 'Profile',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.textWhite),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProfile,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show options menu
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppTheme.primaryYellow),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: AppTheme.textGray,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error loading profile',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error!,
              style: TextStyle(
                color: AppTheme.textGray,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: AppTheme.darkBackground,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (userProfile == null) {
      return Center(
        child: Text(
          'Profile not found',
          style: TextStyle(
            color: AppTheme.textGray,
            fontSize: 16.sp,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProfile,
      color: AppTheme.primaryYellow,
      backgroundColor: AppTheme.darkerBackground,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: _buildProfileContent(),
      ),
    );
  }

  Widget _buildProfileContent() {
    final followState = ref.watch(followProvider);
    final isFollowing = followState.followingStatus[widget.userId] ?? false;
    final followerCount = followState.followerCounts[widget.userId] ?? userProfile!['followers_count'] ?? 0;
    final followingCount = followState.followingCounts[widget.userId] ?? userProfile!['following_count'] ?? 0;

    return Column(
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
                child: userProfile!['profile_image_url'] != null
                    ? CachedNetworkImage(
                  imageUrl: userProfile!['profile_image_url'],
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
                    userProfile!['full_name'] ?? 'Unknown User',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textWhite,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '@${userProfile!['username'] ?? 'unknown'}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.primaryYellow,
                    ),
                  ),
                  if (userProfile!['location']?.isNotEmpty == true) ...[
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
                          userProfile!['location'],
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

        // Follow Button
        FollowButton(
          userId: widget.userId,
          isFollowing: isFollowing,
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
        if (userProfile!['bio']?.isNotEmpty == true) ...[
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
            userProfile!['bio'],
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textWhite,
              height: 1.5,
            ),
          ),
        ],

        // Interests
        if ((userProfile!['interests'] as List?)?.isNotEmpty == true) ...[
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
            children: (userProfile!['interests'] as List).map((interest) {
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
        if ((userProfile!['skills'] as List?)?.isNotEmpty == true) ...[
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
            children: (userProfile!['skills'] as List).map((skill) {
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
      ],
    );
  }

  Widget _buildAvatarPlaceholder() {
    final name = userProfile?['full_name'] ?? userProfile?['first_name'] ?? 'U';
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
