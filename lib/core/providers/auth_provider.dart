import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier(this._apiService) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null) {
        // For now, create a mock user if token exists
        final mockUser = User(
          id: 'mock_user_id',
          email: 'test@example.com',
          name: 'Test User',
          username: 'testuser',
          bio: 'This is a test user account',
          college: 'Test College',
          course: 'Computer Science',
          year: 3,
          skills: ['Flutter', 'React', 'Node.js'],
          interests: ['Mobile Development', 'Web Development'],
          followersCount: 42,
          followingCount: 38,
          isFollowing: false,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(user: mockUser);
      }
    } catch (e) {
      await _storage.delete(key: 'auth_token');
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Use mock login for testing
      final response = await _apiService.mockLogin(email, password);
      
      if (response['token'] != null) {
        await _storage.write(key: 'auth_token', value: response['token']);
        final user = User.fromJson(response['user']);
        state = state.copyWith(user: user, isLoading: false);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.register(userData);
      if (response['token'] != null) {
        await _storage.write(key: 'auth_token', value: response['token']);
        final user = User.fromJson(response['user']);
        state = state.copyWith(user: user, isLoading: false);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Handle error
    } finally {
      await _storage.delete(key: 'auth_token');
      state = AuthState();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});
