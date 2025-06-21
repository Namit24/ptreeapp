import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../../../core/models/post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    this.isOwner = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.darkerBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.inputBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and actions
          Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
                child: post.userProfileImage != null
                    ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: post.userProfileImage!,
                    width: 40.w,
                    height: 40.h,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
                  ),
                )
                    : _buildAvatarPlaceholder(),
              ),

              SizedBox(width: 12.w),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userFullName ?? 'Unknown User',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textWhite,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '@${post.userUsername ?? 'unknown'}',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textGray,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Time and actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeago.format(post.createdAt),
                    style: GoogleFonts.poppins(
                      color: AppTheme.textGray,
                      fontSize: 12.sp,
                    ),
                  ),

                  if (isOwner) ...[
                    SizedBox(height: 4.h),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppTheme.textGray,
                        size: 20.sp,
                      ),
                      color: AppTheme.darkerBackground,
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: AppTheme.textWhite, size: 16.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Edit',
                                style: GoogleFonts.poppins(color: AppTheme.textWhite),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: AppTheme.accentRed, size: 16.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'Delete',
                                style: GoogleFonts.poppins(color: AppTheme.accentRed),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Post content
          Text(
            post.content,
            style: GoogleFonts.poppins(
              color: AppTheme.textWhite,
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),

          // Post image
          if (post.imageUrl != null) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: post.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200.h,
                  color: AppTheme.inputBackground,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryYellow,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200.h,
                  color: AppTheme.inputBackground,
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      color: AppTheme.textGray,
                      size: 48.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],

          SizedBox(height: 12.h),

          // Action buttons
          Row(
            children: [
              _buildActionButton(
                icon: Icons.favorite_border,
                count: post.likesCount,
                onTap: () {
                  // TODO: Implement like functionality
                },
              ),

              SizedBox(width: 24.w),

              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                count: post.commentsCount,
                onTap: () {
                  // TODO: Implement comment functionality
                },
              ),

              const Spacer(),

              IconButton(
                onPressed: () {
                  // TODO: Implement share functionality
                },
                icon: Icon(
                  Icons.share_outlined,
                  color: AppTheme.textGray,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    final name = post.userFullName ?? 'U';
    final letter = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';

    return Text(
      letter,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryYellow,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.textGray,
            size: 20.sp,
          ),
          if (count > 0) ...[
            SizedBox(width: 4.w),
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                color: AppTheme.textGray,
                fontSize: 12.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
