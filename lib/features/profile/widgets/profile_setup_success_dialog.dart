import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ProfileSetupSuccessDialog extends StatelessWidget {
  final VoidCallback? onContinue;

  const ProfileSetupSuccessDialog({
    super.key,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppTheme.inputBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Icon(
                Icons.check_circle,
                color: AppTheme.primaryYellow,
                size: 50.sp,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Title
            Text(
              'Profile Complete! 🎉',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textWhite,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 12.h),
            
            // Description
            Text(
              'Welcome to ProjecTree! Your profile is now complete and you can start connecting with other students.',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppTheme.textGray,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.h),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to profile to see the completed profile
                      context.go('/home');
                      // Then navigate to profile tab
                      // Note: You might need to implement tab navigation here
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.inputBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text(
                      'View Profile',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (onContinue != null) {
                        onContinue!();
                      } else {
                        // Force navigation to home
                        context.go('/home');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      foregroundColor: AppTheme.darkBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
