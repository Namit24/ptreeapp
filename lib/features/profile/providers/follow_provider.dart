import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';

class FollowState {
  final Map<String, bool> followingStatus;
  final Map<String, int> followerCounts;
  final Map<String, int> followingCounts;
  final bool isLoading;
  final String? error;

  FollowState({
    this.followingStatus = const {},
    this.followerCounts = const {},
    this.followingCounts = const {},
    this.isLoading = false,
    this.error,
  });

  FollowState copyWith({
    Map<String, bool>? followingStatus,
    Map<String, int>? followerCounts,
    Map<String, int>? followingCounts,
    bool? isLoading,
    String? error,
  }) {
    return FollowState(
      followingStatus: followingStatus ?? this.followingStatus,
      followerCounts: followerCounts ?? this.followerCounts,
      followingCounts: followingCounts ?? this.followingCounts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FollowNotifier extends StateNotifier<FollowState> {
  FollowNotifier() : super(FollowState());

  Future<void> toggleFollow(String userId) async {
    final currentlyFollowing = state.followingStatus[userId] ?? false;

    // Optimistic update
    final newFollowingStatus = {...state.followingStatus};
    final newFollowerCounts = {...state.followerCounts};

    newFollowingStatus[userId] = !currentlyFollowing;

    if (currentlyFollowing) {
      // Unfollowing - decrease count
      newFollowerCounts[userId] = (newFollowerCounts[userId] ?? 1) - 1;
    } else {
      // Following - increase count
      newFollowerCounts[userId] = (newFollowerCounts[userId] ?? 0) + 1;
    }

    state = state.copyWith(
      followingStatus: newFollowingStatus,
      followerCounts: newFollowerCounts,
    );

    try {
      bool success;
      if (currentlyFollowing) {
        success = await SupabaseService.unfollowUser(userId);
      } else {
        success = await SupabaseService.followUser(userId);
      }

      if (!success) {
        // Revert optimistic update on failure
        final revertFollowingStatus = {...state.followingStatus};
        final revertFollowerCounts = {...state.followerCounts};

        revertFollowingStatus[userId] = currentlyFollowing;

        if (currentlyFollowing) {
          revertFollowerCounts[userId] = (revertFollowerCounts[userId] ?? 0) + 1;
        } else {
          revertFollowerCounts[userId] = (revertFollowerCounts[userId] ?? 1) - 1;
        }

        state = state.copyWith(
          followingStatus: revertFollowingStatus,
          followerCounts: revertFollowerCounts,
          error: 'Failed to update follow status',
        );
      }
    } catch (e) {
      // Revert optimistic update on error
      final revertFollowingStatus = {...state.followingStatus};
      final revertFollowerCounts = {...state.followerCounts};

      revertFollowingStatus[userId] = currentlyFollowing;

      if (currentlyFollowing) {
        revertFollowerCounts[userId] = (revertFollowerCounts[userId] ?? 0) + 1;
      } else {
        revertFollowerCounts[userId] = (revertFollowerCounts[userId] ?? 1) - 1;
      }

      state = state.copyWith(
        followingStatus: revertFollowingStatus,
        followerCounts: revertFollowerCounts,
        error: 'Network error: $e',
      );
    }
  }

  Future<void> checkFollowStatus(String userId) async {
    try {
      final isFollowing = await SupabaseService.isFollowing(userId);

      final newFollowingStatus = {...state.followingStatus};
      newFollowingStatus[userId] = isFollowing;

      state = state.copyWith(followingStatus: newFollowingStatus);
    } catch (e) {
      print('❌ Error checking follow status: $e');
    }
  }

  void updateFollowerCount(String userId, int count) {
    final newFollowerCounts = {...state.followerCounts};
    newFollowerCounts[userId] = count;

    state = state.copyWith(followerCounts: newFollowerCounts);
  }

  void updateFollowingCount(String userId, int count) {
    final newFollowingCounts = {...state.followingCounts};
    newFollowingCounts[userId] = count;

    state = state.copyWith(followingCounts: newFollowingCounts);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final followProvider = StateNotifierProvider<FollowNotifier, FollowState>((ref) {
  return FollowNotifier();
});
