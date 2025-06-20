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

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
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
                SizedBox(height: 60.h),

                // Header Section - FIXED SPACING
                _buildHeader(),

                SizedBox(height: 40.h),

                // Form Section - FIXED SPACING
                _buildForm(authState),

                SizedBox(height: 32.h),

                // Social Login Section - FIXED SPACING
                _buildSocialLogin(authState),

                SizedBox(height: 40.h),
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
        // Logo - CENTERED AND BIGGER
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppTheme.primaryYellow,
            borderRadius: BorderRadius.circular(20.r),
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
            size: 40.sp,
          ),
        ),

        SizedBox(height: 32.h),

        Text(
          'Welcome to ProjecTree',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          'Your journey starts here. Join our community and\ndiscover the power of collaborative innovations.',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 16.sp,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32.h),

        // Toggle Buttons - CENTERED
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleButton('Sign In', !_isSignUp, () {
              setState(() => _isSignUp = false);
            }),
            SizedBox(width: 16.w),
            _buildToggleButton('Sign Up', _isSignUp, () {
              setState(() => _isSignUp = true);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(25.r),
          border: isActive ? null : Border.all(color: AppTheme.inputBorder),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? AppTheme.darkBackground : AppTheme.textWhite,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildForm(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isSignUp) ..._buildSignUpFields() else ..._buildSignInFields(),

          SizedBox(height: 32.h),

          // Submit Button - IMPROVED
          SizedBox(
            height: 56.h,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: AppTheme.darkBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: authState.isLoading
                  ? SizedBox(
                height: 24.h,
                width: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkBackground),
                ),
              )
                  : Text(
                _isSignUp ? 'Create Account' : 'Sign In',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Error Message
          if (authState.error != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                authState.error!,
                style: TextStyle(
                  color: Colors.red.shade300,
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // IMPROVED Social Login Section
  Widget _buildSocialLogin(AuthState authState) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppTheme.inputBorder)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                _isSignUp ? 'OR SIGN UP WITH' : 'OR CONTINUE WITH',
                style: TextStyle(
                  color: AppTheme.textGray,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppTheme.inputBorder)),
          ],
        ),
        SizedBox(height: 24.h),
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
            SizedBox(width: 16.w),
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

        // DEMO LOGIN HINT
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryYellow.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                '🚀 Demo Mode',
                style: TextStyle(
                  color: AppTheme.primaryYellow,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Try: demo@projectree.com / password123\nOr configure your Supabase project for full functionality',
                style: TextStyle(
                  color: AppTheme.textGray,
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String text, IconData icon, VoidCallback onPressed, bool isLoading) {
    return SizedBox(
      height: 52.h,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.inputBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24.sp, color: AppTheme.textWhite),
            SizedBox(width: 12.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSignInFields() {
    return [
      _buildInputField(
        label: 'Email or Username',
        controller: _emailController,
        placeholder: 'demo@projectree.com',
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your email or username';
          return null;
        },
      ),
      SizedBox(height: 20.h),
      _buildInputField(
        label: 'Password',
        controller: _passwordController,
        placeholder: 'password123',
        isPassword: true,
        suffixWidget: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.textGray,
            size: 24.sp,
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your password';
          return null;
        },
      ),
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
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: _buildInputField(
              label: 'Last name',
              controller: _lastNameController,
              placeholder: 'Doe',
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                return null;
              },
            ),
          ),
        ],
      ),
      SizedBox(height: 20.h),
      _buildInputField(
        label: 'Username',
        controller: _usernameController,
        placeholder: 'johndoe',
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter a username';
          return null;
        },
      ),
      SizedBox(height: 20.h),
      _buildInputField(
        label: 'Email',
        controller: _signUpEmailController,
        placeholder: 'john@projectree.com',
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your email';
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
      SizedBox(height: 20.h),
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
            size: 24.sp,
          ),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter a password';
          if (value!.length < 6) return 'Password must be at least 6 characters';
          return null;
        },
      ),
    ];
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    bool isPassword = false,
    Widget? suffixWidget,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          validator: validator,
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 16.sp,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: AppTheme.textPlaceholder,
              fontSize: 16.sp,
            ),
            filled: true,
            fillColor: AppTheme.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.inputBorder, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.inputBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppTheme.primaryYellow, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            suffixIcon: suffixWidget != null
                ? Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: suffixWidget,
            )
                : null,
            suffixIconConstraints: BoxConstraints(
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
      // DEMO LOGIN - Check for demo credentials
      if (!_isSignUp &&
          _emailController.text.trim() == 'demo@projectree.com' &&
          _passwordController.text == 'password123') {

        // Simulate successful login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Demo login successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home (this will show mock data)
        context.go('/home');
        return;
      }

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

  // Social Login Handlers with better error handling
  Future<void> _handleGoogleLogin() async {
    try {
      // Show info about Supabase configuration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Configure your Supabase project first!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      final success = await ref.read(authProvider.notifier).signInWithGoogle();
      if (success && mounted) {
        print('Google login initiated successfully');
      }
    } catch (e) {
      print('Google login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google login failed. Configure Supabase first.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGitHubLogin() async {
    try {
      // Show info about Supabase configuration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Configure your Supabase project first!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      final success = await ref.read(authProvider.notifier).signInWithGitHub();
      if (success && mounted) {
        print('GitHub login initiated successfully');
      }
    } catch (e) {
      print('GitHub login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GitHub login failed. Configure Supabase first.'),
          backgroundColor: Colors.red,
        ),
      );
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
    super.dispose();
  }
}
