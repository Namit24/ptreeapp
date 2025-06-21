import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/providers/auth_provider.dart';

class FollowState {
  final Map<String, bool> followingStatus;
  final Map<String, int> followerCounts;
  final Map<String, int> followingCounts;
  final Set<String> loadingUsers; // Add this property
  final bool isLoading;
  final String? error;

  FollowState({
    this.followingStatus = const {},
    this.followerCounts = const {},
    this.followingCounts = const {},
    this.loadingUsers = const {}, // Add this
    this.isLoading = false,
    this.error,
  });

  FollowState copyWith({
    Map<String, bool>? followingStatus,
    Map<String, int>? followerCounts,
    Map<String, int>? followingCounts,
    Set<String>? loadingUsers, // Add this
    bool? isLoading,
    String? error,
  }) {
    return FollowState(
      followingStatus: followingStatus ?? this.followingStatus,
      followerCounts: followerCounts ?? this.followerCounts,
      followingCounts: followingCounts ?? this.followingCounts,
      loadingUsers: loadingUsers ?? this.loadingUsers, // Add this
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FollowNotifier extends StateNotifier<FollowState> {
  final Ref ref;

  FollowNotifier(this.ref) : super(FollowState());

  Future<void> toggleFollow(String userId) async {
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) return;

    final currentlyFollowing = state.followingStatus[userId] ?? false;

    // Add user to loading set
    final newLoadingUsers = {...state.loadingUsers, userId};
    state = state.copyWith(loadingUsers: newLoadingUsers);

    // Optimistic update for BOTH users
    final newFollowingStatus = {...state.followingStatus};
    final newFollowerCounts = {...state.followerCounts};
    final newFollowingCounts = {...state.followingCounts};

    newFollowingStatus[userId] = !currentlyFollowing;

    if (currentlyFollowing) {
      // Unfollowing - decrease target's followers, decrease current user's following
      newFollowerCounts[userId] = (newFollowerCounts[userId] ?? 1) - 1;
      newFollowingCounts[currentUser.id] = (newFollowingCounts[currentUser.id] ?? 1) - 1;
    } else {
      // Following - increase target's followers, increase current user's following
      newFollowerCounts[userId] = (newFollowerCounts[userId] ?? 0) + 1;
      newFollowingCounts[currentUser.id] = (newFollowingCounts[currentUser.id] ?? 0) + 1;
    }

    state = state.copyWith(
      followingStatus: newFollowingStatus,
      followerCounts: newFollowerCounts,
      followingCounts: newFollowingCounts,
    );

    try {
      bool success;
      if (currentlyFollowing) {
        success = await SupabaseService.unfollowUser(userId);
        print('👥 Unfollowing user: $userId');
      } else {
        success = await SupabaseService.followUser(userId);
        print('👥 Following user: $userId');
      }

      if (success) {
        print('✅ Follow action successful');

        // Wait a bit for database triggers to execute
        await Future.delayed(Duration(milliseconds: 800));

        // Refresh both users' actual counts from database
        await _refreshUserCounts(userId);
        await _refreshUserCounts(currentUser.id);

        // Also refresh the auth provider's profile for current user
        // But don't await it to avoid navigation issues
        ref.read(authProvider.notifier).refreshProfile();

        print('✅ Follow counts refreshed successfully');
      } else {
        print('❌ Follow action failed');
        // Revert optimistic update on failure
        _revertOptimisticUpdate(userId, currentUser.id, currentlyFollowing);
      }
    } catch (e) {
      print('❌ Follow action error: $e');
      // Revert optimistic update on error
      _revertOptimisticUpdate(userId, currentUser.id, currentlyFollowing);
    } finally {
      // Remove user from loading set
      final updatedLoadingUsers = {...state.loadingUsers};
      updatedLoadingUsers.remove(userId);
      state = state.copyWith(loadingUsers: updatedLoadingUsers);
    }
  }

  void _revertOptimisticUpdate(String targetUserId, String currentUserId, bool wasFollowing) {
    final revertFollowingStatus = {...state.followingStatus};
    final revertFollowerCounts = {...state.followerCounts};
    final revertFollowingCounts = {...state.followingCounts};

    revertFollowingStatus[targetUserId] = wasFollowing;

    if (wasFollowing) {
      // Was following, so revert the unfollow
      revertFollowerCounts[targetUserId] = (revertFollowerCounts[targetUserId] ?? 0) + 1;
      revertFollowingCounts[currentUserId] = (revertFollowingCounts[currentUserId] ?? 0) + 1;
    } else {
      // Wasn't following, so revert the follow
      revertFollowerCounts[targetUserId] = (revertFollowerCounts[targetUserId] ?? 1) - 1;
      revertFollowingCounts[currentUserId] = (revertFollowingCounts[currentUserId] ?? 1) - 1;
    }

    state = state.copyWith(
      followingStatus: revertFollowingStatus,
      followerCounts: revertFollowerCounts,
      followingCounts: revertFollowingCounts,
      error: 'Failed to update follow status',
    );
  }

  Future<void> _refreshUserCounts(String userId) async {
    try {
      final profile = await SupabaseService.getProfile(userId);
      if (profile != null) {
        final newFollowerCounts = {...state.followerCounts};
        final newFollowingCounts = {...state.followingCounts};

        newFollowerCounts[userId] = profile['followers_count'] ?? 0;
        newFollowingCounts[userId] = profile['following_count'] ?? 0;

        state = state.copyWith(
          followerCounts: newFollowerCounts,
          followingCounts: newFollowingCounts,
        );

        print('✅ Refreshed counts for user $userId: followers=${profile['followers_count']}, following=${profile['following_count']}');
      }
    } catch (e) {
      print('❌ Error refreshing user counts for $userId: $e');
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

  // Load actual counts from database
  Future<void> loadUserCounts(String userId) async {
    try {
      final profile = await SupabaseService.getProfile(userId);
      if (profile != null) {
        final newFollowerCounts = {...state.followerCounts};
        final newFollowingCounts = {...state.followingCounts};

        newFollowerCounts[userId] = profile['followers_count'] ?? 0;
        newFollowingCounts[userId] = profile['following_count'] ?? 0;

        state = state.copyWith(
          followerCounts: newFollowerCounts,
          followingCounts: newFollowingCounts,
        );

        print('✅ Loaded counts for user $userId: followers=${profile['followers_count']}, following=${profile['following_count']}');
      }
    } catch (e) {
      print('❌ Error loading user counts: $e');
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
  return FollowNotifier(ref);
});
