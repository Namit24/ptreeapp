import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;
  final Function(int)? onStepTap;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Step circles and connectors
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;
            
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onStepTap != null ? () => onStepTap!(index) : null,
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? AppTheme.primaryYellow 
                              : isCurrent 
                                  ? AppTheme.primaryYellow 
                                  : AppTheme.inputBackground,
                          borderRadius: BorderRadius.circular(20.r),
                          border: isCurrent && !isCompleted
                              ? Border.all(color: AppTheme.primaryYellow, width: 2)
                              : null,
                          boxShadow: isCurrent ? [
                            BoxShadow(
                              color: AppTheme.primaryYellow.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(
                                  Icons.check,
                                  color: AppTheme.darkBackground,
                                  size: 20.sp,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isCurrent 
                                        ? AppTheme.darkBackground 
                                        : AppTheme.textGray,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16.sp,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  if (index < totalSteps - 1)
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 2.h,
                        color: index < currentStep 
                            ? AppTheme.primaryYellow 
                            : AppTheme.inputBorder,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        
        SizedBox(height: 12.h),
        
        // Step labels
        Row(
          children: stepLabels.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isActive = index == currentStep;
            final isCompleted = index < currentStep;
            
            return Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isCompleted 
                      ? AppTheme.primaryYellow
                      : isActive 
                          ? AppTheme.primaryYellow 
                          : AppTheme.textGray,
                  fontWeight: isActive || isCompleted 
                      ? FontWeight.w600 
                      : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
