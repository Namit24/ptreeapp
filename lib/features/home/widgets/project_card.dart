import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import '../../../core/models/project_model.dart';
import '../../../core/theme/app_theme.dart';

class ProjectCard extends ConsumerWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor, width: 1),
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile/${project.userId}'),
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundImage: project.user?.profileImage != null
                        ? CachedNetworkImageProvider(project.user!.profileImage!)
                        : null,
                    child: project.user?.profileImage == null
                        ? Icon(Icons.person, size: 20.sp)
                        : null,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/profile/${project.userId}'),
                        child: Text(
                          project.user?.username ?? project.user?.name ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        timeago.format(project.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showOptionsMenu(context),
                ),
              ],
            ),
          ),
          
          // Images
          if (project.images.isNotEmpty)
            SizedBox(
              height: 300.h,
              child: PageView.builder(
                itemCount: project.images.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: project.images[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.borderColor,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.borderColor,
                      child: const Icon(Icons.error),
                    ),
                  );
                },
              ),
            ),
          
          // Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    project.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: project.isLiked ? Colors.red : null,
                  ),
                  onPressed: () => _toggleLike(ref),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => context.push('/project/${project.id}'),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _shareProject(),
                ),
                const Spacer(),
                if (project.openForCollaboration)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Open for Collab',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Likes count
          if (project.likesCount > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                '${project.likesCount} ${project.likesCount == 1 ? 'like' : 'likes'}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          
          // Title and description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (project.description.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    project.description,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ],
            ),
          ),
          
          // Tags
          if (project.tags.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: project.tags.map((tag) => Text(
                  '#$tag',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                )).toList(),
              ),
            ),
          
          // Comments
          if (project.commentsCount > 0)
            Padding(
              padding: EdgeInsets.all(12.w),
              child: GestureDetector(
                onTap: () => context.push('/project/${project.id}'),
                child: Text(
                  'View all ${project.commentsCount} comments',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleLike(WidgetRef ref) {
    // Implement like functionality
  }

  void _shareProject() {
    // Implement share functionality
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _shareProject();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                // Implement report functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
