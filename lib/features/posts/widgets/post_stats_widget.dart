import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class PostStatsWidget extends StatelessWidget {
  final int totalPosts;
  final int totalLikes;
  final int totalComments;

  const PostStatsWidget({
    super.key,
    required this.totalPosts,
    required this.totalLikes,
    required this.totalComments,
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.post_add,
            label: 'Posts',
            value: totalPosts,
            color: AppTheme.primaryYellow,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.favorite,
            label: 'Likes',
            value: totalLikes,
            color: AppTheme.accentRed,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.chat_bubble,
            label: 'Comments',
            value: totalComments,
            color: AppTheme.accentBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textWhite,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: AppTheme.textGray,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.w,
      height: 40.h,
      color: AppTheme.inputBorder.withOpacity(0.3),
    );
  }
}
