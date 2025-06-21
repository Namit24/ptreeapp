import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../../core/models/post_model.dart';

class PostsState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;

  PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  PostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PostsNotifier extends StateNotifier<PostsState> {
  PostsNotifier() : super(PostsState());

  final _supabase = Supabase.instance.client;

  Future<bool> createPost({
    required String content,
    File? imageFile,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      String? imageUrl;
      if (imageFile != null) {
        // Upload image to storage
        final fileName = 'post_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = 'posts/$fileName';

        await _supabase.storage
            .from('avatars')
            .upload(filePath, imageFile);

        imageUrl = _supabase.storage
            .from('avatars')
            .getPublicUrl(filePath);
      }

      // Create post in database
      final response = await _supabase
          .from('posts')
          .insert({
        'user_id': user.id,
        'content': content,
        'image_url': imageUrl,
      })
          .select()
          .single();

      final newPost = Post.fromJson(response);

      // Add to local state
      state = state.copyWith(
        posts: [newPost, ...state.posts],
        isLoading: false,
      );

      return true;
    } catch (e) {
      print('❌ Error creating post: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> getUserPosts(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _supabase
          .from('posts')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final posts = (response as List)
          .map((json) => Post.fromJson(json))
          .toList();

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
      await _supabase
          .from('posts')
          .delete()
          .eq('id', postId);

      // Remove from local state
      final updatedPosts = state.posts.where((post) => post.id != postId).toList();
      state = state.copyWith(posts: updatedPosts);

      return true;
    } catch (e) {
      print('❌ Error deleting post: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updatePost(String postId, String content) async {
    try {
      await _supabase
          .from('posts')
          .update({'content': content})
          .eq('id', postId);

      // Update local state
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          return post.copyWith(content: content);
        }
        return post;
      }).toList();

      state = state.copyWith(posts: updatedPosts);
      return true;
    } catch (e) {
      print('❌ Error updating post: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  return PostsNotifier();
});
