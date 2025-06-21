import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/feed_provider.dart';
import '../providers/feed_posts_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/event_card.dart';
import '../widgets/spotlight_section.dart';
import '../../posts/widgets/post_card.dart';
import '../../posts/widgets/post_search_delegate.dart';

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
      // IMPROVED HEADER - Better spacing
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.h), // Standard height
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 4.h, // Reduced top padding
            left: 16.w,
            right: 16.w,
            bottom: 4.h, // Reduced bottom padding
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryWhite,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.lightGray,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Modern Logo
              Container(
                width: 28.w, // Slightly smaller
                height: 28.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryYellow,
                      AppTheme.primaryYellow.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(7.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryYellow.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.account_tree_rounded,
                  color: AppTheme.primaryBlack,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'ProjecTree',
                style: GoogleFonts.inter(
                  fontSize: 18.sp, // Slightly smaller
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlack,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              // Modern Action Buttons
              _buildModernActionButton(Icons.search, () {
                final feedPostsState = ref.read(feedPostsProvider);
                if (feedPostsState.posts.isNotEmpty) {
                  showSearch(
                    context: context,
                    delegate: PostSearchDelegate(feedPostsState.posts),
                  );
                }
              }),
              SizedBox(width: 8.w),
              _buildModernActionButton(Icons.notifications_none, () {}),
              SizedBox(width: 8.w),
              _buildModernActionButton(Icons.chat_bubble_outline, () {}),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(feedPostsProvider.notifier).refresh();
        },
        color: AppTheme.primaryYellow,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Spotlight Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 8.h), // Reduced top padding
                child: const SpotlightSection(),
              ).animate().fadeIn(duration: 600.ms),
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
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), // Reduced padding
                child: Text(
                  'Your Feed',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlack,
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
            ),
            
            // Main Feed
            Consumer(
              builder: (context, ref, child) {
                final feedPostsState = ref.watch(feedPostsProvider);
                
                // Load feed posts when screen loads
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final authState = ref.read(authProvider);
                  if (authState.user != null && feedPostsState.posts.isEmpty && !feedPostsState.isLoading) {
                    ref.read(feedPostsProvider.notifier).loadFeedPosts();
                  }
                });
                
                if (feedPostsState.isLoading) {
                  return SliverFillRemaining(
                    child: _buildLoadingState(),
                  );
                }
                
                if (feedPostsState.error != null) {
                  return SliverFillRemaining(
                    child: _buildErrorState(feedPostsState.error),
                  );
                }
                
                if (feedPostsState.posts.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.all(24.w),
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: AppTheme.glassBackground,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppTheme.glassBorder),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48.sp,
                            color: AppTheme.neutralGray,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No posts in your feed yet',
                            style: GoogleFonts.inter(
                              color: AppTheme.primaryBlack,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Follow other users to see their posts here!',
                            style: GoogleFonts.inter(
                              color: AppTheme.neutralGray,
                              fontSize: 14.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = feedPostsState.posts[index];
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h, left: 16.w, right: 16.w),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.glassBackground,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppTheme.glassBorder),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.shadowColor,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: PostCard(
                            post: post,
                            isOwner: false, // These are other users' posts
                          ),
                        ).animate().fadeIn(
                          duration: 400.ms,
                          delay: Duration(milliseconds: index * 100),
                        ).slideY(begin: 0.1),
                      );
                    },
                    childCount: feedPostsState.posts.length,
                  ),
                );
              },
            ),
            
            // Bottom padding for navigation - IMPROVED
            SliverToBoxAdapter(
              child: SizedBox(height: 80.h), // Reduced from 100.h
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-post'),
        backgroundColor: AppTheme.primaryYellow,
        child: Icon(
          Icons.add,
          color: AppTheme.primaryBlack,
          size: 28.sp,
        ),
      ),
    );
  }

  Widget _buildModernActionButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36.w, // Slightly smaller
        height: 36.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryBlack,
          size: 22.sp, // Slightly smaller
        ),
      ),
    );
  }

  Widget _buildHorizontalSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), // Reduced padding
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w), // Slightly smaller
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryYellow,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlack,
                ),
              ),
            ],
          ),
        ),
        content,
        SizedBox(height: 16.h), // Reduced spacing
      ],
    );
  }

  Widget _buildProjectsHorizontal() {
    return SizedBox(
      height: 180.h, // Slightly smaller
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 260.w, // Slightly smaller
            margin: EdgeInsets.only(right: 12.w), // Reduced margin
            decoration: BoxDecoration(
              color: AppTheme.glassBackground,
              borderRadius: BorderRadius.circular(12.r), // Slightly smaller radius
              border: Border.all(color: AppTheme.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100.h, // Smaller image area
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 32.sp,
                      color: AppTheme.neutralGray,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.w), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample Project ${index + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Project description here...',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: AppTheme.neutralGray,
                        ),
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
      height: 140.h, // Smaller height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 220.w, // Smaller width
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              color: AppTheme.glassBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.event,
                          color: AppTheme.primaryYellow,
                          size: 14.sp,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Dec ${20 + index}',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: AppTheme.primaryYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Sample Event ${index + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Event description and details...',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppTheme.neutralGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12.sp,
                        color: AppTheme.neutralGray,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Main Auditorium',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: AppTheme.neutralGray,
                          ),
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
            style: GoogleFonts.inter(
              fontSize: 14.sp,
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
            width: 60.w, // Smaller error icon
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Icon(
              Icons.error_outline,
              size: 30.sp,
              color: Colors.red.shade400,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Something went wrong',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlack,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'We couldn\'t load your feed right now',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: AppTheme.neutralGray,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
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
