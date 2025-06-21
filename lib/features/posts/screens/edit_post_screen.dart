import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/post_model.dart';
import '../providers/user_posts_provider.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final Post post;

  const EditPostScreen({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  late TextEditingController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updatePost() async {
    final content = _contentController.text.trim();
    
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post content cannot be empty'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    if (content == widget.post.content) {
      // No changes made
      context.pop();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref.read(userPostsProvider.notifier).updatePost(
        widget.post.id,
        content,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post updated successfully!'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update post'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } catch (e) {
      print('❌ Error updating post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update post: ${e.toString()}'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkerBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.close,
            color: AppTheme.textWhite,
            size: 24.sp,
          ),
        ),
        title: Text(
          'Edit Post',
          style: GoogleFonts.poppins(
            color: AppTheme.textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updatePost,
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryYellow,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryYellow,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
                  child: widget.post.userProfileImage != null
                      ? ClipOval(
                          child: Image.network(
                            widget.post.userProfileImage!,
                            width: 40.w,
                            height: 40.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
                          ),
                        )
                      : _buildAvatarPlaceholder(),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.userFullName ?? 'Your Name',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textWhite,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '@${widget.post.userUsername ?? 'username'}',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textGray,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Content input
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: 120.h,
                maxHeight: 300.h,
              ),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.inputBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppTheme.inputBorder,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                autofocus: true,
                style: GoogleFonts.poppins(
                  color: AppTheme.textWhite,
                  fontSize: 16.sp,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: "Edit your post...",
                  hintStyle: GoogleFonts.poppins(
                    color: AppTheme.textGray,
                    fontSize: 16.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            // Show image if exists (read-only for now)
            if (widget.post.imageUrl != null) ...[
              SizedBox(height: 20.h),
              Text(
                'Image (cannot be edited)',
                style: GoogleFonts.poppins(
                  color: AppTheme.textGray,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                height: 200.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppTheme.inputBorder,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11.r),
                  child: Image.network(
                    widget.post.imageUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
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
              ),
            ],

            SizedBox(height: 20.h),

            // Edit guidelines
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppTheme.primaryYellow.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: AppTheme.primaryYellow,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Editing Guidelines',
                        style: GoogleFonts.poppins(
                          color: AppTheme.primaryYellow,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '• Only text content can be edited\n• Images cannot be changed after posting\n• Keep your edits respectful and relevant\n• Changes will be visible to all users',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textGray,
                      fontSize: 12.sp,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    final name = widget.post.userFullName ?? 'U';
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
}
