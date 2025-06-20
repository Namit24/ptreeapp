import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // Auth methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? username,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'full_name': '$firstName $lastName',
        'username': username,
      },
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;

  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Profile methods
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  static Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await _client
        .from('profiles')
        .update(data)
        .eq('id', userId);
  }

  // Projects methods
  static Future<List<Map<String, dynamic>>> getProjects({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client
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

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting projects: $e');
      return [];
    }
  }

  // Events methods
  static Future<List<Map<String, dynamic>>> getEvents({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client
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

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting events: $e');
      return [];
    }
  }

  // FIXED Google OAuth for Web and Mobile
  static Future<bool> signInWithGoogle() async {
    try {
      print('Starting Google OAuth...');

      // Use the correct redirect URL based on platform
      String redirectTo;
      if (kIsWeb) {
        redirectTo = SupabaseConfig.webRedirectUrl;
      } else {
        redirectTo = SupabaseConfig.mobileredirectUrl;
      }

      print('Using redirect URL: $redirectTo');

      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      print('Google OAuth initiated successfully');
      return true;
    } catch (e) {
      print('Google OAuth error: $e');
      return false;
    }
  }

  // FIXED GitHub OAuth for Web and Mobile
  static Future<bool> signInWithGitHub() async {
    try {
      print('Starting GitHub OAuth...');

      // Use the correct redirect URL based on platform
      String redirectTo;
      if (kIsWeb) {
        redirectTo = SupabaseConfig.webRedirectUrl;
      } else {
        redirectTo = SupabaseConfig.mobileredirectUrl;
      }

      print('Using redirect URL: $redirectTo');

      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: redirectTo,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      print('GitHub OAuth initiated successfully');
      return true;
    } catch (e) {
      print('GitHub OAuth error: $e');
      return false;
    }
  }

  // Handle OAuth callback (for web)
  static Future<void> handleOAuthCallback() async {
    if (kIsWeb) {
      try {
        // Get the current URL
        final currentUrl = Uri.base.toString();
        print('Handling OAuth callback for URL: $currentUrl');

        // Check if we have auth tokens in the URL
        if (currentUrl.contains('access_token') || currentUrl.contains('code')) {
          // Let Supabase handle the session automatically
          // The auth state listener will pick up the session change
          print('OAuth tokens detected in URL, letting Supabase handle session');
        } else {
          print('No OAuth tokens found in URL');
        }
      } catch (e) {
        print('Error handling OAuth callback: $e');
      }
    }
  }
}
