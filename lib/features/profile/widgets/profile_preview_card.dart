import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/profile_setup_provider.dart';

class ProfilePreviewCard extends ConsumerWidget {
  const ProfilePreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(profileSetupProvider);
    
    return Container(
      margin: EdgeInsets.all(16.w),
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
            children: [
              Icon(
                Icons.preview,
                color: AppTheme.primaryYellow,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Profile Preview',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20.h),
          
          // Profile Header
          Row(
            children: [
              // Profile Image
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: AppTheme.primaryYellow, width: 2),
                ),
                child: setupState.profileImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28.r),
                        child: setupState.profileImageFile != null
                            ? Image.file(
                                setupState.profileImageFile!,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                setupState.profileImagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      setupState.avatarLetter,
                                      style: TextStyle(
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryYellow,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      )
                    : Center(
                        child: Text(
                          setupState.avatarLetter,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryYellow,
                          ),
                        ),
                      ),
              ),
              
              SizedBox(width: 16.w),
              
              // Profile Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${setupState.personalInfo['first_name'] ?? 'First'} ${setupState.personalInfo['last_name'] ?? 'Last'}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    if (setupState.personalInfo['username']?.isNotEmpty == true) ...[
                      SizedBox(height: 2.h),
                      Text(
                        '@${setupState.personalInfo['username']}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                    ],
                    if (setupState.personalInfo['location']?.isNotEmpty == true) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14.sp,
                            color: AppTheme.textGray,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            setupState.personalInfo['location'],
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
            ],
          ),
          
          // Bio
          if (setupState.biography['bio']?.isNotEmpty == true) ...[
            SizedBox(height: 16.h),
            Text(
              setupState.biography['bio'],
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textWhite,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          // Interests & Skills
          if (setupState.selectedInterests.isNotEmpty || setupState.selectedSkills.isNotEmpty) ...[
            SizedBox(height: 16.h),
            
            // Interests
            if (setupState.selectedInterests.isNotEmpty) ...[
              Text(
                'Interests',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textGray,
                ),
              ),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: setupState.selectedInterests.take(3).map((interest) {
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
              ),
              if (setupState.selectedInterests.length > 3) ...[
                SizedBox(height: 4.h),
                Text(
                  '+${setupState.selectedInterests.length - 3} more',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ],
            
            // Skills
            if (setupState.selectedSkills.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                'Skills',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textGray,
                ),
              ),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: setupState.selectedSkills.take(3).map((skill) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.darkerBackground,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppTheme.inputBorder),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (setupState.selectedSkills.length > 3) ...[
                SizedBox(height: 4.h),
                Text(
                  '+${setupState.selectedSkills.length - 3} more',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ],
          ],
          
          // Social Links
          if (_hasSocialLinks(setupState)) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                if (setupState.biography['website']?.isNotEmpty == true)
                  _buildSocialIcon(Icons.language, AppTheme.textGray),
                if (setupState.biography['github']?.isNotEmpty == true) ...[
                  SizedBox(width: 8.w),
                  _buildSocialIcon(Icons.code, AppTheme.textGray),
                ],
                if (setupState.biography['linkedin']?.isNotEmpty == true) ...[
                  SizedBox(width: 8.w),
                  _buildSocialIcon(Icons.business, AppTheme.textGray),
                ],
                if (setupState.biography['twitter']?.isNotEmpty == true) ...[
                  SizedBox(width: 8.w),
                  _buildSocialIcon(Icons.alternate_email, AppTheme.textGray),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool _hasSocialLinks(ProfileSetupState setupState) {
    return setupState.biography['website']?.isNotEmpty == true ||
           setupState.biography['github']?.isNotEmpty == true ||
           setupState.biography['linkedin']?.isNotEmpty == true ||
           setupState.biography['twitter']?.isNotEmpty == true;
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      width: 24.w,
      height: 24.h,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        icon,
        size: 14.sp,
        color: color,
      ),
    );
  }
}
