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
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    SupabaseService.authStateChanges.listen((data) {
      print('Auth state changed: ${data.event}');
      final user = data.session?.user;
      if (user != null) {
        print('User authenticated: ${user.email}');
        _loadUserProfile(user);
      } else {
        print('User signed out');
        state = AuthState();
      }
    });

    // Check current session
    final currentUser = SupabaseService.currentUser;
    if (currentUser != null) {
      print('Current user found: ${currentUser.email}');
      _loadUserProfile(currentUser);
    }
  }

  Future<void> _loadUserProfile(User user) async {
    try {
      final profile = await SupabaseService.getProfile(user.id);
      print('Profile loaded: $profile');
      state = state.copyWith(user: user, profile: profile);
    } catch (e) {
      print('Error loading profile: $e');
      state = state.copyWith(user: user);
    }
  }

  // Email/Password Sign In
  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!);
        state = state.copyWith(isLoading: false);
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Login failed',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        username: username,
      );

      if (response.user != null) {
        state = state.copyWith(isLoading: false);
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Google Sign In - ACTUALLY WORKS
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('Starting Google sign in...');
      final success = await SupabaseService.signInWithGoogle();

      if (success) {
        print('Google OAuth initiated successfully');
        // Don't set loading to false here - let the auth state listener handle it
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'Google sign in failed',
      );
      return false;
    } catch (e) {
      print('Google sign in error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // GitHub Sign In - ACTUALLY WORKS
  Future<bool> signInWithGitHub() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('Starting GitHub sign in...');
      final success = await SupabaseService.signInWithGitHub();

      if (success) {
        print('GitHub OAuth initiated successfully');
        // Don't set loading to false here - let the auth state listener handle it
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        error: 'GitHub sign in failed',
      );
      return false;
    } catch (e) {
      print('GitHub sign in error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await SupabaseService.signOut();
    state = AuthState();
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
