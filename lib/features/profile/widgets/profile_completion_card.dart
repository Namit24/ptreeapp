import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';

class ProfileCompletionCard extends StatelessWidget {
  final int completionPercentage;
  final int currentStep;

  const ProfileCompletionCard({
    super.key,
    required this.completionPercentage,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inputBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Completion',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$completionPercentage%',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryYellow,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Progress Bar
          Container(
            height: 8.h,
            decoration: BoxDecoration(
              color: AppTheme.darkerBackground,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: completionPercentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryYellow,
                      AppTheme.primaryYellow.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Completion Items
          ..._buildCompletionItems(),
        ],
      ),
    );
  }

  List<Widget> _buildCompletionItems() {
    final items = [
      {
        'label': 'Basic Info', 
        'completed': currentStep >= 1,
        'icon': Icons.person_outline,
      },
      {
        'label': 'Profile Photo', 
        'completed': currentStep >= 2,
        'icon': Icons.photo_camera_outlined,
      },
      {
        'label': 'Interests & Skills', 
        'completed': currentStep >= 4,
        'icon': Icons.interests_outlined,
      },
      {
        'label': 'Biography', 
        'completed': currentStep >= 5,
        'icon': Icons.description_outlined,
      },
    ];
    
    return items.map((item) {
      final isCompleted = item['completed'] as bool;
      
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? AppTheme.primaryYellow.withOpacity(0.2)
                    : AppTheme.darkerBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                isCompleted ? Icons.check : (item['icon'] as IconData),
                size: 14.sp,
                color: isCompleted 
                    ? AppTheme.primaryYellow 
                    : AppTheme.textGray,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                item['label'] as String,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isCompleted 
                      ? AppTheme.textWhite 
                      : AppTheme.textGray,
                  fontWeight: isCompleted 
                      ? FontWeight.w500 
                      : FontWeight.w400,
                ),
              ),
            ),
            Text(
              isCompleted ? 'Complete' : 'Pending',
              style: TextStyle(
                fontSize: 12.sp,
                color: isCompleted 
                    ? AppTheme.primaryYellow 
                    : AppTheme.textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
