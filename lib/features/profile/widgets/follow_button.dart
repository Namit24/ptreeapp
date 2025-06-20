import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/follow_provider.dart';

class FollowButton extends ConsumerWidget {
  final String userId;
  final bool isFollowing;
  final VoidCallback? onPressed;

  const FollowButton({
    super.key,
    required this.userId,
    required this.isFollowing,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followState = ref.watch(followProvider);
    final currentlyFollowing = followState.followingStatus[userId] ?? isFollowing;

    return SizedBox(
      height: 36.h,
      child: ElevatedButton(
        onPressed: () {
          ref.read(followProvider.notifier).toggleFollow(userId);
          onPressed?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: currentlyFollowing
              ? AppTheme.inputBackground
              : AppTheme.primaryYellow,
          foregroundColor: currentlyFollowing
              ? AppTheme.textWhite
              : AppTheme.darkBackground,
          side: currentlyFollowing
              ? BorderSide(color: AppTheme.inputBorder)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        child: Text(
          currentlyFollowing ? 'Following' : 'Follow',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
