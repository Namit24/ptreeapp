import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final profile = authState.profile;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryYellow),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: AppTheme.primaryYellow),
            onPressed: () {
              // Navigate to edit profile
              // TODO: Implement edit profile screen
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: AppTheme.textGray),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: profile == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryYellow),
            SizedBox(height: 16.h),
            Text(
              'Loading profile...',
              style: TextStyle(
                color: AppTheme.textGray,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(profile),

            SizedBox(height: 24.h),

            // Stats Row
            _buildStatsRow(profile),

            SizedBox(height: 24.h),

            // Bio Section
            if (profile['bio']?.isNotEmpty == true) ...[
              _buildBioSection(profile['bio']),
              SizedBox(height: 24.h),
            ],

            // Interests Section
            if (profile['interests'] != null && (profile['interests'] as List).isNotEmpty) ...[
              _buildInterestsSection(List<String>.from(profile['interests'])),
              SizedBox(height: 24.h),
            ],

            // Skills Section
            if (profile['skills'] != null && (profile['skills'] as List).isNotEmpty) ...[
              _buildSkillsSection(List<String>.from(profile['skills'])),
              SizedBox(height: 24.h),
            ],

            // Social Links Section
            if (_hasSocialLinks(profile)) ...[
              _buildSocialLinksSection(profile),
              SizedBox(height: 24.h),
            ],

            // Additional Info Section
            _buildAdditionalInfoSection(profile),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> profile) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Row(
        children: [
          // Profile Image
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.r),
              border: Border.all(color: AppTheme.primaryYellow, width: 3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(37.r),
              child: profile['profile_image_url'] != null
                  ? CachedNetworkImage(
                imageUrl: profile['profile_image_url'],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.primaryYellow.withOpacity(0.2),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryYellow,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildAvatarPlaceholder(profile),
              )
                  : _buildAvatarPlaceholder(profile),
            ),
          ),

          SizedBox(width: 16.w),

          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile['full_name'] ?? 'No Name',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textWhite,
                  ),
                ),
                if (profile['username'] != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '@${profile['username']}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.primaryYellow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (profile['location']?.isNotEmpty == true) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16.sp,
                        color: AppTheme.textGray,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        profile['location'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                ],
                if (profile['college']?.isNotEmpty == true) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 16.sp,
                        color: AppTheme.textGray,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        profile['college'],
                        style: TextStyle(
                          fontSize: 14.sp,
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
    );
  }

  Widget _buildAvatarPlaceholder(Map<String, dynamic> profile) {
    final firstName = profile['first_name'] ?? profile['full_name'] ?? 'U';
    final letter = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';

    return Container(
      color: AppTheme.primaryYellow.withOpacity(0.2),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryYellow,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> profile) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Projects',
            '0', // TODO: Get actual project count
            Icons.lightbulb_outline,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'Followers',
            '${profile['followers_count'] ?? 0}',
            Icons.people_outline,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'Following',
            '${profile['following_count'] ?? 0}',
            Icons.person_add_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryYellow,
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            count,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
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
      ),
    );
  }

  Widget _buildBioSection(String bio) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppTheme.primaryYellow,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'About Me',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            bio,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textWhite,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(List<String> interests) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_outline,
                color: AppTheme.primaryYellow,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Interests',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: interests.map((interest) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.3)),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.primaryYellow,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(List<String> skills) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code_outlined,
                color: AppTheme.primaryYellow,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Skills',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: skills.map((skill) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppTheme.darkerBackground,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppTheme.inputBorder),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinksSection(Map<String, dynamic> profile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link_outlined,
                color: AppTheme.primaryYellow,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Social Links',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Column(
            children: [
              if (profile['website']?.isNotEmpty == true)
                _buildSocialLinkItem(
                  Icons.language,
                  'Website',
                  profile['website'],
                  profile['website'],
                ),
              if (profile['github']?.isNotEmpty == true)
                _buildSocialLinkItem(
                  Icons.code,
                  'GitHub',
                  profile['github'],
                  'https://github.com/${profile['github'].replaceAll('github.com/', '').replaceAll('https://', '').replaceAll('http://', '')}',
                ),
              if (profile['linkedin']?.isNotEmpty == true)
                _buildSocialLinkItem(
                  Icons.business,
                  'LinkedIn',
                  profile['linkedin'],
                  'https://linkedin.com/in/${profile['linkedin'].replaceAll('linkedin.com/in/', '').replaceAll('https://', '').replaceAll('http://', '')}',
                ),
              if (profile['twitter']?.isNotEmpty == true)
                _buildSocialLinkItem(
                  Icons.alternate_email,
                  'Twitter',
                  profile['twitter'],
                  'https://twitter.com/${profile['twitter'].replaceAll('twitter.com/', '').replaceAll('@', '').replaceAll('https://', '').replaceAll('http://', '')}',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinkItem(IconData icon, String label, String displayText, String url) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: () => _launchURL(url),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryYellow,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textGray,
                    ),
                  ),
                  Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: AppTheme.textGray,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(Map<String, dynamic> profile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.inputBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryYellow,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Additional Info',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (profile['course']?.isNotEmpty == true)
            _buildInfoItem('Course', profile['course']),
          if (profile['year'] != null)
            _buildInfoItem('Year', 'Year ${profile['year']}'),
          _buildInfoItem('Member Since', _formatDate(profile['created_at'])),
          _buildInfoItem('Profile Completed', profile['profile_completed'] == true ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasSocialLinks(Map<String, dynamic> profile) {
    return profile['website']?.isNotEmpty == true ||
        profile['github']?.isNotEmpty == true ||
        profile['linkedin']?.isNotEmpty == true ||
        profile['twitter']?.isNotEmpty == true;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.inputBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Sign Out',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            color: AppTheme.textGray,
            fontSize: 16.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textGray,
                fontSize: 16.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
