import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/feed_posts_provider.dart';
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

    // Load feed posts when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedPostsProvider.notifier).loadFeedPosts();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Load more posts when reaching bottom
      ref.read(feedPostsProvider.notifier).loadFeedPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            bottom: 8,
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
              // Logo
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryYellow,
                      AppTheme.primaryYellow.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
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
                  size: 18,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'ProjecTree',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlack,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              // Action buttons
              _buildActionButton(Icons.search, () {
                final feedPostsState = ref.read(feedPostsProvider);
                if (feedPostsState.posts.isNotEmpty) {
                  showSearch(
                    context: context,
                    delegate: PostSearchDelegate(feedPostsState.posts),
                  );
                }
              }),
              SizedBox(width: 12),
              _buildActionButton(Icons.notifications_none, () {}),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(feedPostsProvider.notifier).refresh();
        },
        color: AppTheme.primaryYellow,
        child: Consumer(
          builder: (context, ref, child) {
            final feedPostsState = ref.watch(feedPostsProvider);

            if (feedPostsState.isLoading && feedPostsState.posts.isEmpty) {
              return _buildLoadingState();
            }

            if (feedPostsState.error != null && feedPostsState.posts.isEmpty) {
              return _buildErrorState(feedPostsState.error);
            }

            if (feedPostsState.posts.isEmpty) {
              return _buildEmptyState();
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Feed Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.home_filled,
                          color: AppTheme.primaryYellow,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Your Feed',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlack,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                ),

                // Posts List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final post = feedPostsState.posts[index];

                      return Padding(
                        padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.glassBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.glassBorder),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.shadowColor,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
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
                ),

                // Loading indicator at bottom
                if (feedPostsState.isLoading && feedPostsState.posts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                    ),
                  ),

                // Bottom padding for navigation
                SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-post'),
        backgroundColor: AppTheme.primaryYellow,
        elevation: 8,
        child: Icon(
          Icons.add,
          color: AppTheme.primaryBlack,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryBlack,
          size: 24,
        ),
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
          SizedBox(height: 16),
          Text(
            'Loading your feed...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.neutralGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(dynamic error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlack,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We couldn\'t load your feed right now',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.neutralGray,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(feedPostsProvider.notifier).refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: AppTheme.primaryBlack,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryYellow.withOpacity(0.1),
                    AppTheme.primaryYellow.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: AppTheme.primaryYellow.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.people_outline,
                size: 60,
                color: AppTheme.primaryYellow,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No posts yet!',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlack,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Follow more users to see their posts in your feed',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.neutralGray,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/search'),
                  icon: Icon(Icons.search, size: 20),
                  label: Text('Find Users'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.primaryBlack,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/create-post'),
                  icon: Icon(Icons.add, size: 20),
                  label: Text('Create Post'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryYellow,
                    side: BorderSide(color: AppTheme.primaryYellow),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
