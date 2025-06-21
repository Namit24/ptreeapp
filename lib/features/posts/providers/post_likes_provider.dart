import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostLikesState {
  final Map<String, bool> likedPosts;
  final Map<String, int> likeCounts;
  final bool isLoading;
  final String? error;

  PostLikesState({
    this.likedPosts = const {},
    this.likeCounts = const {},
    this.isLoading = false,
    this.error,
  });

  PostLikesState copyWith({
    Map<String, bool>? likedPosts,
    Map<String, int>? likeCounts,
    bool? isLoading,
    String? error,
  }) {
    return PostLikesState(
      likedPosts: likedPosts ?? this.likedPosts,
      likeCounts: likeCounts ?? this.likeCounts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PostLikesNotifier extends StateNotifier<PostLikesState> {
  PostLikesNotifier() : super(PostLikesState());

  final _supabase = Supabase.instance.client;

  Future<void> loadPostLikes(List<String> postIds) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      print('📊 Loading likes for ${postIds.length} posts');

      // Get like counts for all posts
      final likeCounts = <String, int>{};
      final likedPosts = <String, bool>{};

      for (final postId in postIds) {
        try {
          // Get like count
          final countResponse = await _supabase
              .from('post_likes')
              .select('id')
              .eq('post_id', postId);
          
          likeCounts[postId] = countResponse.length;

          // Check if current user liked this post
          final userLikeResponse = await _supabase
              .from('post_likes')
              .select('id')
              .eq('post_id', postId)
              .eq('user_id', user.id);
          
          likedPosts[postId] = userLikeResponse.isNotEmpty;
        } catch (e) {
          print('❌ Error loading likes for post $postId: $e');
          likeCounts[postId] = 0;
          likedPosts[postId] = false;
        }
      }

      state = state.copyWith(
        likeCounts: {...state.likeCounts, ...likeCounts},
        likedPosts: {...state.likedPosts, ...likedPosts},
      );

      print('✅ Loaded likes for ${postIds.length} posts');
    } catch (e) {
      print('❌ Error loading post likes: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> toggleLike(String postId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return false;
      }

      print('❤️ Toggling like for post: $postId');

      final isCurrentlyLiked = state.likedPosts[postId] ?? false;
      final currentCount = state.likeCounts[postId] ?? 0;

      if (isCurrentlyLiked) {
        // Unlike the post
        await _supabase
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', user.id);

        // Update local state
        state = state.copyWith(
          likedPosts: {...state.likedPosts, postId: false},
          likeCounts: {...state.likeCounts, postId: currentCount - 1},
        );

        print('💔 Post unliked');
      } else {
        // Like the post
        await _supabase
            .from('post_likes')
            .insert({
              'post_id': postId,
              'user_id': user.id,
            });

        // Update local state
        state = state.copyWith(
          likedPosts: {...state.likedPosts, postId: true},
          likeCounts: {...state.likeCounts, postId: currentCount + 1},
        );

        print('❤️ Post liked');
      }

      return true;
    } catch (e) {
      print('❌ Error toggling like: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  bool isPostLiked(String postId) {
    return state.likedPosts[postId] ?? false;
  }

  int getLikeCount(String postId) {
    return state.likeCounts[postId] ?? 0;
  }
}

final postLikesProvider = StateNotifierProvider<PostLikesNotifier, PostLikesState>((ref) {
  return PostLikesNotifier();
});
