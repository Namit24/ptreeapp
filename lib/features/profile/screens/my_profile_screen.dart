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

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> with TickerProviderStateMixin {
  late AnimationController _buttonController;
  late AnimationController _socialController;

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
    _loadProfileData();
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _socialController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      await ref.read(followProvider.notifier).loadUserCounts(authState.user!.id);
    }
  }

  Future<void> _refreshProfile() async {
    await ref.read(authProvider.notifier).refreshProfile();
    await _loadProfileData();
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
                          profile?['full_name'] ?? 'Your Name',
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

                        if (profile?['location']?.isNotEmpty == true) ...[
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
                                profile!['location'],
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
              if (profile?['bio']?.isNotEmpty == true) ...[
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
                  profile!['bio'],
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
                    return _buildModernChip(interest, AppTheme.primaryYellow)
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
                    return _buildModernChip(skill, AppTheme.textGray)
                        .animate(delay: Duration(milliseconds: 1300 + (index * 100)))
                        .fadeIn()
                        .scale(begin: const Offset(0.8, 0.8));
                  }).toList(),
                ),
              ],

              SizedBox(height: 40.h),

              // Modern Logout Button
              _buildModernButton(
                'Sign Out',
                onPressed: () async {
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

    // Debug print to see what's in the profile
    print('🔍 Profile data: ${profile.keys.toList()}');
    print('📱 Instagram: ${profile['instagram_handle']}');
    print('🐦 Twitter: ${profile['twitter_handle']}');
    print('💼 LinkedIn: ${profile['linkedin_handle']}');
    print('💻 GitHub: ${profile['github_handle']}');
    print('🌐 Website: ${profile['website_url']}');

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
                () => _launchUrl(profile!['website_url']),
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
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18.sp,
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
    final name = profile?['full_name'] ?? profile?['first_name'] ?? 'U';
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
