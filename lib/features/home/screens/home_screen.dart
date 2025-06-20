import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/event_card.dart';
import '../widgets/spotlight_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        color: AppTheme.primaryYellow,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Spotlight Section
            SliverToBoxAdapter(
              child: const SpotlightSection().animate().fadeIn(duration: 600.ms),
            ),
            
            // Recent Projects Horizontal Scroll
            SliverToBoxAdapter(
              child: _buildHorizontalSection(
                'Recent Projects',
                Icons.lightbulb_outline,
                _buildProjectsHorizontal(),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
            ),
            
            // Upcoming Events Horizontal Scroll
            SliverToBoxAdapter(
              child: _buildHorizontalSection(
                'Upcoming Events',
                Icons.event_outlined,
                _buildEventsHorizontal(),
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
            ),
            
            // Feed Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Your Feed',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
            ),
            
            // Main Feed
            feedState.when(
              data: (items) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= items.length) {
                      return Container(
                        padding: EdgeInsets.all(20.w),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryYellow,
                          ),
                        ),
                      );
                    }
                    
                    final item = items[index];
                    Widget card;
                    if (item['type'] == 'project') {
                      card = ProjectCard(project: item['data']);
                    } else {
                      card = EventCard(event: item['data']);
                    }
                    
                    return card.animate().fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: index * 100),
                    ).slideY(begin: 0.1);
                  },
                  childCount: items.length,
                ),
              ),
              loading: () => SliverFillRemaining(
                child: _buildLoadingState(),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: _buildErrorState(error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryWhite,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryYellow.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.account_tree_rounded,
              color: AppTheme.primaryBlack,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'ProjecTree',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 22.sp,
            ),
          ),
        ],
      ),
      actions: [
        _buildAppBarAction(Icons.notifications_outlined, () {}),
        _buildAppBarAction(Icons.chat_bubble_outline, () {}),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildAppBarAction(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlack,
              size: 20.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryYellow,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
        ),
        content,
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildProjectsHorizontal() {
    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 280.w,
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: AppTheme.glassBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppTheme.glassBorder),
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
                Container(
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 40.sp,
                      color: AppTheme.neutralGray,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample Project ${index + 1}',
                        style: Theme.of(context).textTheme.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Project description here...',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsHorizontal() {
    return SizedBox(
      height: 160.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 240.w,
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: AppTheme.glassBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppTheme.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.event,
                          color: AppTheme.primaryYellow,
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Dec ${20 + index}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.primaryYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Sample Event ${index + 1}',
                    style: Theme.of(context).textTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Event description and details...',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14.sp,
                        color: AppTheme.neutralGray,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          'Main Auditorium',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryYellow,
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading your feed...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.neutralGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Icon(
              Icons.error_outline,
              size: 40.sp,
              color: Colors.red.shade400,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8.h),
          Text(
            'We couldn\'t load your feed right now',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.neutralGray,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => ref.read(feedProvider.notifier).refresh(),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
