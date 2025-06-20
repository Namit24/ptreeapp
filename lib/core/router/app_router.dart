import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../services/supabase_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/projects/screens/project_detail_screen.dart';
import '../../features/events/screens/event_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isAuthCallback = state.matchedLocation == '/auth/callback';

      print('Router redirect - isLoggedIn: $isLoggedIn, location: ${state.matchedLocation}');

      // Allow auth callback to proceed
      if (isAuthCallback) return null;

      // DEMO MODE: Allow access to home even without real auth
      if (state.matchedLocation == '/home') return null;

      // If not logged in and not on auth pages, go to login
      if (!isLoggedIn && !isLoggingIn && state.matchedLocation != '/home') {
        print('Redirecting to login');
        return '/login';
      }

      // If logged in and on auth pages, go to home
      if (isLoggedIn && isLoggingIn) {
        print('Redirecting to home');
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          print('Building login screen');
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) => ProfileScreen(
          userId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/project/:id',
        builder: (context, state) => ProjectDetailScreen(
          projectId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/event/:id',
        builder: (context, state) => EventDetailScreen(
          eventId: state.pathParameters['id']!,
        ),
      ),
      // OAuth callback route for web
      GoRoute(
        path: '/auth/callback',
        builder: (context, state) => const AuthCallbackScreen(),
      ),
    ],
  );
});

// OAuth callback screen for web
class AuthCallbackScreen extends ConsumerStatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    try {
      await SupabaseService.handleOAuthCallback();
      // Navigate to home after successful callback
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      print('Error handling OAuth callback: $e');
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B23),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFCC00),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.account_tree_rounded,
                color: Color(0xFF1A1B23),
                size: 30,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Color(0xFFFFCC00),
            ),
            const SizedBox(height: 16),
            const Text(
              'Completing sign in...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
