import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import '../../../core/models/event_model.dart';
import '../../../core/theme/app_theme.dart';

class EventCard extends ConsumerWidget {
  final Event event;

  const EventCard({super.key, required this.event});

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
                  onTap: () => context.push('/profile/${event.userId}'),
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundImage: event.user?.profileImage != null
                        ? CachedNetworkImageProvider(event.user!.profileImage!)
                        : null,
                    child: event.user?.profileImage == null
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
                        onTap: () => context.push('/profile/${event.userId}'),
                        child: Text(
                          event.user?.username ?? event.user?.name ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        timeago.format(event.createdAt),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'EVENT',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Images
          if (event.images.isNotEmpty)
            SizedBox(
              height: 300.h,
              child: PageView.builder(
                itemCount: event.images.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: event.images[index],
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
          
          // Event Info
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14.sp, color: AppTheme.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      '${event.date.day}/${event.date.month}/${event.date.year}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(Icons.location_on, size: 14.sp, color: AppTheme.textSecondary),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        event.location,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (event.description.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    event.description,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ],
            ),
          ),
          
          // Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    event.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: event.isLiked ? Colors.red : null,
                  ),
                  onPressed: () => _toggleLike(ref),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => context.push('/event/${event.id}'),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _shareEvent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleLike(WidgetRef ref) {
    // Implement like functionality
  }

  void _shareEvent() {
    // Implement share functionality
  }
}
