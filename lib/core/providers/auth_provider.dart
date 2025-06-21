import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../services/supabase_service.dart';

class AuthState {
  final User? user;
  final Map<String, dynamic>? profile;
  final bool isLoading;
  final String? error;
  final bool hasNetworkError;

  AuthState({
    this.user,
    this.profile,
    this.isLoading = false,
    this.error,
    this.hasNetworkError = false,
  });

  AuthState copyWith({
    User? user,
    Map<String, dynamic>? profile,
    bool? isLoading,
    String? error,
    bool? hasNetworkError,
  }) {
    return AuthState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasNetworkError: hasNetworkError ?? this.hasNetworkError,
    );
  }

  // FIXED: More robust profile completion check
  bool get isProfileComplete {
    if (hasNetworkError) {
      print('🌐 Network error detected, assuming profile is complete to avoid redirect loop');
      return true;
    }
    
    if (profile == null) {
      print('❌ Profile completion check: No profile data');
      return false;
    }

    // Check if explicitly marked as complete
    final isMarkedComplete = profile!['profile_completed'] == true;

    // Check required fields with better null safety
    final firstName = profile!['first_name']?.toString().trim() ?? '';
    final lastName = profile!['last_name']?.toString().trim() ?? '';
    final username = profile!['username']?.toString().trim() ?? '';

    final hasFirstName = firstName.isNotEmpty;
    final hasLastName = lastName.isNotEmpty;
    final hasUsername = username.isNotEmpty;

    // Check interests and skills with better null safety
    final interests = profile!['interests'];
    final skills = profile!['skills'];

    final hasInterests = interests is List && interests.isNotEmpty;
    final hasSkills = skills is List && skills.isNotEmpty;

    // FIXED: More lenient completion check
    final isComplete = isMarkedComplete || (hasFirstName && hasLastName && hasUsername);

    print('🔍 Profile completion check:');
    print('  - Marked complete: $isMarkedComplete');
    print('  - Has first name: $hasFirstName ($firstName)');
    print('  - Has last name: $hasLastName ($lastName)');
    print('  - Has username: $hasUsername ($username)');
    print('  - Has interests: $hasInterests ($interests)');
    print('  - Has skills: $hasSkills ($skills)');
    print('  - Final result: $isComplete');

    return isComplete;
  }

  // Check if user needs profile setup
  bool get needsProfileSetup {
    final needs = user != null && !isProfileComplete;
    print('🔍 Needs profile setup: $needs (user: ${user?.email}, complete: $isProfileComplete)');
    return needs;
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    SupabaseService.authStateChanges.listen((data) {
      print('🔄 Auth state changed: ${data.event}');
      final user = data.session?.user;

      if (user != null && state.user?.id != user.id) {
        print('👤 User authenticated: ${user.email}');
        loadUserProfile(user);
      } else if (user == null && state.user != null) {
        print('👋 User signed out');
        state = AuthState();
      }
    });

    // Check current session
    final currentUser = SupabaseService.currentUser;
    if (currentUser != null && state.user == null) {
      print('🔍 Current user found: ${currentUser.email}');
      loadUserProfile(currentUser);
    }
  }

  Future<void> loadUserProfile(User user) async {
    try {
      print('📥 Loading profile for user: ${user.id}');

      final profile = await SupabaseService.getProfile(user.id);

      if (profile != null) {
        print('✅ Profile loaded successfully');
        state = state.copyWith(user: user, profile: profile, isLoading: false, hasNetworkError: false);
      } else {
        print('⚠️ No profile found, user needs to complete setup');
        state = state.copyWith(user: user, profile: null, isLoading: false, hasNetworkError: false);
      }
    } catch (e) {
      print('❌ Error loading profile: $e');
      
      final isNetworkError = e.toString().contains('SocketException') || 
                           e.toString().contains('Failed host lookup') ||
                           e.toString().contains('Connection reset') ||
                           e.toString().contains('No address associated');

      if (isNetworkError) {
        print('🌐 Network error detected, setting offline mode');
        state = state.copyWith(
          user: user, 
          profile: null, 
          isLoading: false, 
          hasNetworkError: true,
          error: 'Network connection failed. Please check your internet connection.',
        );
      } else {
        state = state.copyWith(user: user, profile: null, isLoading: false, error: e.toString(), hasNetworkError: false);
      }
    }
  }

  // Refresh profile after completion
  Future<void> refreshProfile() async {
    if (state.user != null) {
      print('🔄 Refreshing profile...');
      await loadUserProfile(state.user!);
    }
  }

  // Upload profile image method
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final user = state.user;
      if (user == null) throw Exception('User not authenticated');

      print('📤 Uploading profile image for user: ${user.id}');

      final fileName = 'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'profiles/$fileName';

      // Upload to Supabase Storage
      await Supabase.instance.client.storage
          .from('avatars')
          .upload(filePath, imageFile);

      // Get public URL
      final imageUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath);

      print('✅ Profile image uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading profile image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Update profile method
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      final user = state.user;
      if (user == null) throw Exception('User not authenticated');

      print('📝 Updating profile for user: ${user.id}');
      print('Updates: $updates');

      // Update profile in database
      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', user.id);

      // Refresh profile data
      await refreshProfile();

      print('✅ Profile updated successfully');
    } catch (e) {
      print('❌ Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // Email/Password Sign In
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, hasNetworkError: false);

    try {
      print('🔐 Attempting sign in for: $email');

      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Sign in successful');
        await loadUserProfile(response.user!);
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Invalid email or password',
      );
      return false;
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      print('❌ Unexpected error: $e');
      
      final isNetworkError = e.toString().contains('SocketException') || 
                           e.toString().contains('Failed host lookup') ||
                           e.toString().contains('Connection reset');
      
      state = state.copyWith(
        isLoading: false,
        hasNetworkError: isNetworkError,
        error: isNetworkError ? 'Network connection failed. Please check your internet.' : 'An unexpected error occurred',
      );
      return false;
    }
  }

  // Email/Password Sign Up
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? username,
  }) async {
    state = state.copyWith(isLoading: true, error: null, hasNetworkError: false);

    try {
      print('📝 Attempting sign up for: $email');

      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        username: username,
      );

      if (response.user != null) {
        print('✅ Sign up successful');

        if (response.session == null) {
          state = state.copyWith(
            isLoading: false,
            error: 'Please check your email and click the confirmation link.',
          );
          return false;
        }

        await loadUserProfile(response.user!);
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed',
      );
      return false;
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      print('❌ Unexpected error: $e');
      
      final isNetworkError = e.toString().contains('SocketException') || 
                           e.toString().contains('Failed host lookup') ||
                           e.toString().contains('Connection reset');
      
      state = state.copyWith(
        isLoading: false,
        hasNetworkError: isNetworkError,
        error: isNetworkError ? 'Sign up requires internet connection' : 'Registration failed',
      );
      return false;
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null, hasNetworkError: false);

    try {
      print('🔍 Starting Google sign in...');
      final success = await SupabaseService.signInWithGoogle();

      if (success) {
        print('✅ Google OAuth initiated');
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Google sign in failed',
      );
      return false;
    } catch (e) {
      print('❌ Google sign in error: $e');
      
      final isNetworkError = e.toString().contains('SocketException') || 
                           e.toString().contains('Failed host lookup') ||
                           e.toString().contains('Connection reset');
      
      state = state.copyWith(
        isLoading: false,
        hasNetworkError: isNetworkError,
        error: isNetworkError ? 'Google sign in requires internet connection' : 'Google sign in failed',
      );
      return false;
    }
  }

  // GitHub Sign In
  Future<bool> signInWithGitHub() async {
    state = state.copyWith(isLoading: true, error: null, hasNetworkError: false);

    try {
      print('🐙 Starting GitHub sign in...');
      final success = await SupabaseService.signInWithGitHub();

      if (success) {
        print('✅ GitHub OAuth initiated');
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'GitHub sign in failed',
      );
      return false;
    } catch (e) {
      print('❌ GitHub sign in error: $e');
      
      final isNetworkError = e.toString().contains('SocketException') || 
                           e.toString().contains('Failed host lookup') ||
                           e.toString().contains('Connection reset');
      
      state = state.copyWith(
        isLoading: false,
        hasNetworkError: isNetworkError,
        error: isNetworkError ? 'GitHub sign in requires internet connection' : 'GitHub sign in failed',
      );
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      print('👋 Signing out...');
      await SupabaseService.signOut();
      state = AuthState();
      print('✅ Signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null, hasNetworkError: false);
  }

  // Backward compatibility
  Future<bool> login(String email, String password) => signIn(email, password);
  Future<bool> register(Map<String, dynamic> userData) => signUp(
    email: userData['email'],
    password: userData['password'],
    firstName: userData['firstName'] ?? userData['name']?.split(' ').first ?? '',
    lastName: userData['lastName'] ?? userData['name']?.split(' ').last ?? '',
    username: userData['username'],
  );
  Future<void> logout() => signOut();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
