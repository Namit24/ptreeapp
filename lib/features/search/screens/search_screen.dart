import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
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
    // Remove _loadAllUsers() - start with empty screen
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      // Clear results when search is empty
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

      // Load follow status for each user
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
      appBar: AppBar(
        backgroundColor: AppTheme.darkerBackground,
        elevation: 0,
        title: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: AppTheme.inputBackground,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppTheme.inputBorder),
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 16.sp,
            ),
            decoration: InputDecoration(
              hintText: 'Search students...',
              hintStyle: TextStyle(
                color: AppTheme.textGray,
                fontSize: 16.sp,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.textGray,
                size: 20.sp,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(
                  Icons.clear,
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
                vertical: 10.h,
              ),
            ),
            onChanged: (value) {
              setState(() {}); // Rebuild to show/hide clear button
              if (value.isEmpty) {
                // Clear results immediately when search is cleared
                setState(() {
                  searchResults = [];
                  hasSearched = false;
                });
              } else {
                // Optional: Add debounced search here for better UX
                _searchUsers(value);
              }
            },
            onSubmitted: _searchUsers,
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
            CircularProgressIndicator(color: AppTheme.primaryYellow),
            SizedBox(height: 16.h),
            Text(
              hasSearched ? 'Searching...' : 'Loading students...',
              style: TextStyle(
                color: AppTheme.textGray,
                fontSize: 16.sp,
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
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: AppTheme.textGray,
            ),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              error!,
              style: TextStyle(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: AppTheme.darkBackground,
              ),
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
            Icon(
              hasSearched ? Icons.search_off : Icons.search,
              size: 64.sp,
              color: AppTheme.textGray,
            ),
            SizedBox(height: 16.h),
            Text(
              hasSearched ? 'No results found' : 'Search for students',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              hasSearched
                  ? 'Try searching with different keywords'
                  : 'Enter a name or username to find students',
              style: TextStyle(
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
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final followState = ref.watch(followProvider);
    final isFollowing = followState.followingStatus[user['id']] ?? false;
    final followerCount = followState.followerCounts[user['id']] ?? user['followers_count'] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.darkerBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: InkWell(
        onTap: () => context.push('/profile/${user['id']}'),
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile Image
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(color: AppTheme.primaryYellow, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23.r),
                    child: user['profile_image_url'] != null
                        ? CachedNetworkImage(
                      imageUrl: user['profile_image_url'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.primaryYellow.withOpacity(0.2),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryYellow,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildAvatarPlaceholder(user),
                    )
                        : _buildAvatarPlaceholder(user),
                  ),
                ),

                SizedBox(width: 12.w),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['full_name'] ?? 'Unknown User',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textWhite,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '@${user['username'] ?? 'unknown'}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                      if (user['location']?.isNotEmpty == true) ...[
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12.sp,
                              color: AppTheme.textGray,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              user['location'],
                              style: TextStyle(
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
              SizedBox(height: 12.h),
              Text(
                user['bio'],
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textWhite,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Interests and Skills
            if ((user['interests'] as List?)?.isNotEmpty == true ||
                (user['skills'] as List?)?.isNotEmpty == true) ...[
              SizedBox(height: 12.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: [
                  // Show first 3 interests
                  ...((user['interests'] as List?) ?? []).take(3).map((interest) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.3)),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppTheme.primaryYellow,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),

                  // Show first 2 skills
                  ...((user['skills'] as List?) ?? []).take(2).map((skill) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppTheme.inputBackground,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppTheme.inputBorder),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppTheme.textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],

            // Stats
            SizedBox(height: 12.h),
            Row(
              children: [
                _buildStatItem('Followers', followerCount),
                SizedBox(width: 16.w),
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
      color: AppTheme.primaryYellow.withOpacity(0.2),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 20.sp,
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
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textWhite,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppTheme.textGray,
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
