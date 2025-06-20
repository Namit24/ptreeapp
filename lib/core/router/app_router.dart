import 'dart:async';
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
  final authNotifier = ref.read(authProvider.notifier);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(
      SupabaseService.authStateChanges.map((data) => data.session),
    ),
    redirect: (context, state) {
      // Get current Supabase session directly for most up-to-date info
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session?.user != null;
      final currentLocation = state.matchedLocation;

      print('Router redirect - isLoggedIn: $isLoggedIn, location: $currentLocation');

      // Allow auth callback to proceed
      if (currentLocation == '/auth/callback') return null;

      // If already on login and not logged in, stay there
      if (currentLocation == '/login' && !isLoggedIn) return null;

      // If already on register and not logged in, stay there
      if (currentLocation == '/register' && !isLoggedIn) return null;

      // If logged in and on auth pages, go to home
      if (isLoggedIn && (currentLocation == '/login' || currentLocation == '/register')) {
        print('User is logged in, redirecting to home');
        return '/home';
      }

      // If not logged in and not on auth pages, go to login
      if (!isLoggedIn && currentLocation != '/login' && currentLocation != '/register') {
        print('User not logged in, redirecting to login');
        return '/login';
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
        builder: (context, state) {
          print('Building home screen');
          return const MainScreen();
        },
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

// Helper class to refresh router on auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

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
