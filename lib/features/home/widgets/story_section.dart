import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';

class StorySection extends ConsumerWidget {
  const StorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final profile = authState.profile;

    // Get user's display name from profile or email
    String displayName = 'You';
    if (profile != null) {
      // Try to get name from profile first
      final firstName = profile['first_name'] as String?;
      final lastName = profile['last_name'] as String?;
      if (firstName != null || lastName != null) {
        displayName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
      }
    } else if (user?.email != null) {
      // Fallback to email username part
      displayName = user!.email!.split('@').first;
    }

    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          // Add Your Story
          _buildAddStoryItem(displayName),
          SizedBox(width: 12.w),

          // Sample Stories (you can replace with real data)
          ..._buildSampleStories(),
        ],
      ),
    );
  }

  Widget _buildAddStoryItem(String name) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.person,
                  size: 30.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Your Story',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  List<Widget> _buildSampleStories() {
    final stories = [
      {'name': 'Alex', 'hasStory': true},
      {'name': 'Sarah', 'hasStory': true},
      {'name': 'Mike', 'hasStory': true},
      {'name': 'Emma', 'hasStory': true},
      {'name': 'John', 'hasStory': true},
    ];

    return stories.map((story) => Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: _buildStoryItem(story['name'] as String, story['hasStory'] as bool),
    )).toList();
  }

  Widget _buildStoryItem(String name, bool hasStory) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            gradient: hasStory
                ? LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: hasStory ? null : AppTheme.borderColor,
            borderRadius: BorderRadius.circular(30.r),
          ),
          padding: EdgeInsets.all(2.w),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
            ),
            child: Center(
              child: Icon(
                Icons.person,
                size: 30.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        SizedBox(
          width: 60.w,
          child: Text(
            name,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}