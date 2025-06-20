import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../widgets/follow_button.dart';
import '../providers/follow_provider.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final loadedUsers = await SupabaseService.getAllUsers();

      // Check follow status for each user
      for (final user in loadedUsers) {
        await ref.read(followProvider.notifier).checkFollowStatus(user['id']);

        // Update follower counts
        ref.read(followProvider.notifier).updateFollowerCount(
          user['id'],
          user['followers_count'] ?? 0,
        );
        ref.read(followProvider.notifier).updateFollowingCount(
          user['id'],
          user['following_count'] ?? 0,
        );
      }

      setState(() {
        users = loadedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkerBackground,
        title: Text(
          'Discover Students',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.textWhite),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryYellow,
        ),
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
              'Failed to load users',
              style: TextStyle(
                fontSize: 18.sp,
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error!,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textGray,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: _loadUsers,
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

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64.sp,
              color: AppTheme.textGray,
            ),
            SizedBox(height: 16.h),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 18.sp,
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Be the first to complete your profile!',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textGray,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: AppTheme.primaryYellow,
      backgroundColor: AppTheme.darkerBackground,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final followState = ref.watch(followProvider);
    final isFollowing = followState.followingStatus[user['id']] ?? false;
    final followerCount = followState.followerCounts[user['id']] ?? user['followers_count'] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.darkerBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile Image
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(color: AppTheme.primaryYellow, width: 2),
                ),
                child: user['profile_image_url'] != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(23.r),
                  child: Image.network(
                    user['profile_image_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildAvatarPlaceholder(user['first_name'] ?? 'U');
                    },
                  ),
                )
                    : _buildAvatarPlaceholder(user['first_name'] ?? 'U'),
              ),

              SizedBox(width: 12.w),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['full_name'] ?? 'Unknown User',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '@${user['username'] ?? 'unknown'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textGray,
                      ),
                    ),
                    if (user['location']?.isNotEmpty == true) ...[
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12.sp,
                            color: AppTheme.textGray,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            user['location'],
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppTheme.textGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Follow Button
              FollowButton(
                userId: user['id'],
                isFollowing: isFollowing,
              ),
            ],
          ),

          // Bio
          if (user['bio']?.isNotEmpty == true) ...[
            SizedBox(height: 12.h),
            Text(
              user['bio'],
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textWhite,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Interests and Skills
          if ((user['interests'] as List?)?.isNotEmpty == true ||
              (user['skills'] as List?)?.isNotEmpty == true) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                // Show first 3 interests
                ...((user['interests'] as List?) ?? []).take(3).map((interest) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.3)),
                    ),
                    child: Text(
                      interest,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppTheme.primaryYellow,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),

                // Show first 2 skills
                ...((user['skills'] as List?) ?? []).take(2).map((skill) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.inputBackground,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.inputBorder),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppTheme.textGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ],

          // Stats
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildStatItem('Followers', followerCount),
              SizedBox(width: 16.w),
              _buildStatItem('Following', user['following_count'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    final letter = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';
    return Center(
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryYellow,
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
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
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
