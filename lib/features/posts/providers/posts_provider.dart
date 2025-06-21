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
      print('🚀 Creating post...');

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Validate that we have either content or image
      if (content.trim().isEmpty && imageFile == null) {
        throw Exception('Post must have either text content or an image');
      }

      String? imageUrl;
      if (imageFile != null) {
        print('📸 Uploading image...');
        // Upload image to storage
        final fileName = 'post_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = 'posts/$fileName';

        await _supabase.storage
            .from('avatars')
            .upload(filePath, imageFile);

        imageUrl = _supabase.storage
            .from('avatars')
            .getPublicUrl(filePath);
        
        print('✅ Image uploaded: $imageUrl');
      }

      // Create post data
      final postData = {
        'user_id': user.id,
        'content': content.trim().isEmpty ? null : content.trim(),
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      print('📝 Inserting post: $postData');

      // Create post in database - SIMPLIFIED APPROACH
      final response = await _supabase
          .from('posts')
          .insert(postData)
          .select()
          .single();

      print('✅ Post created: ${response['id']}');

      // Get user profile for the post
      final profile = await _supabase
          .from('profiles')
          .select('username, full_name, profile_image_url')
          .eq('id', user.id)
          .single();

      // Create Post object
      final newPost = Post.fromJson({
        ...response,
        'user_username': profile['username'],
        'user_full_name': profile['full_name'],
        'user_profile_image': profile['profile_image_url'],
      });

      // Add to local state
      state = state.copyWith(
        posts: [newPost, ...state.posts],
        isLoading: false,
      );

      print('✅ Post creation completed successfully');
      return true;
    } catch (e) {
      print('❌ Error creating post: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create post: ${e.toString()}',
      );
      return false;
    }
  }

  // SIMPLIFIED: Get posts for a specific user
  Future<void> getUserPosts(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print('📱 Loading posts for user: $userId');

      // Simple query without complex joins
      final postsResponse = await _supabase
          .from('posts')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('✅ Found ${postsResponse.length} posts');

      // Get user profile separately
      final profileResponse = await _supabase
          .from('profiles')
          .select('username, full_name, profile_image_url')
          .eq('id', userId)
          .single();

      // Combine data
      final posts = (postsResponse as List).map((postJson) {
        return Post.fromJson({
          ...postJson,
          'user_username': profileResponse['username'],
          'user_full_name': profileResponse['full_name'],
          'user_profile_image': profileResponse['profile_image_url'],
        });
      }).toList();

      state = state.copyWith(
        posts: posts,
        isLoading: false,
      );

      print('✅ User posts loaded successfully');
    } catch (e) {
      print('❌ Error loading user posts: $e');
      state = state.copyWith(
        posts: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // SIMPLIFIED: Get all posts for feed
  Future<void> getFeedPosts() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print('📱 Loading feed posts...');

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get all posts except current user's
      final postsResponse = await _supabase
          .from('posts')
          .select('*')
          .neq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(50);

      print('✅ Found ${postsResponse.length} feed posts');

      final posts = <Post>[];
      
      // Get profile for each post
      for (final postJson in postsResponse) {
        try {
          final profileResponse = await _supabase
              .from('profiles')
              .select('username, full_name, profile_image_url')
              .eq('id', postJson['user_id'])
              .single();

          posts.add(Post.fromJson({
            ...postJson,
            'user_username': profileResponse['username'],
            'user_full_name': profileResponse['full_name'],
            'user_profile_image': profileResponse['profile_image_url'],
          }));
        } catch (e) {
          print('❌ Error loading profile for post ${postJson['id']}: $e');
          // Add post without profile data as fallback
          posts.add(Post.fromJson({
            ...postJson,
            'user_username': 'Unknown',
            'user_full_name': 'Unknown User',
            'user_profile_image': null,
          }));
        }
      }

      state = state.copyWith(
        posts: posts,
        isLoading: false,
      );

      print('✅ Feed posts loaded successfully');
    } catch (e) {
      print('❌ Error loading feed posts: $e');
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

final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  return PostsNotifier();
});
