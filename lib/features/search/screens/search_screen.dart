import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../../profile/widgets/follow_button.dart';
import '../../profile/providers/follow_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  bool hasSearched = false;
  String? error;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        hasSearched = false;
        isLoading = false;
        error = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = true;
      error = null;
    });

    try {
      final users = await SupabaseService.searchUsers(query);
      
      for (final user in users) {
        await ref.read(followProvider.notifier).checkFollowStatus(user['id']);
        ref.read(followProvider.notifier).updateFollowerCount(
          user['id'], 
          user['followers_count'] ?? 0,
        );
      }

      setState(() {
        searchResults = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      // FIXED HEADER - Better spacing from top
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h), // Increased height
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16.h, // Increased padding
            left: 16.w,
            right: 16.w,
            bottom: 16.h, // Increased bottom padding
          ),
          decoration: BoxDecoration(
            color: AppTheme.darkerBackground,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.inputBorder,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Modern Search Bar - Better positioned
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: AppTheme.inputBackground,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppTheme.inputBorder,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.poppins(
                      color: AppTheme.textWhite,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search students...',
                      hintStyle: GoogleFonts.poppins(
                        color: AppTheme.textPlaceholder,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Container(
                        padding: EdgeInsets.all(12.w),
                        child: Icon(
                          Icons.search_rounded,
                          color: AppTheme.textPlaceholder,
                          size: 20.sp,
                        ),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: AppTheme.textGray,
                                size: 20.sp,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  searchResults = [];
                                  hasSearched = false;
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      if (value.isEmpty) {
                        setState(() {
                          searchResults = [];
                          hasSearched = false;
                        });
                      } else {
                        _searchUsers(value);
                      }
                    },
                    onSubmitted: _searchUsers,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
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
              'Searching...',
              style: GoogleFonts.poppins(
                color: AppTheme.textGray,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppTheme.accentRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40.sp,
                color: AppTheme.accentRed,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Something went wrong',
              style: GoogleFonts.poppins(
                color: AppTheme.textWhite,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error!,
              style: GoogleFonts.poppins(
                color: AppTheme.textGray,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  _searchUsers(_searchController.text);
                }
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Icon(
                hasSearched ? Icons.search_off_rounded : Icons.search_rounded,
                size: 50.sp,
                color: AppTheme.primaryYellow,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              hasSearched ? 'No results found' : 'Search for students',
              style: GoogleFonts.poppins(
                color: AppTheme.textWhite,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              hasSearched 
                  ? 'Try searching with different keywords'
                  : 'Enter a name or username to find students',
              style: GoogleFonts.poppins(
                color: AppTheme.textGray,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_searchController.text.isNotEmpty) {
          await _searchUsers(_searchController.text);
        }
      },
      color: AppTheme.primaryYellow,
      backgroundColor: AppTheme.darkerBackground,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final user = searchResults[index];
          return _buildModernUserCard(user);
        },
      ),
    );
  }

  Widget _buildModernUserCard(Map<String, dynamic> user) {
    final followState = ref.watch(followProvider);
    final isFollowing = followState.followingStatus[user['id']] ?? false;
    final followerCount = followState.followerCounts[user['id']] ?? user['followers_count'] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.inputBorder.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/profile/${user['id']}'),
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Modern Profile Image
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryYellow,
                        AppTheme.primaryYellow.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28.r),
                      color: AppTheme.darkBackground,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26.r),
                      child: user['profile_image_url'] != null
                          ? CachedNetworkImage(
                              imageUrl: user['profile_image_url'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => _buildAvatarPlaceholder(user),
                              errorWidget: (context, url, error) => _buildAvatarPlaceholder(user),
                            )
                          : _buildAvatarPlaceholder(user),
                    ),
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['full_name'] ?? 'Unknown User',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textWhite,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '@${user['username'] ?? 'unknown'}',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: AppTheme.primaryYellow,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (user['location']?.isNotEmpty == true) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14.sp,
                              color: AppTheme.textGray,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              user['location'],
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: AppTheme.textGray,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Follow Button
                FollowButton(
                  userId: user['id'],
                  isFollowing: isFollowing,
                ),
              ],
            ),
            
            // Bio
            if (user['bio']?.isNotEmpty == true) ...[
              SizedBox(height: 16.h),
              Text(
                user['bio'],
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppTheme.textWhite,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Stats
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildStatItem('Followers', followerCount),
                SizedBox(width: 24.w),
                _buildStatItem('Following', user['following_count'] ?? 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(Map<String, dynamic> user) {
    final name = user['full_name'] ?? user['first_name'] ?? 'U';
    final letter = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryYellow.withOpacity(0.3),
            AppTheme.primaryYellow.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.poppins(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryYellow,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textWhite,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: AppTheme.textGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
