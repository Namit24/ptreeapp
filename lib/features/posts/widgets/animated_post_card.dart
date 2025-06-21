import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/post_model.dart';
import 'post_card.dart';

class AnimatedPostCard extends StatefulWidget {
  final Post post;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;

  const AnimatedPostCard({
    super.key,
    required this.post,
    this.isOwner = false,
    this.onEdit,
    this.onDelete,
    this.index = 0,
  });

  @override
  State<AnimatedPostCard> createState() => _AnimatedPostCardState();
}

class _AnimatedPostCardState extends State<AnimatedPostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLikeTap() {
    setState(() {
      _isLiked = !_isLiked;
    });
    
    if (_isLiked) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  void _onBookmarkTap() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PostCard(
      post: widget.post,
      isOwner: widget.isOwner,
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
    )
        .animate(delay: Duration(milliseconds: widget.index * 100))
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideY(begin: 0.3, duration: const Duration(milliseconds: 600))
        .then()
        .shimmer(
          duration: const Duration(milliseconds: 1000),
          color: Colors.white.withOpacity(0.1),
        );
  }
}
