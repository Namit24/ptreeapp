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
              const Color(0xFF4A5568), // Grayish blue
              AppTheme.darkBackground,
              AppTheme.darkerBackground,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40.h), // Reduced height

                  // Header Section
                  _buildHeader().animate().fadeIn(duration: 800.ms).slideY(begin: -0.3),

                  SizedBox(height: 40.h), // Reduced height

                  // Form Section
                  _buildForm(authState).animate().fadeIn(duration: 800.ms, delay: 200.ms),

                  SizedBox(height: 24.h), // Reduced height

                  // Social Login Section
                  _buildSocialLogin().animate().fadeIn(duration: 800.ms, delay: 400.ms),

                  SizedBox(height: 30.h), // Reduced height
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to ProjecTree',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        SizedBox(height: 12.h), // Reduced height
        Text(
          'Your journey starts here. Join our community and\ndiscover the power of collaborative innovations.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 24.h), // Reduced height

        // Toggle Buttons
        Row(
          children: [
            _buildToggleButton('Sign In', !_isSignUp, () {
              setState(() => _isSignUp = false);
            }),
            SizedBox(width: 12.w), // Reduced width
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h), // Reduced padding
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r), // Reduced radius
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isActive ? AppTheme.darkBackground : AppTheme.textWhite,
            fontWeight: FontWeight.w600,
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

          SizedBox(height: 24.h), // Reduced height

          // Submit Button
          SizedBox(
            height: 48.h, // Reduced from 56
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _handleSubmit,
              child: authState.isLoading
                  ? SizedBox(
                height: 20.h, // Reduced size
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkBackground),
                ),
              )
                  : Text(_isSignUp ? 'Create Account' : 'Sign In'),
            ),
          ),

          // Error Message
          if (authState.error != null) ...[
            SizedBox(height: 12.h), // Reduced height
            Container(
              padding: EdgeInsets.all(10.w), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                authState.error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red.shade300,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildSignInFields() {
    return [
      _buildInputField(
        label: 'Email or Username',
        controller: _emailController,
        placeholder: 'Enter your email or username',
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your email or username';
          return null;
        },
      ),
      SizedBox(height: 16.h), // Reduced height
      _buildInputField(
        label: 'Password',
        controller: _passwordController,
        placeholder: 'Enter your password',
        isPassword: true,
        suffixWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                // Handle forgot password
              },
              child: Text(
                'Forgot password?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryYellow,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp, // Smaller font
                ),
              ),
            ),
            SizedBox(width: 8.w), // Reduced width
            GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textGray,
                size: 18.sp, // Reduced size
              ),
            ),
          ],
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
          SizedBox(width: 12.w), // Reduced width
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
      SizedBox(height: 16.h), // Reduced height
      _buildInputField(
        label: 'Username',
        controller: _usernameController,
        placeholder: 'johndoe',
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter a username';
          return null;
        },
      ),
      SizedBox(height: 16.h),
      _buildInputField(
        label: 'Email',
        controller: _signUpEmailController,
        placeholder: 'projectree@example.com',
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your email';
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
      SizedBox(height: 16.h),
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
            size: 18.sp, // Reduced size
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
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(height: 6.h), // Reduced height
        TextFormField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          validator: validator,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textWhite,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            suffixIcon: suffixWidget != null
                ? Padding(
              padding: EdgeInsets.only(right: 8.w), // Reduced padding
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

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Text(
          _isSignUp ? 'OR SIGN UP WITH' : 'OR CONTINUE WITH',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textGray,
            fontSize: 11.sp, // Reduced font size
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h), // Reduced height
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                'GitHub',
                Icons.code,
                    () => _handleGitHubLogin(),
              ),
            ),
            SizedBox(width: 12.w), // Reduced width
            Expanded(
              child: _buildSocialButton(
                'Google',
                Icons.g_mobiledata,
                    () => _handleGoogleLogin(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      height: 44.h, // Reduced from 52
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp), // Reduced size
            SizedBox(width: 6.w), // Reduced width
            Text(text),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      bool success;

      if (_isSignUp) {
        success = await ref.read(authProvider.notifier).register({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'username': _usernameController.text.trim(),
          'email': _signUpEmailController.text.trim(),
          'password': _signUpPasswordController.text,
        });
      } else {
        success = await ref.read(authProvider.notifier).login(
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Google login coming soon!'),
        backgroundColor: AppTheme.primaryYellow,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleGitHubLogin() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('GitHub login coming soon!'),
        backgroundColor: AppTheme.primaryYellow,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
