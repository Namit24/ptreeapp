import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // Auth methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? username,
  }) async {
    print('📝 Creating account for: $email');

    return await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'full_name': '$firstName $lastName',
        'username': username ?? email.split('@')[0],
        'email': email,
      },
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    print('🔐 Signing in: $email');

    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    print('👋 Signing out...');
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ENHANCED: Profile methods with proper email handling
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      print('👤 Loading profile for: $userId');

      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        print('✅ Profile found');
        return response;
      } else {
        print('⚠️ No profile found');
        return null;
      }
    } catch (e) {
      print('❌ Error getting profile: $e');
      return null;
    }
  }

  // FIXED: Include email in profile updates
  static Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      print('📝 Updating profile for: $userId');

      // Get current user email
      final currentUser = client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Ensure email is always included
      final updateData = {
        'id': userId,
        'email': currentUser.email, // Always include email
        ...data,
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('Update data: $updateData');

      await client
          .from('profiles')
          .upsert(updateData);

      print('✅ Profile updated successfully');
    } catch (e) {
      print('❌ Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // ENHANCED: Profile image upload with better error handling and binary upload
  static Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      print('🚀 Starting profile image upload for user: $userId');

      // Read file as bytes
      final Uint8List fileBytes = await imageFile.readAsBytes();
      final String fileExtension = path.extension(imageFile.path).toLowerCase();

      // Validate file type
      if (!['.jpg', '.jpeg', '.png', '.webp'].contains(fileExtension)) {
        throw Exception('Unsupported file type. Please use JPG, PNG, or WebP.');
      }

      // Validate file size (5MB limit)
      if (fileBytes.length > 5 * 1024 * 1024) {
        throw Exception('File too large. Please choose an image smaller than 5MB.');
      }

      // Generate unique filename
      final String fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final String filePath = '$userId/$fileName';

      print('📁 Uploading to path: $filePath');
      print('📊 File size: ${fileBytes.length} bytes');

      // Upload to Supabase Storage using binary upload
      final String uploadPath = await client.storage
          .from('avatars')
          .uploadBinary(
        filePath,
        fileBytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true, // Allow overwriting
        ),
      );

      print('✅ Upload successful: $uploadPath');

      // Get public URL
      final String publicUrl = client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      print('🌐 Public URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      print('❌ Upload error details: $e');

      // Provide more specific error messages
      if (e.toString().contains('row-level security policy')) {
        throw Exception('Storage permission denied. Please contact support.');
      } else if (e.toString().contains('413')) {
        throw Exception('File too large. Please choose a smaller image.');
      } else if (e.toString().contains('415')) {
        throw Exception('Unsupported file type. Please use JPG, PNG, or WebP.');
      } else {
        throw Exception('Failed to upload image: ${e.toString()}');
      }
    }
  }

  // Username availability
  static Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await client
          .from('profiles')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      return response == null;
    } catch (e) {
      print('❌ Error checking username: $e');
      return false;
    }
  }

  // Follow/Unfollow functionality
  static Future<bool> followUser(String followingId) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) return false;

      print('👥 Following user: $followingId');

      await client.from('follows').insert({
        'follower_id': currentUser.id,
        'following_id': followingId,
      });

      // Update counts for both users
      await updateFollowCounts(followingId); // Update followed user's follower count
      await updateFollowCounts(currentUser.id); // Update current user's following count

      print('✅ Successfully followed user');
      return true;
    } catch (e) {
      print('❌ Error following user: $e');
      return false;
    }
  }

  static Future<bool> unfollowUser(String followingId) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) return false;

      print('👥 Unfollowing user: $followingId');

      await client
          .from('follows')
          .delete()
          .eq('follower_id', currentUser.id)
          .eq('following_id', followingId);

      // Update counts for both users
      await updateFollowCounts(followingId); // Update unfollowed user's follower count
      await updateFollowCounts(currentUser.id); // Update current user's following count

      print('✅ Successfully unfollowed user');
      return true;
    } catch (e) {
      print('❌ Error unfollowing user: $e');
      return false;
    }
  }

  static Future<bool> isFollowing(String userId) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) return false;

      final response = await client
          .from('follows')
          .select()
          .eq('follower_id', currentUser.id)
          .eq('following_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('❌ Error checking follow status: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    try {
      final response = await client
          .from('follows')
          .select('''
            follower_id,
            profiles!follows_follower_id_fkey (
              id,
              username,
              full_name,
              profile_image_url
            )
          ''')
          .eq('following_id', userId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting followers: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    try {
      final response = await client
          .from('follows')
          .select('''
            following_id,
            profiles!follows_following_id_fkey (
              id,
              username,
              full_name,
              profile_image_url
            )
          ''')
          .eq('follower_id', userId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting following: $e');
      return [];
    }
  }

  // Get all users for discovery
  static Future<List<Map<String, dynamic>>> getAllUsers({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null) return [];

      final response = await client
          .from('profiles')
          .select()
          .neq('id', currentUser.id) // Exclude current user
          .eq('profile_completed', true) // Only completed profiles
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting users: $e');
      return [];
    }
  }

  // Search users functionality
  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      print('🔍 Searching users with query: $query');

      final currentUser = client.auth.currentUser;
      if (currentUser == null) return [];

      final response = await client
          .from('profiles')
          .select()
          .neq('id', currentUser.id) // Exclude current user
          .eq('profile_completed', true) // Only completed profiles
          .or('full_name.ilike.%$query%,username.ilike.%$query%,first_name.ilike.%$query%,last_name.ilike.%$query%')
          .order('created_at', ascending: false);

      print('✅ Search completed, found ${response.length} users');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error searching users: $e');
      throw Exception('Failed to search users: $e');
    }
  }

  // Projects methods
  static Future<List<Map<String, dynamic>>> getProjects({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      print('📋 Loading projects...');
      final response = await client
          .from('projects')
          .select('''
            *,
            profiles:user_id (
              id,
              username,
              full_name,
              profile_image_url
            )
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      print('✅ Loaded ${response.length} projects');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting projects: $e');
      return [];
    }
  }

  // Events methods
  static Future<List<Map<String, dynamic>>> getEvents({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      print('📅 Loading events...');
      final response = await client
          .from('events')
          .select('''
            *,
            profiles:user_id (
              id,
              username,
              full_name,
              profile_image_url
            )
          ''')
          .order('event_date', ascending: true)
          .range(offset, offset + limit - 1);

      print('✅ Loaded ${response.length} events');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting events: $e');
      return [];
    }
  }

  // OAuth methods
  static Future<bool> signInWithGoogle() async {
    try {
      print('🔍 Initiating Google OAuth...');

      String redirectTo;
      if (kIsWeb) {
        redirectTo = SupabaseConfig.webRedirectUrl;
      } else {
        redirectTo = SupabaseConfig.mobileRedirectUrl;
      }

      print('🔗 Redirect URL: $redirectTo');

      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      print('✅ Google OAuth initiated');
      return true;
    } catch (e) {
      print('❌ Google OAuth error: $e');
      return false;
    }
  }

  static Future<bool> signInWithGitHub() async {
    try {
      print('🐙 Initiating GitHub OAuth...');

      String redirectTo;
      if (kIsWeb) {
        redirectTo = SupabaseConfig.webRedirectUrl;
      } else {
        redirectTo = SupabaseConfig.mobileRedirectUrl;
      }

      print('🔗 Redirect URL: $redirectTo');

      await client.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: redirectTo,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      print('✅ GitHub OAuth initiated');
      return true;
    } catch (e) {
      print('❌ GitHub OAuth error: $e');
      return false;
    }
  }

  // Handle OAuth callback (for web)
  static Future<void> handleOAuthCallback() async {
    if (kIsWeb) {
      try {
        final currentUrl = Uri.base.toString();
        print('🔗 Handling OAuth callback: $currentUrl');

        if (currentUrl.contains('access_token') || currentUrl.contains('code')) {
          print('✅ OAuth tokens detected');
        } else {
          print('⚠️ No OAuth tokens found');
        }
      } catch (e) {
        print('❌ Error handling OAuth callback: $e');
      }
    }
  }

  // Password reset
  static Future<bool> resetPassword(String email) async {
    try {
      print('🔄 Sending password reset to: $email');
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb
            ? SupabaseConfig.webRedirectUrl
            : SupabaseConfig.mobileRedirectUrl,
      );
      print('✅ Password reset email sent');
      return true;
    } catch (e) {
      print('❌ Error sending password reset: $e');
      return false;
    }
  }

  // Update follower/following counts
  static Future<void> updateFollowCounts(String userId) async {
    try {
      print('📊 Updating follow counts for user: $userId');

      // Get follower count
      final followersResponse = await client
          .from('follows')
          .select('id')
          .eq('following_id', userId);

      final followerCount = followersResponse.length;

      // Get following count
      final followingResponse = await client
          .from('follows')
          .select('id')
          .eq('follower_id', userId);

      final followingCount = followingResponse.length;

      // Update profile with new counts
      await client
          .from('profiles')
          .update({
        'followers_count': followerCount,
        'following_count': followingCount,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

      print('✅ Updated counts - Followers: $followerCount, Following: $followingCount');
    } catch (e) {
      print('❌ Error updating follow counts: $e');
    }
  }
}
