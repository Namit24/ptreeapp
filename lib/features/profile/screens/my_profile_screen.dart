import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/follow_provider.dart';
import '../../../features/posts/providers/user_posts_provider.dart';
import '../../posts/widgets/post_card.dart';
import '../../posts/screens/create_post_screen.dart';
import '../../posts/widgets/quick_post_widget.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late AnimationController _socialController;
  bool _hasLoadedData = false;
  bool _isDisposed = false; // PREVENT WIDGET DISPOSAL ERRORS

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _socialController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    // LOAD DATA ONLY ONCE ON INIT
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedData && !_isDisposed) {
        _loadProfileData();
        _hasLoadedData = true;
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true; // MARK AS DISPOSED
    _buttonController.dispose();
    _socialController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    if (_isDisposed) return; // PREVENT USING REF AFTER DISPOSAL
    
    try {
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        await ref.read(followProvider.notifier).loadUserCounts(authState.user!.id);
        await ref.read(userPostsProvider.notifier).loadUserPosts(authState.user!.id);
      }
    } catch (e) {
      print('❌ Error loading profile data: $e');
    }
  }

  Future<void> _refreshProfile() async {
    if (_isDisposed) return;
    
    try {
      await ref.read(authProvider.notifier).refreshProfile();
      await _loadProfileData();
    } catch (e) {
      print('❌ Error refreshing profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final followState = ref.watch(followProvider);
    
    if (authState.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryYellow)
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: const Duration(seconds: 1)),
        ),
      );
    }

    if (authState.user == null) {
      return Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please log in to view your profile',
                style: GoogleFonts.poppins(
                  color: AppTheme.textWhite,
                  fontSize: 16.sp,
                ),
              ).animate().fadeIn().slideY(begin: 0.3),
              SizedBox(height: 20.h),
              _buildModernButton(
                'Log In',
                onPressed: () => context.go('/login'),
                isPrimary: true,
              ).animate(delay: const Duration(milliseconds: 200)).fadeIn().slideY(begin: 0.3),
            ],
          ),
        ),
      );
    }

    final profile = authState.profile;
    final userId = authState.user!.id;
    
    final followerCount = followState.followerCounts[userId] ?? profile?['followers_count'] ?? 0;
    final followingCount = followState.followingCounts[userId] ?? profile?['following_count'] ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkerBackground,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: AppTheme.textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        color: AppTheme.primaryYellow,
        backgroundColor: AppTheme.darkerBackground,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Row(
                children: [
                  // Modern Profile Image
                  Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.r),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryYellow,
                          AppTheme.primaryYellow.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryYellow.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(47.r),
                        color: AppTheme.darkBackground,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(44.r),
                        child: profile?['profile_image_url'] != null
                            ? CachedNetworkImage(
                                imageUrl: profile!['profile_image_url'],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => _buildAvatarPlaceholder(),
                                errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
                              )
                            : _buildAvatarPlaceholder(),
                      ),
                    ),
                  ).animate().scale(delay: const Duration(milliseconds: 100)),
                  
                  SizedBox(width: 24.w),
                  
                  // Profile Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?['full_name'] ?? profile?['first_name'] ?? 'Your Name',
                          style: GoogleFonts.poppins(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textWhite,
                          ),
                        ).animate().fadeIn().slideX(begin: 0.3),
                        SizedBox(height: 4.h),
                        Text(
                          '@${profile?['username'] ?? 'username'}',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: AppTheme.primaryYellow,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate(delay: const Duration(milliseconds: 100)).fadeIn().slideX(begin: 0.3),
                        
                        // SOCIAL HANDLES RIGHT BELOW USERNAME
                        if (_hasSocialHandles(profile)) ...[
                          SizedBox(height: 8.h),
                          _buildCompactSocialHandles(profile)
                              .animate(delay: const Duration(milliseconds: 200))
                              .fadeIn()
                              .slideX(begin: 0.3),
                        ],
                        
                        if (profile?['location']?.toString().isNotEmpty == true) ...[
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 16.sp,
                                color: AppTheme.textGray,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                profile!['location'].toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: AppTheme.textGray,
                                ),
                              ),
                            ],
                          ).animate(delay: const Duration(milliseconds: 300)).fadeIn().slideX(begin: 0.3),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Modern Edit Profile Button
              _buildModernButton(
                'Edit Profile',
                onPressed: () => context.push('/edit-profile'),
                isPrimary: false,
                icon: Icons.edit_rounded,
              ).animate(delay: const Duration(milliseconds: 400)).fadeIn().slideY(begin: 0.2),
              
              SizedBox(height: 24.h),
              
              // Stats
              Row(
                children: [
                  _buildStatItem('Followers', followerCount)
                      .animate(delay: const Duration(milliseconds: 500))
                      .fadeIn()
                      .slideY(begin: 0.2),
                  SizedBox(width: 40.w),
                  _buildStatItem('Following', followingCount)
                      .animate(delay: const Duration(milliseconds: 600))
                      .fadeIn()
                      .slideY(begin: 0.2),
                ],
              ),
              
              // Bio
              if (profile?['bio']?.toString().isNotEmpty == true) ...[
                SizedBox(height: 24.h),
                Text(
                  'About',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite,
                  ),
                ).animate(delay: const Duration(milliseconds: 700)).fadeIn().slideX(begin: -0.3),
                SizedBox(height: 12.h),
                Text(
                  profile!['bio'].toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    color: AppTheme.textWhite,
                    height: 1.5,
                  ),
                ).animate(delay: const Duration(milliseconds: 800)).fadeIn().slideY(begin: 0.2),
              ],
              
              // Interests
              if ((profile?['interests'] as List?)?.isNotEmpty == true) ...[
                SizedBox(height: 24.h),
                Text(
                  'Interests',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite,
                  ),
                ).animate(delay: const Duration(milliseconds: 900)).fadeIn().slideX(begin: -0.3),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: (profile!['interests'] as List).asMap().entries.map((entry) {
                    final index = entry.key;
                    final interest = entry.value;
                    return _buildModernChip(interest.toString(), AppTheme.primaryYellow)
                        .animate(delay: Duration(milliseconds: 1000 + (index * 100)))
                        .fadeIn()
                        .scale(begin: const Offset(0.8, 0.8));
                  }).toList(),
                ),
              ],
              
              // Skills
              if ((profile?['skills'] as List?)?.isNotEmpty == true) ...[
                SizedBox(height: 24.h),
                Text(
                  'Skills',
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textWhite,
                  ),
                ).animate(delay: const Duration(milliseconds: 1200)).fadeIn().slideX(begin: -0.3),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: (profile!['skills'] as List).asMap().entries.map((entry) {
                    final index = entry.key;
                    final skill = entry.value;
                    return _buildModernChip(skill.toString(), AppTheme.textGray)
                        .animate(delay: Duration(milliseconds: 1300 + (index * 100)))
                        .fadeIn()
                        .scale(begin: const Offset(0.8, 0.8));
                  }).toList(),
                ),
              ],
              
              // Create Post Button
              SizedBox(height: 24.h),
              _buildModernButton(
                'Create Post',
                onPressed: () => context.push('/create-post'),
                isPrimary: true,
                icon: Icons.add_rounded,
              ).animate(delay: const Duration(milliseconds: 1600)).fadeIn().slideY(begin: 0.3),

              // Quick Post Widget
              QuickPostWidget(
                userProfileImage: profile?['profile_image_url']?.toString(),
                userName: profile?['full_name']?.toString() ?? profile?['first_name']?.toString() ?? 'User',
              ).animate(delay: const Duration(milliseconds: 1550)).fadeIn().slideY(begin: 0.3),

              SizedBox(height: 24.h),

              // Posts Section
              Text(
                'My Posts',
                style: GoogleFonts.poppins(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ).animate(delay: const Duration(milliseconds: 1700)).fadeIn().slideX(begin: -0.3),

              SizedBox(height: 12.h),

              // Posts List - REMOVED THE RECURSIVE CALLBACK
              Consumer(
                builder: (context, ref, child) {
                  final userPostsState = ref.watch(userPostsProvider);
                  
                  if (userPostsState.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryYellow),
                    );
                  }
                  
                  if (userPostsState.posts.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: AppTheme.darkerBackground,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppTheme.inputBorder.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.post_add_rounded,
                            size: 48.sp,
                            color: AppTheme.textGray,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No posts yet',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textGray,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Share your first post with the community!',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textGray,
                              fontSize: 14.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ).animate(delay: const Duration(milliseconds: 1800)).fadeIn().scale(begin: const Offset(0.9, 0.9));
                  }
                  
                  return Column(
                    children: userPostsState.posts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final post = entry.value;
                      
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: PostCard(
                          post: post,
                          isOwner: true,
                          onEdit: () async {
                            if (_isDisposed) return;
                            
                            // Show edit dialog
                            final TextEditingController editController = TextEditingController(text: post.content);
                            
                            final result = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppTheme.darkerBackground,
                                title: Text(
                                  'Edit Post',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textWhite,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: Container(
                                  width: double.maxFinite,
                                  child: TextField(
                                    controller: editController,
                                    maxLines: 5,
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.textWhite,
                                      fontSize: 14.sp,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Edit your post...',
                                      hintStyle: GoogleFonts.poppins(
                                        color: AppTheme.textGray,
                                        fontSize: 14.sp,
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.inputBackground,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                        borderSide: BorderSide(color: AppTheme.inputBorder),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                        borderSide: BorderSide(color: AppTheme.inputBorder),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                        borderSide: BorderSide(color: AppTheme.primaryYellow),
                                      ),
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.poppins(color: AppTheme.textGray),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final newContent = editController.text.trim();
                                      if (newContent.isNotEmpty && newContent != post.content) {
                                        Navigator.of(context).pop(newContent);
                                      } else {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: Text(
                                      'Save',
                                      style: GoogleFonts.poppins(color: AppTheme.primaryYellow),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            
                            if (result != null && result.isNotEmpty && !_isDisposed) {
                              final success = await ref.read(userPostsProvider.notifier).updatePost(post.id, result);
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Post updated successfully!'),
                                    backgroundColor: AppTheme.accentGreen,
                                  ),
                                );
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to update post'),
                                    backgroundColor: AppTheme.accentRed,
                                  ),
                                );
                              }
                            }
                          },
                          onDelete: () async {
                            if (_isDisposed) return;
                            
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppTheme.darkerBackground,
                                title: Text(
                                  'Delete Post',
                                  style: GoogleFonts.poppins(color: AppTheme.textWhite),
                                ),
                                content: Text(
                                  'Are you sure you want to delete this post? This action cannot be undone.',
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
                            
                            if (confirmed == true && !_isDisposed) {
                              final success = await ref.read(userPostsProvider.notifier).deletePost(post.id);
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Post deleted successfully!'),
                                    backgroundColor: AppTheme.accentGreen,
                                  ),
                                );
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to delete post'),
                                    backgroundColor: AppTheme.accentRed,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ).animate(delay: Duration(milliseconds: 1800 + (index * 100)))
                       .fadeIn()
                       .slideY(begin: 0.3);
                    }).toList(),
                  );
                },
              ),
              
              SizedBox(height: 40.h),
              
              // Modern Logout Button
              _buildModernButton(
                'Sign Out',
                onPressed: () async {
                  if (_isDisposed) return;
                  
                  await ref.read(authProvider.notifier).signOut();
                  if (mounted) {
                    context.go('/login');
                  }
                },
                isPrimary: false,
                isDestructive: true,
                icon: Icons.logout_rounded,
              ).animate(delay: const Duration(milliseconds: 1500)).fadeIn().slideY(begin: 0.3),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasSocialHandles(Map<String, dynamic>? profile) {
    if (profile == null) return false;
    
    return profile['instagram_handle']?.toString().isNotEmpty == true ||
           profile['twitter_handle']?.toString().isNotEmpty == true ||
           profile['linkedin_handle']?.toString().isNotEmpty == true ||
           profile['github_handle']?.toString().isNotEmpty == true ||
           profile['website_url']?.toString().isNotEmpty == true;
  }

  // COMPACT SOCIAL HANDLES - displayed as small icons below username
  Widget _buildCompactSocialHandles(Map<String, dynamic>? profile) {
    return Row(
      children: [
        if (profile?['instagram_handle']?.toString().isNotEmpty == true)
          _buildSocialIcon(
            Icons.camera_alt_rounded,
            AppTheme.accentPurple,
            () => _launchUrl('https://instagram.com/${profile!['instagram_handle']}'),
          ),
        if (profile?['twitter_handle']?.toString().isNotEmpty == true)
          _buildSocialIcon(
            Icons.alternate_email_rounded,
            AppTheme.accentBlue,
            () => _launchUrl('https://twitter.com/${profile!['twitter_handle']}'),
          ),
        if (profile?['linkedin_handle']?.toString().isNotEmpty == true)
          _buildSocialIcon(
            Icons.work_rounded,
            AppTheme.accentBlue,
            () => _launchUrl('https://linkedin.com/in/${profile!['linkedin_handle']}'),
          ),
        if (profile?['github_handle']?.toString().isNotEmpty == true)
          _buildSocialIcon(
            Icons.code_rounded,
            AppTheme.textWhite,
            () => _launchUrl('https://github.com/${profile!['github_handle']}'),
          ),
        if (profile?['website_url']?.toString().isNotEmpty == true)
          _buildSocialIcon(
            Icons.language_rounded,
            AppTheme.accentGreen,
            () => _launchUrl(profile!['website_url'].toString()),
          ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: AnimatedBuilder(
        animation: _socialController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_socialController.value * 0.05),
            child: GestureDetector(
              onTapDown: (_) => _socialController.forward(),
              onTapUp: (_) {
                _socialController.reverse();
                onTap();
              },
              onTapCancel: () => _socialController.reverse(),
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('❌ Error launching URL: $e');
    }
  }

  Widget _buildAvatarPlaceholder() {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;
    final name = profile?['full_name']?.toString() ?? profile?['first_name']?.toString() ?? 'U';
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
            fontSize: 40.sp,
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
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textWhite,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: AppTheme.textGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildModernButton(
    String text, {
    required VoidCallback onPressed,
    bool isPrimary = true,
    bool isDestructive = false,
    IconData? icon,
  }) {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 - (_buttonController.value * 0.02),
          child: GestureDetector(
            onTapDown: (_) => _buttonController.forward(),
            onTapUp: (_) {
              _buttonController.reverse();
              onPressed();
            },
            onTapCancel: () => _buttonController.reverse(),
            child: Container(
              width: double.infinity,
              height: 50.h,
              decoration: BoxDecoration(
                gradient: isPrimary && !isDestructive
                    ? LinearGradient(
                        colors: [
                          AppTheme.primaryYellow,
                          AppTheme.primaryYellow.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isDestructive
                    ? AppTheme.accentRed.withOpacity(0.1)
                    : isPrimary
                        ? null
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: !isPrimary || isDestructive
                    ? Border.all(
                        color: isDestructive ? AppTheme.accentRed.withOpacity(0.3) : AppTheme.inputBorder,
                        width: 1.5,
                      )
                    : null,
                boxShadow: isPrimary && !isDestructive
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryYellow.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20.sp,
                      color: isDestructive
                          ? AppTheme.accentRed
                          : isPrimary
                              ? AppTheme.darkBackground
                              : AppTheme.textWhite,
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? AppTheme.accentRed
                          : isPrimary
                              ? AppTheme.darkBackground
                              : AppTheme.textWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
