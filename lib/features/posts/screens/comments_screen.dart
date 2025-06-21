import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/comment_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/comments_provider.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final Post post;

  const CommentsScreen({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _replyingToCommentId;
  String? _replyingToUsername;

  @override
  void initState() {
    super.initState();
    // Load comments when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentsProvider.notifier).loadComments(widget.post.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final success = await ref.read(commentsProvider.notifier).addComment(
      postId: widget.post.id,
      content: content,
      parentCommentId: _replyingToCommentId,
    );

    if (success) {
      _commentController.clear();
      _replyingToCommentId = null;
      _replyingToUsername = null;
      setState(() {});

      // Scroll to bottom to show new comment
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _replyToComment(Comment comment) {
    setState(() {
      _replyingToCommentId = comment.id;
      _replyingToUsername = comment.userUsername;
    });
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsProvider);
    final comments = commentsState.postComments[widget.post.id] ?? [];
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkerBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.textWhite,
            size: 24.sp,
          ),
        ),
        title: Text(
          'Comments',
          style: GoogleFonts.poppins(
            color: AppTheme.textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Post preview
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.darkerBackground,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.inputBorder.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
                  child: widget.post.userProfileImage != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: widget.post.userProfileImage!,
                            width: 32.w,
                            height: 32.h,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => _buildAvatarPlaceholder(widget.post.userFullName ?? 'U'),
                          ),
                        )
                      : _buildAvatarPlaceholder(widget.post.userFullName ?? 'U'),
                ),
                SizedBox(width: 12.w),
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
                      if (widget.post.content.isNotEmpty)
                        Text(
                          widget.post.content,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textGray,
                            fontSize: 12.sp,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Comments list
          Expanded(
            child: commentsState.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryYellow,
                    ),
                  )
                : comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48.sp,
                              color: AppTheme.textGray,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No comments yet',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textGray,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Be the first to comment!',
                              style: GoogleFonts.poppins(
                                color: AppTheme.textGray,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16.w),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return _buildCommentItem(comment, authState);
                        },
                      ),
          ),

          // Reply indicator
          if (_replyingToUsername != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.1),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.primaryYellow.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply,
                    color: AppTheme.primaryYellow,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Replying to @$_replyingToUsername',
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryYellow,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: Icon(
                      Icons.close,
                      color: AppTheme.primaryYellow,
                      size: 16.sp,
                    ),
                  ),
                ],
              ),
            ),

          // Comment input
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.darkerBackground,
              border: Border(
                top: BorderSide(
                  color: AppTheme.inputBorder.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
                  child: authState.profile?['profile_image_url'] != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: authState.profile!['profile_image_url'],
                            width: 32.w,
                            height: 32.h,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => _buildAvatarPlaceholder(authState.profile?['full_name'] ?? 'U'),
                          ),
                        )
                      : _buildAvatarPlaceholder(authState.profile?['full_name'] ?? 'U'),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textWhite,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: _replyingToUsername != null 
                          ? 'Reply to @$_replyingToUsername...'
                          : 'Add a comment...',
                      hintStyle: GoogleFonts.poppins(
                        color: AppTheme.textGray,
                        fontSize: 14.sp,
                      ),
                      filled: true,
                      fillColor: AppTheme.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: _addComment,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      Icons.send,
                      color: AppTheme.darkBackground,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, authState) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
                child: comment.userProfileImage != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: comment.userProfileImage!,
                          width: 32.w,
                          height: 32.h,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => _buildAvatarPlaceholder(comment.userFullName ?? 'U'),
                        ),
                      )
                    : _buildAvatarPlaceholder(comment.userFullName ?? 'U'),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.userFullName ?? 'Unknown User',
                          style: GoogleFonts.poppins(
                            color: AppTheme.textWhite,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          timeago.format(comment.createdAt),
                          style: GoogleFonts.poppins(
                            color: AppTheme.textGray,
                            fontSize: 11.sp,
                          ),
                        ),
                        const Spacer(),
                        if (comment.userId == authState.user?.id)
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: AppTheme.textGray,
                              size: 16.sp,
                            ),
                            color: AppTheme.darkerBackground,
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteComment(comment);
                              }
                            },
                            itemBuilder: (context) => [
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
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      comment.content,
                      style: GoogleFonts.poppins(
                        color: AppTheme.textWhite,
                        fontSize: 13.sp,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _replyToComment(comment),
                          child: Text(
                            'Reply',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textGray,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (comment.replies.isNotEmpty) ...[
                          SizedBox(width: 16.w),
                          Text(
                            '${comment.replies.length} ${comment.replies.length == 1 ? 'reply' : 'replies'}',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textGray,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Replies
        if (comment.replies.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 40.w),
            child: Column(
              children: comment.replies.map((reply) => _buildReplyItem(reply, authState)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildReplyItem(Comment reply, authState) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12.r,
            backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
            child: reply.userProfileImage != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: reply.userProfileImage!,
                      width: 24.w,
                      height: 24.h,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => _buildAvatarPlaceholder(reply.userFullName ?? 'U', size: 10.sp),
                    ),
                  )
                : _buildAvatarPlaceholder(reply.userFullName ?? 'U', size: 10.sp),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.userFullName ?? 'Unknown User',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textWhite,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      timeago.format(reply.createdAt),
                      style: GoogleFonts.poppins(
                        color: AppTheme.textGray,
                        fontSize: 10.sp,
                      ),
                    ),
                    const Spacer(),
                    if (reply.userId == authState.user?.id)
                      GestureDetector(
                        onTap: () => _deleteComment(reply),
                        child: Icon(
                          Icons.delete_outline,
                          color: AppTheme.textGray,
                          size: 14.sp,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  reply.content,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textWhite,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name, {double? size}) {
    final letter = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';
    
    return Text(
      letter,
      style: GoogleFonts.poppins(
        fontSize: size ?? 12.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryYellow,
      ),
    );
  }

  Future<void> _deleteComment(Comment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkerBackground,
        title: Text(
          'Delete Comment',
          style: GoogleFonts.poppins(color: AppTheme.textWhite),
        ),
        content: Text(
          'Are you sure you want to delete this comment?',
          style: GoogleFonts.poppins(color: AppTheme.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.textGray),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(commentsProvider.notifier).deleteComment(
        comment.id,
        widget.post.id,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comment deleted successfully!'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    }
  }
}
