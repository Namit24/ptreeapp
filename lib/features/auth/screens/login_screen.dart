import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSignUp = false;

  // Sign up controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController.forward();

    // Clear any previous errors when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(authProvider.notifier).clearError();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      key: const ValueKey('login_screen'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF4A5568),
              AppTheme.darkBackground,
              AppTheme.darkerBackground,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 50.h), // Reduced from 60.h

                // Header Section with animations
                _buildHeader()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 100.ms)
                    .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                SizedBox(height: 32.h), // Reduced from 40.h

                // Form Section with staggered animations
                _buildForm(authState)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                SizedBox(height: 24.h), // Reduced from 32.h

                // Social Login Section
                _buildSocialLogin(authState)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 500.ms)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),

                SizedBox(height: 32.h), // Reduced from 40.h
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo with bounce animation
        Container(
          width: 70.w, // Reduced from 80.w
          height: 70.h, // Reduced from 80.h
          decoration: BoxDecoration(
            color: AppTheme.primaryYellow,
            borderRadius: BorderRadius.circular(18.r), // Reduced from 20.r
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryYellow.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.account_tree_rounded,
            color: AppTheme.darkBackground,
            size: 36.sp, // Reduced from 40.sp
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 2000.ms)
            .then()
            .scale(begin: const Offset(1.05, 1.05), end: const Offset(1.0, 1.0), duration: 2000.ms),

        SizedBox(height: 28.h), // Reduced from 32.h

        Text(
          'Welcome to ProjecTree',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: 24.sp, // Reduced from 28.sp
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 200.ms)
            .slideX(begin: -0.3, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),

        SizedBox(height: 10.h), // Reduced from 12.h

        Text(
          'Your journey starts here. Join our community and\ndiscover the power of collaborative innovations.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 14.sp, // Reduced from 16.sp
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 400.ms)
            .slideX(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),

        SizedBox(height: 28.h), // Reduced from 32.h

        // Toggle Buttons with smooth transition
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleButton('Sign In', !_isSignUp, () {
              setState(() {
                _isSignUp = false;
                ref.read(authProvider.notifier).clearError();
              });
              _slideController.reverse();
            }),
            SizedBox(width: 14.w), // Reduced from 16.w
            _buildToggleButton('Sign Up', _isSignUp, () {
              setState(() {
                _isSignUp = true;
                ref.read(authProvider.notifier).clearError();
              });
              _slideController.forward();
            }),
          ],
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 600.ms, curve: Curves.easeOutBack),
      ],
    );
  }

  Widget _buildToggleButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h), // Reduced padding
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(22.r), // Reduced from 25.r
          border: isActive ? null : Border.all(color: AppTheme.inputBorder),
          boxShadow: isActive ? [
            BoxShadow(
              color: AppTheme.primaryYellow.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? AppTheme.darkBackground : AppTheme.textWhite,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp, // Reduced from 16.sp
          ),
        ),
      ),
    )
        .animate(target: isActive ? 1 : 0)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 200.ms);
  }

  Widget _buildForm(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Animated form fields
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: _isSignUp ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _isSignUp
                ? Column(
              key: const ValueKey('signup'),
              children: _buildSignUpFields(),
            )
                : Column(
              key: const ValueKey('signin'),
              children: _buildSignInFields(),
            ),
          ),

          SizedBox(height: 28.h), // Reduced from 32.h

          // Submit Button with loading animation
          SizedBox(
            height: 50.h, // Reduced from 56.h
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: AppTheme.darkBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r), // Reduced from 12.r
                ),
                elevation: 0,
                shadowColor: AppTheme.primaryYellow.withOpacity(0.3),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: authState.isLoading
                    ? SizedBox(
                  height: 20.h, // Reduced from 24.h
                  width: 20.w, // Reduced from 24.w
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkBackground),
                  ),
                )
                    : Text(
                  _isSignUp ? 'Create Account' : 'Sign In',
                  style: TextStyle(
                    fontSize: 16.sp, // Reduced from 18.sp
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
              .animate(target: authState.isLoading ? 1 : 0)
              .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.98, 0.98), duration: 100.ms),

          // Error Message with slide animation
          if (authState.error != null) ...[
            SizedBox(height: 14.h), // Reduced from 16.h
            Container(
              padding: EdgeInsets.all(14.w), // Reduced from 16.w
              decoration: BoxDecoration(
                color: authState.error!.contains('check your email')
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r), // Reduced from 12.r
                border: Border.all(
                  color: authState.error!.contains('check your email')
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    authState.error!.contains('check your email')
                        ? Icons.email_outlined
                        : Icons.error_outline,
                    color: authState.error!.contains('check your email')
                        ? Colors.blue.shade300
                        : Colors.red.shade300,
                    size: 18.sp, // Reduced from 20.sp
                  ),
                  SizedBox(width: 10.w), // Reduced from 12.w
                  Expanded(
                    child: Text(
                      authState.error!,
                      style: TextStyle(
                        color: authState.error!.contains('check your email')
                            ? Colors.blue.shade300
                            : Colors.red.shade300,
                        fontSize: 13.sp, // Reduced from 14.sp
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.5, end: 0, duration: 300.ms, curve: Curves.easeOutCubic)
                .shake(hz: 2, curve: Curves.easeInOut),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialLogin(AuthState authState) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppTheme.inputBorder)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w), // Reduced from 16.w
              child: Text(
                _isSignUp ? 'OR SIGN UP WITH' : 'OR CONTINUE WITH',
                style: TextStyle(
                  color: AppTheme.textGray,
                  fontSize: 12.sp, // Reduced from 14.sp
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppTheme.inputBorder)),
          ],
        ),
        SizedBox(height: 20.h), // Reduced from 24.h
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                'Google',
                Icons.g_mobiledata,
                    () => _handleGoogleLogin(),
                authState.isLoading,
              ),
            ),
            SizedBox(width: 14.w), // Reduced from 16.w
            Expanded(
              child: _buildSocialButton(
                'GitHub',
                Icons.code,
                    () => _handleGitHubLogin(),
                authState.isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String text, IconData icon, VoidCallback onPressed, bool isLoading) {
    return SizedBox(
      height: 46.h, // Reduced from 52.h
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.inputBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r), // Reduced from 12.r
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp, color: AppTheme.textWhite), // Reduced from 24.sp
            SizedBox(width: 10.w), // Reduced from 12.w
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp, // Reduced from 16.sp
                fontWeight: FontWeight.w500,
                color: AppTheme.textWhite,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 400.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 400.ms);
  }

  List<Widget> _buildSignInFields() {
    return [
      _buildInputField(
        label: 'Email',
        controller: _emailController,
        placeholder: 'Enter your email',
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your email';
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 100.ms)
          .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

      SizedBox(height: 18.h), // Reduced from 20.h

      _buildInputField(
        label: 'Password',
        controller: _passwordController,
        placeholder: 'Enter your password',
        isPassword: true,
        suffixWidget: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.textGray,
            size: 20.sp, // Reduced from 24.sp
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your password';
          return null;
        },
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
    ];
  }

  List<Widget> _buildSignUpFields() {
    return [
      Row(
        children: [
          Expanded(
            child: _buildInputField(
              label: 'First name',
              controller: _firstNameController,
              placeholder: 'John',
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                return null;
              },
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
          ),
          SizedBox(width: 14.w), // Reduced from 16.w
          Expanded(
            child: _buildInputField(
              label: 'Last name',
              controller: _lastNameController,
              placeholder: 'Doe',
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                return null;
              },
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 150.ms)
                .slideX(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
          ),
        ],
      ),
      SizedBox(height: 18.h), // Reduced from 20.h
      _buildInputField(
        label: 'Username (optional)',
        controller: _usernameController,
        placeholder: 'johndoe',
        validator: null,
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 200.ms)
          .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

      SizedBox(height: 18.h),
      _buildInputField(
        label: 'Email',
        controller: _signUpEmailController,
        placeholder: 'john@example.com',
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your email';
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 250.ms)
          .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

      SizedBox(height: 18.h),
      _buildInputField(
        label: 'Password',
        controller: _signUpPasswordController,
        placeholder: 'Create a strong password',
        isPassword: true,
        suffixWidget: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.textGray,
            size: 20.sp,
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter a password';
          if (value!.length < 6) return 'Password must be at least 6 characters';
          return null;
        },
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 300.ms)
          .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),

      SizedBox(height: 18.h),
      _buildInputField(
        label: 'Confirm Password',
        controller: _confirmPasswordController,
        placeholder: 'Confirm your password',
        isPassword: true,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please confirm your password';
          if (value != _signUpPasswordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 350.ms)
          .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
    ];
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    bool isPassword = false,
    Widget? suffixWidget,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 14.sp, // Reduced from 16.sp
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6.h), // Reduced from 8.h
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          validator: validator,
          keyboardType: keyboardType,
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 14.sp, // Reduced from 16.sp
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: AppTheme.textPlaceholder,
              fontSize: 14.sp, // Reduced from 16.sp
            ),
            filled: true,
            fillColor: AppTheme.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r), // Reduced from 12.r
              borderSide: BorderSide(color: AppTheme.inputBorder, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppTheme.inputBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: AppTheme.primaryYellow, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h), // Reduced padding
            suffixIcon: suffixWidget != null
                ? Padding(
              padding: EdgeInsets.only(right: 14.w), // Reduced from 16.w
              child: suffixWidget,
            )
                : null,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      bool success;

      if (_isSignUp) {
        success = await ref.read(authProvider.notifier).signUp(
          email: _signUpEmailController.text.trim(),
          password: _signUpPasswordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          username: _usernameController.text.trim().isEmpty
              ? null
              : _usernameController.text.trim(),
        );
      } else {
        success = await ref.read(authProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      if (success && mounted) {
        context.go('/home');
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final success = await ref.read(authProvider.notifier).signInWithGoogle();
      if (success) {
        print('✅ Google login initiated successfully');
      }
    } catch (e) {
      print('❌ Google login error: $e');
    }
  }

  Future<void> _handleGitHubLogin() async {
    try {
      final success = await ref.read(authProvider.notifier).signInWithGitHub();
      if (success) {
        print('✅ GitHub login initiated successfully');
      }
    } catch (e) {
      print('❌ GitHub login error: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _confirmPasswordController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}
