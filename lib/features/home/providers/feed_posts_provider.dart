import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/post_model.dart';

class FeedPostsState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;
  final bool hasLoaded;

  FeedPostsState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
    this.hasLoaded = false,
  });

  FeedPostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
    bool? hasLoaded,
  }) {
    return FeedPostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class FeedPostsNotifier extends StateNotifier<FeedPostsState> {
  FeedPostsNotifier() : super(FeedPostsState());

  final _supabase = Supabase.instance.client;

  Future<void> loadFeedPosts() async {
    // Prevent recursive loading
    if (state.isLoading || state.hasLoaded) return;
    
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('📱 Loading feed posts (one time)...');

      // Use simple query without joins to avoid relationship issues
      final postsResponse = await _supabase
          .from('posts')
          .select('*')
          .neq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(20);

      print('✅ Loaded ${postsResponse.length} posts');

      final posts = <Post>[];
      
      // Get profile data for each post separately
      for (final postJson in postsResponse) {
        try {
          final profileResponse = await _supabase
              .from('profiles')
              .select('username, full_name, profile_image_url')
              .eq('id', postJson['user_id'])
              .maybeSingle();

          final postData = Map<String, dynamic>.from({
            ...postJson,
            'user_full_name': profileResponse?['full_name'] ?? 'Unknown User',
            'user_username': profileResponse?['username'] ?? 'unknown',
            'user_profile_image': profileResponse?['profile_image_url'],
          });
          
          posts.add(Post.fromJson(postData));
        } catch (e) {
          print('❌ Error loading profile for post ${postJson['id']}: $e');
          // Add post without profile data
          final postData = Map<String, dynamic>.from({
            ...postJson,
            'user_full_name': 'Unknown User',
            'user_username': 'unknown',
            'user_profile_image': null,
          });
          posts.add(Post.fromJson(postData));
        }
      }

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasLoaded: true,
      );
    } catch (e) {
      print('❌ Error loading feed posts: $e');
      state = state.copyWith(
        posts: [],
        isLoading: false,
        error: e.toString(),
        hasLoaded: true,
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(hasLoaded: false);
    await loadFeedPosts();
  }

  void reset() {
    state = FeedPostsState();
  }
}

final feedPostsProvider = StateNotifierProvider<FeedPostsNotifier, FeedPostsState>((ref) {
  return FeedPostsNotifier();
});
