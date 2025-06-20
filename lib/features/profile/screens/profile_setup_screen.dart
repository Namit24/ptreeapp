import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/profile_setup_provider.dart';
import '../widgets/step_indicator.dart';
import '../widgets/profile_completion_card.dart';
import '../widgets/interest_skill_chip.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/profile_setup_success_dialog.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<String> _stepTitles = [
    'Personal Information',
    'Profile Photo',
    'Your Interests',
    'Your Skills',
    'Biography & Social Links',
  ];

  final List<String> _stepLabels = [
    'Personal',
    'Photo',
    'Interests',
    'Skills',
    'Bio',
  ];

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(profileSetupProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use responsive layout
            if (constraints.maxWidth > 800) {
              // Desktop/Tablet layout with sidebar
              return Row(
                children: [
                  // Left Sidebar
                  Container(
                    width: 350.w,
                    child: _buildSidebar(setupState),
                  ),

                  // Main Content
                  Expanded(
                    child: _buildMainContent(),
                  ),
                ],
              );
            } else {
              // Mobile layout - full screen
              return Column(
                children: [
                  // Compact header for mobile
                  _buildMobileHeader(setupState),

                  // Main Content
                  Expanded(
                    child: _buildMainContent(),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileHeader(ProfileSetupState setupState) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.darkerBackground,
        border: Border(
          bottom: BorderSide(color: AppTheme.inputBorder, width: 1),
        ),
      ),
      child: Column(
        children: [
          // App Header
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.account_tree_rounded,
                  color: AppTheme.darkBackground,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'ProjecTree',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textWhite,
                ),
              ),
              const Spacer(),
              Text(
                'Step ${_currentStep + 1} of 5',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.textGray,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Progress Bar
          Container(
            height: 4.h,
            decoration: BoxDecoration(
              color: AppTheme.inputBackground,
              borderRadius: BorderRadius.circular(2.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentStep + 1) / 5,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() => _currentStep = index);
      },
      children: [
        _PersonalInfoStep(onNext: _nextStep, onPrevious: _previousStep),
        _ProfilePhotoStep(onNext: _nextStep, onPrevious: _previousStep),
        _InterestsStep(onNext: _nextStep, onPrevious: _previousStep),
        _SkillsStep(onNext: _nextStep, onPrevious: _previousStep),
        _BiographyStep(onNext: _nextStep, onPrevious: _previousStep, onComplete: _completeProfile),
      ],
    );
  }

  Widget _buildSidebar(ProfileSetupState setupState) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.darkerBackground,
        border: Border(
          right: BorderSide(color: AppTheme.inputBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.account_tree_rounded,
                  color: AppTheme.darkBackground,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'ProjecTree',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          Text(
            'Welcome to ProjecTree',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Complete your profile to connect with other students, showcase your projects, and discover events on campus.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textGray,
              height: 1.4,
            ),
          ),

          SizedBox(height: 32.h),

          // Step Indicators
          StepIndicator(
            currentStep: _currentStep,
            totalSteps: 5,
            stepLabels: _stepLabels,
            onStepTap: _canNavigateToStep,
          ),

          SizedBox(height: 32.h),

          // Profile Completion Card
          ProfileCompletionCard(
            completionPercentage: setupState.completionPercentage,
            currentStep: _currentStep,
          ),

          const Spacer(),

          // Error Display
          if (setupState.error != null) ...[
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      setupState.error!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(profileSetupProvider.notifier).clearError(),
                    child: Icon(Icons.close, color: Colors.red, size: 16.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ],
      ),
    );
  }

  void _canNavigateToStep(int step) {
    // Allow navigation to completed steps or current step
    if (step <= _currentStep) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    final setupNotifier = ref.read(profileSetupProvider.notifier);

    // Validate current step
    if (!setupNotifier.validateStep(_currentStep)) {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getValidationMessage(_currentStep)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _getValidationMessage(int step) {
    switch (step) {
      case 0:
        return 'Please fill in all required personal information fields';
      case 2:
        return 'Please select at least one interest';
      case 3:
        return 'Please select at least one skill';
      default:
        return 'Please complete this step';
    }
  }

  Future<void> _completeProfile() async {
    try {
      final success = await ref.read(profileSetupProvider.notifier).completeProfile();
      if (success && mounted) {
        // Force refresh the auth state to get updated profile
        await ref.read(authProvider.notifier).refreshProfile();

        // Small delay to ensure state is updated
        await Future.delayed(const Duration(milliseconds: 500));

        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ProfileSetupSuccessDialog(
              onContinue: () {
                // Force navigation to home
                if (mounted) {
                  context.go('/home');
                }
              },
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error in _completeProfile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// Step 1: Personal Information
class _PersonalInfoStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _PersonalInfoStep({
    required this.onNext,
    required this.onPrevious,
  });

  @override
  ConsumerState<_PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends ConsumerState<_PersonalInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final setupState = ref.read(profileSetupProvider);

    // Pre-fill from existing data
    _firstNameController.text = setupState.personalInfo['first_name'] ?? '';
    _lastNameController.text = setupState.personalInfo['last_name'] ?? '';
    _usernameController.text = setupState.personalInfo['username'] ?? '';
    _locationController.text = setupState.personalInfo['location'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textWhite,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Let\'s start with the basics. This information will be displayed on your public profile.',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppTheme.textGray,
                height: 1.4,
              ),
            ),

            SizedBox(height: 32.h),

            // First Name & Last Name
            Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    label: 'First Name',
                    placeholder: 'Enter your first name',
                    controller: _firstNameController,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'First name is required';
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomInputField(
                    label: 'Last Name',
                    placeholder: 'Enter your last name',
                    controller: _lastNameController,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Last name is required';
                      return null;
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Username
            CustomInputField(
              label: 'Username',
              placeholder: 'Choose a unique username',
              controller: _usernameController,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Username is required';
                if (value!.length < 3) return 'Username must be at least 3 characters';
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                  return 'Username can only contain letters, numbers, and underscores';
                }
                return null;
              },
            ),

            SizedBox(height: 20.h),

            // Email (Read-only)
            CustomInputField(
              label: 'Email',
              placeholder: 'Your email address',
              controller: TextEditingController(text: user?.email ?? ''),
              readOnly: true,
            ),
            SizedBox(height: 4.h),
            Text(
              'Email cannot be changed',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textGray,
              ),
            ),

            SizedBox(height: 20.h),

            // Location
            CustomInputField(
              label: 'Location (Optional)',
              placeholder: 'City, Country',
              controller: _locationController,
            ),

            SizedBox(height: 40.h),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 120.w,
                  height: 48.h,
                  child: OutlinedButton(
                    onPressed: null, // Disabled on first step
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.inputBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppTheme.textGray,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 120.w,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _saveAndNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      foregroundColor: AppTheme.darkBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Next Step',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveAndNext() {
    if (_formKey.currentState?.validate() ?? false) {
      // Save data to provider
      ref.read(profileSetupProvider.notifier).updatePersonalInfo({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'location': _locationController.text.trim(),
      });

      // Navigate to next step
      widget.onNext();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

// Step 2: Profile Photo
class _ProfilePhotoStep extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _ProfilePhotoStep({
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(profileSetupProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Photo',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add a profile photo to help others recognize you. A clear, friendly headshot works best.',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textGray,
              height: 1.4,
            ),
          ),

          SizedBox(height: 40.h),

          // Profile Photo Section
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 160.w,
                      height: 160.h,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(80.r),
                        border: Border.all(
                          color: AppTheme.primaryYellow,
                          width: 4,
                        ),
                      ),
                      child: setupState.profileImagePath != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(76.r),
                        child: setupState.profileImageFile != null
                            ? Image.file(
                          setupState.profileImageFile!,
                          fit: BoxFit.cover,
                        )
                            : Image.network(
                          setupState.profileImagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildAvatarPlaceholder(setupState.avatarLetter);
                          },
                        ),
                      )
                          : _buildAvatarPlaceholder(setupState.avatarLetter),
                    ),
                    if (setupState.profileImagePath != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => ref.read(profileSetupProvider.notifier).removeProfileImage(),
                          child: Container(
                            width: 32.w,
                            height: 32.h,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    if (setupState.isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(80.r),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryYellow,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Change Photo Button
                SizedBox(
                  width: 160.w,
                  height: 48.h,
                  child: OutlinedButton.icon(
                    onPressed: setupState.isUploadingImage
                        ? null
                        : () => _showImagePicker(context, ref),
                    icon: Icon(
                      Icons.upload,
                      size: 20.sp,
                      color: AppTheme.textWhite,
                    ),
                    label: Text(
                      setupState.profileImagePath != null ? 'Change Photo' : 'Add Photo',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.inputBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 40.h),

          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 120.w,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 120.w,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Next Step',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String letter) {
    return Center(
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 60.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryYellow,
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.inputBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppTheme.textGray,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Select Photo',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textWhite,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: _buildImageOption(
                    context,
                    ref,
                    'Camera',
                    Icons.camera_alt,
                    ImageSource.camera,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildImageOption(
                    context,
                    ref,
                    'Gallery',
                    Icons.photo_library,
                    ImageSource.gallery,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(
      BuildContext context,
      WidgetRef ref,
      String label,
      IconData icon,
      ImageSource source,
      ) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        await ref.read(profileSetupProvider.notifier).pickImage(source);
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.darkerBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.sp,
              color: AppTheme.primaryYellow,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Step 3: Interests
class _InterestsStep extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _InterestsStep({
    required this.onNext,
    required this.onPrevious,
  });

  final List<Map<String, dynamic>> _interestCategories = const [
    {
      'title': 'Technology',
      'interests': [
        'Web Development', 'Mobile Apps', 'AI & Machine Learning', 'Blockchain',
        'IoT', 'Cloud Computing', 'Cybersecurity', 'Data Science'
      ],
    },
    {
      'title': 'Business',
      'interests': [
        'Startups', 'Entrepreneurship', 'Marketing', 'Finance',
        'Product Management', 'E-commerce', 'Remote Work', 'Leadership'
      ],
    },
    {
      'title': 'Creative',
      'interests': [
        'Design', 'UI/UX', 'Photography', 'Video Production',
        'Writing', 'Music', 'Animation', '3D Modeling'
      ],
    },
    {
      'title': 'Personal',
      'interests': [
        'Travel', 'Fitness', 'Gaming', 'Reading',
        'Cooking', 'Sustainability', 'Mental Health', 'Productivity'
      ],
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(profileSetupProvider);
    final customInterestController = TextEditingController();

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Interests',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Select interests that matter to you. This helps us connect you with relevant projects and people.',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textGray,
              height: 1.4,
            ),
          ),

          SizedBox(height: 24.h),

          // Add Custom Interest
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: customInterestController,
                  style: TextStyle(color: AppTheme.textWhite, fontSize: 16.sp),
                  decoration: InputDecoration(
                    hintText: 'Add a custom interest...',
                    hintStyle: TextStyle(color: AppTheme.textPlaceholder, fontSize: 16.sp),
                    filled: true,
                    fillColor: AppTheme.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppTheme.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppTheme.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppTheme.primaryYellow, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                  ),
                  onFieldSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      ref.read(profileSetupProvider.notifier).addInterest(value.trim());
                      customInterestController.clear();
                    }
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 48.w,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (customInterestController.text.trim().isNotEmpty) {
                      ref.read(profileSetupProvider.notifier).addInterest(customInterestController.text.trim());
                      customInterestController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(Icons.add, size: 24.sp),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Selected Interests
          if (setupState.selectedInterests.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.inputBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.inputBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryYellow,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Selected Interests (${setupState.selectedInterests.length})',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textWhite,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: setupState.selectedInterests.map((interest) {
                      return InterestSkillChip(
                        label: interest,
                        isSelected: true,
                        showRemove: true,
                        onTap: () => ref.read(profileSetupProvider.notifier).removeInterest(interest),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // Interest Categories
          ..._interestCategories.map((category) {
            return _buildInterestCategory(
              context,
              ref,
              category['title'],
              category['interests'],
              setupState.selectedInterests,
            );
          }).toList(),

          SizedBox(height: 40.h),

          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 120.w,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 120.w,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: setupState.selectedInterests.isEmpty ? null : onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Next Step',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterestCategory(
      BuildContext context,
      WidgetRef ref,
      String title,
      List<String> interests,
      List<String> selectedInterests,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: interests.map((interest) {
              final isSelected = selectedInterests.contains(interest);
              return InterestSkillChip(
                label: interest,
                isSelected: isSelected,
                onTap: () {
                  if (isSelected) {
                    ref.read(profileSetupProvider.notifier).removeInterest(interest);
                  } else {
                    ref.read(profileSetupProvider.notifier).addInterest(interest);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Step 4: Skills
class _SkillsStep extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _SkillsStep({
    required this.onNext,
    required this.onPrevious,
  });

  final List<Map<String, dynamic>> _skillCategories = const [
    {
      'title': 'Programming Languages',
      'skills': [
        'JavaScript', 'TypeScript', 'Python', 'Java', 'C#', 'Go', 'Ruby', 'PHP', 'Swift', 'Kotlin'
      ],
    },
    {
      'title': 'Frontend',
      'skills': [
        'React', 'Vue', 'Angular', 'Next.js', 'Svelte', 'HTML', 'CSS', 'Tailwind CSS', 'SASS', 'Redux'
      ],
    },
    {
      'title': 'Backend',
      'skills': [
        'Node.js', 'Express', 'Django', 'Flask', 'Spring Boot', 'Laravel', 'ASP.NET', 'GraphQL', 'REST API', 'Microservices'
      ],
    },
    {
      'title': 'DevOps & Tools',
      'skills': [
        'Git', 'Docker', 'Kubernetes', 'AWS', 'Azure', 'GCP', 'CI/CD', 'Linux', 'Bash', 'Terraform'
      ],
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(profileSetupProvider);
    final customSkillController = TextEditingController();

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Skills',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add skills that showcase your expertise. This helps others understand your strengths and capabilities.',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textGray,
              height: 1.4,
            ),
          ),

          SizedBox(height: 24.h),

          // Add Custom Skill
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: customSkillController,
                  style: TextStyle(color: AppTheme.textWhite, fontSize: 16.sp),
                  decoration: InputDecoration(
                    hintText: 'Add a custom skill...',
                    hintStyle: TextStyle(color: AppTheme.textPlaceholder, fontSize: 16.sp),
                    filled: true,
                    fillColor: AppTheme.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppTheme.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppTheme.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppTheme.primaryYellow, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                  ),
                  onFieldSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      ref.read(profileSetupProvider.notifier).addSkill(value.trim());
                      customSkillController.clear();
                    }
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 48.w,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (customSkillController.text.trim().isNotEmpty) {
                      ref.read(profileSetupProvider.notifier).addSkill(customSkillController.text.trim());
                      customSkillController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(Icons.add, size: 24.sp),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Selected Skills
          if (setupState.selectedSkills.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.inputBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.inputBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: AppTheme.primaryYellow,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Selected Skills (${setupState.selectedSkills.length})',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textWhite,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: setupState.selectedSkills.map((skill) {
                      return InterestSkillChip(
                        label: skill,
                        isSelected: true,
                        showRemove: true,
                        onTap: () => ref.read(profileSetupProvider.notifier).removeSkill(skill),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],

          // Skill Categories
          ..._skillCategories.map((category) {
            return _buildSkillCategory(
              context,
              ref,
              category['title'],
              category['skills'],
              setupState.selectedSkills,
            );
          }).toList(),

          SizedBox(height: 40.h),

          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 120.w,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 120.w,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: setupState.selectedSkills.isEmpty ? null : onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Next Step',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCategory(
      BuildContext context,
      WidgetRef ref,
      String title,
      List<String> skills,
      List<String> selectedSkills,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: skills.map((skill) {
              final isSelected = selectedSkills.contains(skill);
              return InterestSkillChip(
                label: skill,
                isSelected: isSelected,
                onTap: () {
                  if (isSelected) {
                    ref.read(profileSetupProvider.notifier).removeSkill(skill);
                  } else {
                    ref.read(profileSetupProvider.notifier).addSkill(skill);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Step 5: Biography & Social Links
class _BiographyStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onComplete;

  const _BiographyStep({
    required this.onNext,
    required this.onPrevious,
    required this.onComplete,
  });

  @override
  ConsumerState<_BiographyStep> createState() => _BiographyStepState();
}

class _BiographyStepState extends ConsumerState<_BiographyStep> {
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  final _githubController = TextEditingController();
  final _twitterController = TextEditingController();
  final _linkedinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final setupState = ref.read(profileSetupProvider);

    // Pre-fill from existing data
    _bioController.text = setupState.biography['bio'] ?? '';
    _websiteController.text = setupState.biography['website'] ?? '';
    _githubController.text = setupState.biography['github'] ?? '';
    _twitterController.text = setupState.biography['twitter'] ?? '';
    _linkedinController.text = setupState.biography['linkedin'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(profileSetupProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biography & Social Links',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tell others about yourself and connect your social profiles to enhance your network.',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textGray,
              height: 1.4,
            ),
          ),

          SizedBox(height: 24.h),

          // Bio Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bio',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textWhite,
                    ),
                  ),
                  GestureDetector(
                    onTap: setupState.isGeneratingBio
                        ? null
                        : () => ref.read(profileSetupProvider.notifier).generateAIBio(),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (setupState.isGeneratingBio) ...[
                            SizedBox(
                              width: 12.w,
                              height: 12.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(AppTheme.primaryYellow),
                              ),
                            ),
                            SizedBox(width: 6.w),
                          ] else ...[
                            Icon(
                              Icons.auto_awesome,
                              size: 16.sp,
                              color: AppTheme.primaryYellow,
                            ),
                            SizedBox(width: 6.w),
                          ],
                          Text(
                            setupState.isGeneratingBio ? 'Generating...' : 'Generate with AI',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppTheme.primaryYellow,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 300,
                style: TextStyle(color: AppTheme.textWhite, fontSize: 16.sp),
                decoration: InputDecoration(
                  hintText: 'Write a short bio about yourself...',
                  hintStyle: TextStyle(color: AppTheme.textPlaceholder, fontSize: 16.sp),
                  filled: true,
                  fillColor: AppTheme.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppTheme.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppTheme.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppTheme.primaryYellow, width: 2),
                  ),
                  contentPadding: EdgeInsets.all(20.w),
                  counterStyle: TextStyle(
                    color: AppTheme.textGray,
                    fontSize: 12.sp,
                  ),
                ),
                onChanged: (value) {
                  // Auto-save bio changes
                  ref.read(profileSetupProvider.notifier).updateBiography({
                    'bio': value,
                  });
                },
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Social Profiles Section
          Text(
            'Social Profiles (Optional)',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 16.h),

          // Website
          CustomInputField(
            label: 'Personal Website',
            placeholder: 'https://yourwebsite.com',
            controller: _websiteController,
          ),

          SizedBox(height: 16.h),

          // GitHub
          CustomInputField(
            label: 'GitHub',
            placeholder: 'github.com/username',
            controller: _githubController,
          ),

          SizedBox(height: 16.h),

          // LinkedIn
          CustomInputField(
            label: 'LinkedIn',
            placeholder: 'linkedin.com/in/username',
            controller: _linkedinController,
          ),

          SizedBox(height: 16.h),

          // Twitter
          CustomInputField(
            label: 'Twitter',
            placeholder: 'twitter.com/username',
            controller: _twitterController,
          ),

          SizedBox(height: 40.h),

          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 120.w,
                height: 48.h,
                child: OutlinedButton(
                  onPressed: widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 140.w,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: setupState.isLoading ? null : _completeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: setupState.isLoading
                      ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppTheme.darkBackground),
                    ),
                  )
                      : Text(
                    'Complete Profile',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _completeProfile() {
    // Save biography data
    ref.read(profileSetupProvider.notifier).updateBiography({
      'bio': _bioController.text.trim(),
      'website': _websiteController.text.trim(),
      'github': _githubController.text.trim(),
      'twitter': _twitterController.text.trim(),
      'linkedin': _linkedinController.text.trim(),
    });

    // Complete profile
    widget.onComplete();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _websiteController.dispose();
    _githubController.dispose();
    _twitterController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }
}
