import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final profile = authState.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 40.r,
                  backgroundImage: profile?['profile_image_url'] != null
                      ? NetworkImage(profile!['profile_image_url'])
                      : null,
                  child: profile?['profile_image_url'] == null
                      ? Icon(Icons.person, size: 40.sp)
                      : null,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?['full_name'] ?? user.email ?? 'No Name',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textWhite,
                        ),
                      ),
                      if (profile?['username'] != null)
                        Text(
                          '@${profile!['username']}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Posts', '0'),
                _buildStatItem('Followers', '${profile?['followers_count'] ?? 0}'),
                _buildStatItem('Following', '${profile?['following_count'] ?? 0}'),
              ],
            ),

            SizedBox(height: 24.h),

            // Bio
            if (profile?['bio'] != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  profile!['bio'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textWhite,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to edit profile
                },
                child: const Text('Edit Profile'),
              ),
            ),

            SizedBox(height: 24.h),

            // Content Grid (placeholder)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 0, // No posts yet
                itemBuilder: (context, index) {
                  return Container(
                    color: AppTheme.borderColor,
                    child: const Icon(Icons.image),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textWhite,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
