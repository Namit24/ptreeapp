import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/follow_provider.dart';

class FollowButton extends ConsumerStatefulWidget {
  final String userId;
  final bool isFollowing;
  final VoidCallback? onPressed;

  const FollowButton({
    super.key,
    required this.userId,
    required this.isFollowing,
    this.onPressed,
  });

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final followState = ref.watch(followProvider);
    final currentlyFollowing = followState.followingStatus[widget.userId] ?? widget.isFollowing;
    final isLoading = followState.loadingUsers.contains(widget.userId);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      onTap: isLoading ? null : () {
        ref.read(followProvider.notifier).toggleFollow(widget.userId);
        widget.onPressed?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        // MADE SMALLER - reduced height and padding
        height: 28.h, // Reduced from 32.h
        padding: EdgeInsets.symmetric(horizontal: 12.w), // Reduced from 14.w
        decoration: BoxDecoration(
          color: currentlyFollowing 
              ? AppTheme.inputBackground 
              : AppTheme.primaryYellow,
          borderRadius: BorderRadius.circular(6.r),
          border: currentlyFollowing 
              ? Border.all(color: AppTheme.inputBorder) 
              : null,
          boxShadow: !currentlyFollowing && !_isPressed ? [
            BoxShadow(
              color: AppTheme.primaryYellow.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: isLoading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 12.w, // Reduced from 16.w
                    height: 12.h, // Reduced from 16.h
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5, // Reduced from 2
                      valueColor: AlwaysStoppedAnimation<Color>(
                        currentlyFollowing ? AppTheme.textWhite : AppTheme.darkBackground,
                      ),
                    ),
                  )
                : Row(
                    key: ValueKey(currentlyFollowing ? 'following' : 'follow'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        currentlyFollowing ? Icons.check : Icons.add,
                        size: 12.sp, // Reduced from 14.sp
                        color: currentlyFollowing 
                            ? AppTheme.textWhite 
                            : AppTheme.darkBackground,
                      )
                          .animate(target: currentlyFollowing ? 1 : 0)
                          .rotate(begin: 0, end: 0.5, duration: 300.ms, curve: Curves.easeInOut),
                      
                      SizedBox(width: 3.w), // Reduced from 4.w
                      
                      Text(
                        currentlyFollowing ? 'Following' : 'Follow',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp, // Reduced from 12.sp
                          fontWeight: FontWeight.w600,
                          color: currentlyFollowing 
                              ? AppTheme.textWhite 
                              : AppTheme.darkBackground,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      )
          .animate(target: _isPressed ? 1 : 0)
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.95, 0.95), duration: 100.ms)
          .animate()
          .then(delay: currentlyFollowing != widget.isFollowing ? 0.ms : 1000.ms)
          .shake(hz: 2, curve: Curves.easeInOut)
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1), duration: 150.ms)
          .then()
          .scale(begin: const Offset(1.1, 1.1), end: const Offset(1.0, 1.0), duration: 150.ms),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
