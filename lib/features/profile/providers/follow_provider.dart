import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/providers/auth_provider.dart';

class FollowState {
  final Map<String, bool> followingStatus;
  final Map<String, int> followerCounts;
  final Map<String, int> followingCounts;
  final Set<String> loadingUsers; // Track loading state per user
  final bool isLoading;
  final String? error;

  FollowState({
    this.followingStatus = const {},
    this.followerCounts = const {},
    this.followingCounts = const {},
    this.loadingUsers = const {},
    this.isLoading = false,
    this.error,
  });

  FollowState copyWith({
    Map<String, bool>? followingStatus,
    Map<String, int>? followerCounts,
    Map<String, int>? followingCounts,
    Set<String>? loadingUsers,
    bool? isLoading,
    String? error,
  }) {
    return FollowState(
      followingStatus: followingStatus ?? this.followingStatus,
      followerCounts: followerCounts ?? this.followerCounts,
      followingCounts: followingCounts ?? this.followingCounts,
      loadingUsers: loadingUsers ?? this.loadingUsers,
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

    // Add user to loading set
    final newLoadingUsers = Set<String>.from(state.loadingUsers)..add(userId);
    state = state.copyWith(loadingUsers: newLoadingUsers);

    try {
      final isCurrentlyFollowing = state.followingStatus[userId] ?? false;
      
      if (isCurrentlyFollowing) {
        await SupabaseService.unfollowUser(currentUser.id, userId);
      } else {
        await SupabaseService.followUser(currentUser.id, userId);
      }

      // Update local state
      final newFollowingStatus = Map<String, bool>.from(state.followingStatus);
      newFollowingStatus[userId] = !isCurrentlyFollowing;

      final newFollowerCounts = Map<String, int>.from(state.followerCounts);
      final currentCount = newFollowerCounts[userId] ?? 0;
      newFollowerCounts[userId] = isCurrentlyFollowing 
          ? (currentCount - 1).clamp(0, double.infinity).toInt()
          : currentCount + 1;

      // Remove user from loading set
      final updatedLoadingUsers = Set<String>.from(state.loadingUsers)..remove(userId);

      state = state.copyWith(
        followingStatus: newFollowingStatus,
        followerCounts: newFollowerCounts,
        loadingUsers: updatedLoadingUsers,
      );
    } catch (e) {
      // Remove user from loading set on error
      final updatedLoadingUsers = Set<String>.from(state.loadingUsers)..remove(userId);
      state = state.copyWith(
        loadingUsers: updatedLoadingUsers,
        error: 'Failed to update follow status: $e',
      );
    }
  }

  Future<void> loadUserCounts(String userId) async {
    try {
      final counts = await SupabaseService.getUserCounts(userId);
      
      final newFollowerCounts = Map<String, int>.from(state.followerCounts);
      final newFollowingCounts = Map<String, int>.from(state.followingCounts);
      
      newFollowerCounts[userId] = counts['followers_count'] ?? 0;
      newFollowingCounts[userId] = counts['following_count'] ?? 0;
      
      state = state.copyWith(
        followerCounts: newFollowerCounts,
        followingCounts: newFollowingCounts,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to load user counts: $e');
    }
  }

  Future<void> checkFollowStatus(String userId) async {
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) return;

    try {
      final isFollowing = await SupabaseService.isFollowing(currentUser.id, userId);
      
      final newFollowingStatus = Map<String, bool>.from(state.followingStatus);
      newFollowingStatus[userId] = isFollowing;
      
      state = state.copyWith(followingStatus: newFollowingStatus);
    } catch (e) {
      state = state.copyWith(error: 'Failed to check following status: $e');
    }
  }

  void updateFollowerCount(String userId, int count) {
    final newFollowerCounts = Map<String, int>.from(state.followerCounts);
    newFollowerCounts[userId] = count;
    state = state.copyWith(followerCounts: newFollowerCounts);
  }

  void updateFollowingCount(String userId, int count) {
    final newFollowingCounts = Map<String, int>.from(state.followingCounts);
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
