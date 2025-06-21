import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/post_model.dart';
import '../providers/post_likes_provider.dart';
import '../screens/comments_screen.dart';

class PostCard extends ConsumerStatefulWidget {
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
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> with TickerProviderStateMixin {
  late AnimationController _likeController;
  late AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Load likes for this post
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postLikesProvider.notifier).loadPostLikes([widget.post.id]);
    });
  }

  @override
  void dispose() {
    _likeController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  Future<void> _handleLike() async {
    final success = await ref.read(postLikesProvider.notifier).toggleLike(widget.post.id);
    
    if (success) {
      _likeController.forward().then((_) => _likeController.reverse());
      
      // Show heart animation if liked
      final isLiked = ref.read(postLikesProvider.notifier).isPostLiked(widget.post.id);
      if (isLiked) {
        _heartController.forward().then((_) => _heartController.reset());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final likesState = ref.watch(postLikesProvider);
    final isLiked = likesState.likedPosts[widget.post.id] ?? false;
    final likeCount = likesState.likeCounts[widget.post.id] ?? widget.post.likesCount;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.darkerBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.inputBorder.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info and actions
              Row(
                children: [
                  // User avatar
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
                    child: widget.post.userProfileImage != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: widget.post.userProfileImage!,
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
                          widget.post.userFullName ?? 'Unknown User',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textWhite,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '@${widget.post.userUsername ?? 'unknown'}',
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
                        timeago.format(widget.post.createdAt),
                        style: GoogleFonts.poppins(
                          color: AppTheme.textGray,
                          fontSize: 12.sp,
                        ),
                      ),
                      
                      if (widget.isOwner) ...[
                        SizedBox(height: 4.h),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: AppTheme.textGray,
                            size: 20.sp,
                          ),
                          color: AppTheme.darkerBackground,
                          onSelected: (value) {
                            if (value == 'edit' && widget.onEdit != null) {
                              widget.onEdit!();
                            } else if (value == 'delete' && widget.onDelete != null) {
                              widget.onDelete!();
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
              
              // Post content - only show if content exists
              if (widget.post.content.isNotEmpty) ...[
                Text(
                  widget.post.content,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textWhite,
                    fontSize: 14.sp,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12.h),
              ],

              // Post image
              if (widget.post.imageUrl != null) ...[
                if (widget.post.content.isEmpty) SizedBox(height: 12.h),
                GestureDetector(
                  onDoubleTap: _handleLike,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: widget.post.imageUrl!,
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
                ),
                SizedBox(height: 12.h),
              ] else if (widget.post.content.isNotEmpty) ...[
                SizedBox(height: 12.h),
              ],
              
              // Action buttons
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _likeController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_likeController.value * 0.2),
                        child: GestureDetector(
                          onTap: _handleLike,
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? AppTheme.accentRed : AppTheme.textGray,
                                size: 22.sp,
                              ),
                              if (likeCount > 0) ...[
                                SizedBox(width: 4.w),
                                Text(
                                  likeCount.toString(),
                                  style: GoogleFonts.poppins(
                                    color: isLiked ? AppTheme.accentRed : AppTheme.textGray,
                                    fontSize: 12.sp,
                                    fontWeight: isLiked ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(width: 24.w),
                  
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    count: widget.post.commentsCount,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(post: widget.post),
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(),
                  
                  IconButton(
                    onPressed: () {
                      // TODO: Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Share functionality coming soon!'),
                          backgroundColor: AppTheme.primaryYellow,
                        ),
                      );
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
          
          // Floating heart animation
          if (widget.post.imageUrl != null)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _heartController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 1.0 - _heartController.value,
                    child: Transform.scale(
                      scale: 0.5 + (_heartController.value * 1.5),
                      child: Center(
                        child: Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 80.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
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
