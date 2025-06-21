import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/post_model.dart';
import 'post_card.dart';

class PostSearchDelegate extends SearchDelegate<Post?> {
  final List<Post> posts;

  PostSearchDelegate(this.posts);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.darkerBackground,
        foregroundColor: AppTheme.textWhite,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.poppins(
          color: AppTheme.textGray,
          fontSize: 16.sp,
        ),
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Search posts...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: AppTheme.textWhite),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: AppTheme.textWhite),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Container(
        color: AppTheme.darkBackground,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64.sp,
                color: AppTheme.textGray,
              ),
              SizedBox(height: 16.h),
              Text(
                'Search for posts',
                style: GoogleFonts.poppins(
                  color: AppTheme.textGray,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredPosts = posts.where((post) {
      final content = post.content.toLowerCase();
      final userName = (post.userFullName ?? '').toLowerCase();
      final username = (post.userUsername ?? '').toLowerCase();
      final searchQuery = query.toLowerCase();

      return content.contains(searchQuery) ||
             userName.contains(searchQuery) ||
             username.contains(searchQuery);
    }).toList();

    if (filteredPosts.isEmpty) {
      return Container(
        color: AppTheme.darkBackground,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64.sp,
                color: AppTheme.textGray,
              ),
              SizedBox(height: 16.h),
              Text(
                'No posts found',
                style: GoogleFonts.poppins(
                  color: AppTheme.textGray,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Try searching with different keywords',
                style: GoogleFonts.poppins(
                  color: AppTheme.textGray,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: AppTheme.darkBackground,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: filteredPosts.length,
        itemBuilder: (context, index) {
          final post = filteredPosts[index];
          return PostCard(
            post: post,
            isOwner: false,
          );
        },
      ),
    );
  }
}
