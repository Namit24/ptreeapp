import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../config/supabase_config.dart';

class SupabaseService {
  // Make client getter public
  static SupabaseClient get client => Supabase.instance.client;

  // ENHANCED Auth methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? username,
  }) async {
    print('📝 Creating new account for: $email');

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
    print('🔐 Signing in user: $email');

    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    print('👋 Signing out current user...');
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;

  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Profile methods
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      print('👤 Loading profile for user: $userId');
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      print('✅ Profile loaded successfully');
      return response;
    } catch (e) {
      print('❌ Error getting profile: $e');
      return null;
    }
  }

  static Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    print('📝 Updating profile for user: $userId');
    await client
        .from('profiles')
        .update(data)
        .eq('id', userId);
  }

  // ENHANCED: Profile image upload
  static Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      print('📸 Uploading profile image for user: $userId');

      final fileName = 'profile_$userId.jpg';
      final filePath = 'profiles/$fileName';

      // Upload to Supabase Storage
      await client.storage
          .from('avatars')
          .upload(filePath, imageFile, fileOptions: const FileOptions(
        cacheControl: '3600',
        upsert: true,
      ));

      // Get public URL
      final publicUrl = client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      print('✅ Profile image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Check username availability
  static Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await client
          .from('profiles')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      return response == null;
    } catch (e) {
      print('❌ Error checking username availability: $e');
      return false;
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

  // ENHANCED Google OAuth
  static Future<bool> signInWithGoogle() async {
    try {
      print('🔍 Initiating Google OAuth...');

      // Use the correct redirect URL based on platform
      String redirectTo;
      if (kIsWeb) {
        redirectTo = SupabaseConfig.webRedirectUrl;
      } else {
        redirectTo = SupabaseConfig.mobileredirectUrl;
      }

      print('🔗 Using redirect URL: $redirectTo');

      final response = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      print('✅ Google OAuth request sent successfully');
      return true;
    } catch (e) {
      print('❌ Google OAuth error: $e');
      return false;
    }
  }

  // ENHANCED GitHub OAuth
  static Future<bool> signInWithGitHub() async {
    try {
      print('🐙 Initiating GitHub OAuth...');

      // Use the correct redirect URL based on platform
      String redirectTo;
      if (kIsWeb) {
        redirectTo = SupabaseConfig.webRedirectUrl;
      } else {
        redirectTo = SupabaseConfig.mobileredirectUrl;
      }

      print('🔗 Using redirect URL: $redirectTo');

      final response = await client.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: redirectTo,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      print('✅ GitHub OAuth request sent successfully');
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
        // Get the current URL
        final currentUrl = Uri.base.toString();
        print('🔗 Handling OAuth callback for URL: $currentUrl');

        // Check if we have auth tokens in the URL
        if (currentUrl.contains('access_token') || currentUrl.contains('code')) {
          // Let Supabase handle the session automatically
          // The auth state listener will pick up the session change
          print('✅ OAuth tokens detected in URL, letting Supabase handle session');
        } else {
          print('⚠️ No OAuth tokens found in URL');
        }
      } catch (e) {
        print('❌ Error handling OAuth callback: $e');
      }
    }
  }

  // Password reset
  static Future<bool> resetPassword(String email) async {
    try {
      print('🔄 Sending password reset email to: $email');
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb
            ? SupabaseConfig.webRedirectUrl
            : SupabaseConfig.mobileredirectUrl,
      );
      print('✅ Password reset email sent successfully');
      return true;
    } catch (e) {
      print('❌ Error sending password reset email: $e');
      return false;
    }
  }
}
