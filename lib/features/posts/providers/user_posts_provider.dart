import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../../core/models/post_model.dart';

class UserPostsState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;

  UserPostsState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  UserPostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
  }) {
    return UserPostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserPostsNotifier extends StateNotifier<UserPostsState> {
  UserPostsNotifier() : super(UserPostsState());

  final _supabase = Supabase.instance.client;

  Future<void> loadUserPosts(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      print('📱 Loading posts for user: $userId');

      final response = await _supabase
          .from('posts')
          .select('''
            *,
            profiles:user_id (
              id,
              username,
              full_name,
              profile_image_url
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('✅ Loaded ${response.length} posts for user');

      // Transform the response to match our Post model
      final posts = (response as List).map((json) {
        final postData = Map<String, dynamic>.from({
          ...json,
          'user_full_name': json['profiles']['full_name'],
          'user_username': json['profiles']['username'],
          'user_profile_image': json['profiles']['profile_image_url'],
        });
        return Post.fromJson(postData);
      }).toList();

      state = state.copyWith(
        posts: posts,
        isLoading: false,
      );
    } catch (e) {
      print('❌ Error loading user posts: $e');
      state = state.copyWith(
        posts: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      print('🗑️ Deleting post: $postId');

      await _supabase
          .from('posts')
          .delete()
          .eq('id', postId);

      // Remove from local state
      final updatedPosts = state.posts.where((post) => post.id != postId).toList();
      state = state.copyWith(posts: updatedPosts);

      print('✅ Post deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting post: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updatePost(String postId, String content) async {
    try {
      print('✏️ Updating post: $postId');

      await _supabase
          .from('posts')
          .update({
            'content': content.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', postId);

      // Update local state
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            content: content.trim(),
            updatedAt: DateTime.now(),
          );
        }
        return post;
      }).toList();

      state = state.copyWith(posts: updatedPosts);
      
      print('✅ Post updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating post: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void clearPosts() {
    state = state.copyWith(posts: [], error: null);
  }
}

final userPostsProvider = StateNotifierProvider<UserPostsNotifier, UserPostsState>((ref) {
  return UserPostsNotifier();
});
