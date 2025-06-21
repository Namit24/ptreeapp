import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/comment_model.dart';

class CommentsState {
  final Map<String, List<Comment>> postComments;
  final bool isLoading;
  final String? error;

  CommentsState({
    this.postComments = const {},
    this.isLoading = false,
    this.error,
  });

  CommentsState copyWith({
    Map<String, List<Comment>>? postComments,
    bool? isLoading,
    String? error,
  }) {
    return CommentsState(
      postComments: postComments ?? this.postComments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CommentsNotifier extends StateNotifier<CommentsState> {
  CommentsNotifier() : super(CommentsState());

  final _supabase = Supabase.instance.client;

  Future<void> loadComments(String postId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print('💬 Loading comments for post: $postId');

      // Get comments with user profile data
      final response = await _supabase
          .from('comments')
          .select('''
            *,
            profiles:user_id (
              username,
              full_name,
              profile_image_url
            )
          ''')
          .eq('post_id', postId)
          .isFilter('parent_comment_id', null)
          .order('created_at', ascending: true);

      final comments = <Comment>[];
      
      for (final commentJson in response) {
        try {
          // Get replies for this comment
          final repliesResponse = await _supabase
              .from('comments')
              .select('''
                *,
                profiles:user_id (
                  username,
                  full_name,
                  profile_image_url
                )
              ''')
              .eq('parent_comment_id', commentJson['id'])
              .order('created_at', ascending: true);

          final replies = (repliesResponse as List).map((replyJson) {
            final profile = replyJson['profiles'];
            return Comment.fromJson({
              ...replyJson,
              'user_username': profile?['username'],
              'user_full_name': profile?['full_name'],
              'user_profile_image': profile?['profile_image_url'],
            });
          }).toList();

          final profile = commentJson['profiles'];
          final comment = Comment.fromJson({
            ...commentJson,
            'user_username': profile?['username'],
            'user_full_name': profile?['full_name'],
            'user_profile_image': profile?['profile_image_url'],
          });

          // Add replies to comment
          comments.add(comment.copyWith(replies: replies));
        } catch (e) {
          print('❌ Error processing comment: $e');
        }
      }

      state = state.copyWith(
        postComments: {...state.postComments, postId: comments},
        isLoading: false,
      );

      print('✅ Loaded ${comments.length} comments');
    } catch (e) {
      print('❌ Error loading comments: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return false;
      }

      print('💬 Adding comment to post: $postId');

      // Insert comment
      final response = await _supabase
          .from('comments')
          .insert({
            'post_id': postId,
            'user_id': user.id,
            'content': content.trim(),
            'parent_comment_id': parentCommentId,
          })
          .select()
          .single();

      // Get user profile
      final profile = await _supabase
          .from('profiles')
          .select('username, full_name, profile_image_url')
          .eq('id', user.id)
          .single();

      final newComment = Comment.fromJson({
        ...response,
        'user_username': profile['username'],
        'user_full_name': profile['full_name'],
        'user_profile_image': profile['profile_image_url'],
      });

      // Update local state
      final currentComments = state.postComments[postId] ?? [];
      
      if (parentCommentId == null) {
        // Top-level comment
        state = state.copyWith(
          postComments: {
            ...state.postComments,
            postId: [...currentComments, newComment],
          },
        );
      } else {
        // Reply to existing comment
        final updatedComments = currentComments.map((comment) {
          if (comment.id == parentCommentId) {
            return comment.copyWith(replies: [...comment.replies, newComment]);
          }
          return comment;
        }).toList();
        
        state = state.copyWith(
          postComments: {
            ...state.postComments,
            postId: updatedComments,
          },
        );
      }

      print('✅ Comment added successfully');
      return true;
    } catch (e) {
      print('❌ Error adding comment: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteComment(String commentId, String postId) async {
    try {
      print('🗑️ Deleting comment: $commentId');

      await _supabase
          .from('comments')
          .delete()
          .eq('id', commentId);

      // Update local state
      final currentComments = state.postComments[postId] ?? [];
      final updatedComments = currentComments.where((comment) => comment.id != commentId).toList();
      
      state = state.copyWith(
        postComments: {
          ...state.postComments,
          postId: updatedComments,
        },
      );

      print('✅ Comment deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting comment: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  List<Comment> getCommentsForPost(String postId) {
    return state.postComments[postId] ?? [];
  }
}

final commentsProvider = StateNotifierProvider<CommentsNotifier, CommentsState>((ref) {
  return CommentsNotifier();
});
