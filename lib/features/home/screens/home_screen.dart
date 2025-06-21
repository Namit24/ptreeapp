import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
              _buildModernActionButton(Icons.notifications_none, () {}),
              SizedBox(width: 8.w),
              _buildModernActionButton(Icons.chat_bubble_outline, () {}),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
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

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h), // Consistent spacing
                      child: card.animate().fadeIn(
                        duration: 400.ms,
                        delay: Duration(milliseconds: index * 100),
                      ).slideY(begin: 0.1),
                    );
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

            // Bottom padding for navigation - IMPROVED
            SliverToBoxAdapter(
              child: SizedBox(height: 80.h), // Reduced from 100.h
            ),
          ],
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
