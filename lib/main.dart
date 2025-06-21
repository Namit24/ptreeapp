import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/supabase_config.dart';

// OAuth state provider
final oauthHandlingProvider = StateProvider<bool>((ref) => false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set URL strategy for web (removes # from URLs)
  if (kIsWeb) {
    setPathUrlStrategy();
  }

  // Initialize Supabase with better error handling
  try {
    if (SupabaseConfig.supabaseUrl != 'https://your-project.supabase.co' &&
        SupabaseConfig.supabaseAnonKey != 'your-anon-key-here') {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        authOptions: FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          detectSessionInUri: kIsWeb,
        ),
      );
      print('✅ Supabase initialized successfully');
    } else {
      print('⚠️ Supabase credentials not configured. Using mock data.');
    }
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
  }

  runApp(const ProviderScope(child: ProjecTreeApp()));
}

class ProjecTreeApp extends ConsumerStatefulWidget {
  const ProjecTreeApp({super.key});

  @override
  ConsumerState<ProjecTreeApp> createState() => _ProjecTreeAppState();
}

class _ProjecTreeAppState extends ConsumerState<ProjecTreeApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAppLinks();
    _setupAuthListener();
  }

  void _initializeAppLinks() {
    if (!kIsWeb) {
      _appLinks = AppLinks();

      // Handle app links when app is already running
      _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
        print('🔗 Received app link: $uri');
        _handleIncomingLink(uri);
      }, onError: (err) {
        print('❌ App link error: $err');
      });
    }
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      print('🔐 Auth state changed: $event');

      if (event == AuthChangeEvent.signedIn && session != null) {
        print('✅ User signed in successfully: ${session.user.email}');
        // Reset OAuth handling state and navigate
        Future.microtask(() {
          if (mounted) {
            ref.read(oauthHandlingProvider.notifier).state = false;
            // Force navigation to home after successful login
            final router = ref.read(routerProvider);
            router.go('/home');
          }
        });
      } else if (event == AuthChangeEvent.signedOut) {
        print('👋 User signed out');
        Future.microtask(() {
          if (mounted) {
            ref.read(oauthHandlingProvider.notifier).state = false;
          }
        });
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        print('🔄 Token refreshed');
      }
    });
  }

  Future<void> _handleIncomingLink(Uri uri) async {
    final isHandling = ref.read(oauthHandlingProvider);
    if (isHandling) {
      print('⏳ Already handling OAuth callback, skipping...');
      return;
    }

    try {
      if (uri.scheme == 'io.supabase.projectree' &&
          uri.host == 'login-callback') {

        print('🚀 Processing OAuth callback...');
        ref.read(oauthHandlingProvider.notifier).state = true;

        // Get the authorization code
        final code = uri.queryParameters['code'];
        final error = uri.queryParameters['error'];

        if (error != null) {
          print('❌ OAuth error: $error');
          final errorDescription = uri.queryParameters['error_description'];
          print('❌ OAuth error description: $errorDescription');

          if (mounted) {
            // Show error to user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sign in failed: $errorDescription'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (code != null) {
          print('🔑 OAuth code received: ${code.substring(0, 10)}...');

          try {
            // Exchange code for session
            await Supabase.instance.client.auth.exchangeCodeForSession(code);
            print('✅ Successfully exchanged code for session');

            // Wait a moment for auth state to update, then navigate
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              final router = ref.read(routerProvider);
              router.go('/home');
            }
          } catch (e) {
            print('❌ Failed to exchange code for session: $e');

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Authentication failed: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          print('❌ No OAuth code found in callback');
        }
      }
    } catch (e) {
      print('❌ Error handling OAuth callback: $e');
    } finally {
      // Always reset the handling state
      Future.microtask(() {
        if (mounted) {
          ref.read(oauthHandlingProvider.notifier).state = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final isHandlingOAuth = ref.watch(oauthHandlingProvider);

    // Show OAuth loading screen
    if (isHandlingOAuth) {
      return MaterialApp(
        title: 'ProjecTree',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: Scaffold(
          backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo or icon
                Icon(
                  Icons.account_tree_rounded,
                  size: 80,
                  color: AppTheme.darkTheme.primaryColor,
                ),
                const SizedBox(height: 32),
                // Loading indicator
                CircularProgressIndicator(
                  color: AppTheme.darkTheme.primaryColor,
                ),
                const SizedBox(height: 24),
                // Loading text
                Text(
                  'Signing you in...',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.darkTheme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we complete your authentication',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.darkTheme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ScreenUtilInit(
      designSize: const Size(390, 844), // OPTIMIZED: Standard Android size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'ProjecTree',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          routerConfig: router,
          // PERFORMANCE OPTIMIZATION
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
}

//https://v0.dev/chat/fork-of-projec-tree-architecture-1dlklGQeNbb