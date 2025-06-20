import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthState {
  final User? user;
  final Map<String, dynamic>? profile;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.profile,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    Map<String, dynamic>? profile,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Check if profile is complete
  bool get isProfileComplete {
    return profile?['profile_completed'] == true;
  }

  // Check if user needs profile setup
  bool get needsProfileSetup {
    return user != null && !isProfileComplete;
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }

  void _init() {
    // Listen to auth state changes with debouncing
    SupabaseService.authStateChanges.listen((data) {
      print('Auth state changed: ${data.event}');
      final user = data.session?.user;

      // Only update state if there's an actual change
      if (user != null && state.user?.id != user.id) {
        print('User authenticated: ${user.email}');
        loadUserProfile(user);
      } else if (user == null && state.user != null) {
        print('User signed out');
        state = AuthState();
      }
    });

    // Check current session only once
    final currentUser = SupabaseService.currentUser;
    if (currentUser != null && state.user == null) {
      print('Current user found: ${currentUser.email}');
      loadUserProfile(currentUser);
    }
  }

  Future<void> loadUserProfile(User user) async {
    try {
      final profile = await SupabaseService.getProfile(user.id);
      print('Profile loaded: $profile');
      state = state.copyWith(user: user, profile: profile);
    } catch (e) {
      print('Error loading profile: $e');
      state = state.copyWith(user: user);
    }
  }

  // Add method to refresh profile after completion
  Future<void> refreshProfile() async {
    if (state.user != null) {
      await loadUserProfile(state.user!);
    }
  }

  // ENHANCED Email/Password Sign In
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔐 Attempting email/password sign in for: $email');

      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Email/password sign in successful');
        await loadUserProfile(response.user!);
        state = state.copyWith(isLoading: false);
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Login failed - Invalid credentials',
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
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  // ENHANCED Email/Password Sign Up
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? username,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('📝 Attempting email/password sign up for: $email');

      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        username: username,
      );

      if (response.user != null) {
        print('✅ Email/password sign up successful');

        // Check if email confirmation is required
        if (response.session == null) {
          state = state.copyWith(
            isLoading: false,
            error: 'Please check your email and click the confirmation link to complete registration.',
          );
          return false;
        }

        await loadUserProfile(response.user!);
        state = state.copyWith(isLoading: false);
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed',
      );
      return false;
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      String errorMessage = e.message;

      // Provide user-friendly error messages
      if (e.message.contains('already registered')) {
        errorMessage = 'An account with this email already exists. Please sign in instead.';
      } else if (e.message.contains('password')) {
        errorMessage = 'Password must be at least 6 characters long.';
      } else if (e.message.contains('email')) {
        errorMessage = 'Please enter a valid email address.';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    } catch (e) {
      print('❌ Unexpected error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred during registration',
      );
      return false;
    }
  }

  // ENHANCED Google Sign In
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🔍 Starting Google sign in...');
      final success = await SupabaseService.signInWithGoogle();

      if (success) {
        print('✅ Google OAuth initiated successfully');
        // Don't set loading to false here - let the auth state listener handle it
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Google sign in failed to start',
      );
      return false;
    } catch (e) {
      print('❌ Google sign in error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Google sign in failed: ${e.toString()}',
      );
      return false;
    }
  }

  // ENHANCED GitHub Sign In
  Future<bool> signInWithGitHub() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('🐙 Starting GitHub sign in...');
      final success = await SupabaseService.signInWithGitHub();

      if (success) {
        print('✅ GitHub OAuth initiated successfully');
        // Don't set loading to false here - let the auth state listener handle it
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'GitHub sign in failed to start',
      );
      return false;
    } catch (e) {
      print('❌ GitHub sign in error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'GitHub sign in failed: ${e.toString()}',
      );
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      print('👋 Signing out user...');
      await SupabaseService.signOut();
      state = AuthState();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Backward compatibility methods
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
