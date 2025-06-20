import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';

class InterestSkillChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showRemove;

  const InterestSkillChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showRemove = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: showRemove ? 12.w : 16.w, 
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryYellow 
              : AppTheme.inputBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryYellow 
                : AppTheme.inputBorder,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.primaryYellow.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: isSelected 
                    ? AppTheme.darkBackground 
                    : AppTheme.textWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showRemove && isSelected) ...[
              SizedBox(width: 6.w),
              Icon(
                Icons.close,
                size: 16.sp,
                color: AppTheme.darkBackground,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
