import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class QuickPostWidget extends StatelessWidget {
  final String? userProfileImage;
  final String userName;

  const QuickPostWidget({
    super.key,
    this.userProfileImage,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.darkerBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.inputBorder.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
            backgroundImage: userProfileImage != null
                ? NetworkImage(userProfileImage!)
                : null,
            child: userProfileImage == null
                ? Text(
                    userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U',
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryYellow,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          
          SizedBox(width: 12.w),
          
          // Quick post input
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/create-post'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppTheme.inputBackground,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppTheme.inputBorder),
                ),
                child: Text(
                  "What's on your mind?",
                  style: GoogleFonts.poppins(
                    color: AppTheme.textGray,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // Quick actions
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/create-post'),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    color: AppTheme.primaryYellow,
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => context.push('/create-post'),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppTheme.accentGreen,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
