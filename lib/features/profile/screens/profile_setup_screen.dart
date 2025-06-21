import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  late AnimationController _slideController;
  late AnimationController _progressController;

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
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(profileSetupProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return Row(
                children: [
                  Container(
                    width: 320.w,
                    child: _buildSidebar(setupState)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideX(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
                  ),
                  Expanded(
                    child: _buildMainContent()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideX(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildMobileHeader(setupState)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                  Expanded(
                    child: _buildMainContent()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
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
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppTheme.darkerBackground,
        border: Border(
          bottom: BorderSide(color: AppTheme.inputBorder, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow,
                  borderRadius: BorderRadius.circular(7.r),
                ),
                child: Icon(
                  Icons.account_tree_rounded,
                  color: AppTheme.darkBackground,
                  size: 16.sp,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1), duration: 2000.ms),
              
              SizedBox(width: 10.w),
              Text(
                'ProjecTree',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textWhite,
                ),
              ),
              const Spacer(),
              Text(
                'Step ${_currentStep + 1} of 5',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textGray,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 14.h),
          
          Container(
            height: 3.h,
            decoration: BoxDecoration(
              color: AppTheme.inputBackground,
              borderRadius: BorderRadius.circular(1.5.r),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: MediaQuery.of(context).size.width * ((_currentStep + 1) / 5) - 28.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow,
                borderRadius: BorderRadius.circular(1.5.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryYellow.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
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
        _slideController.reset();
        _slideController.forward();
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
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.darkerBackground,
        border: Border(
          right: BorderSide(color: AppTheme.inputBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(
                  Icons.account_tree_rounded,
                  color: AppTheme.darkBackground,
                  size: 20.sp,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.05, 1.05), duration: 2000.ms),
              
              SizedBox(width: 10.w),
              Text(
                'ProjecTree',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textWhite,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20.h),
          
          Text(
            'Welcome to ProjecTree',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textWhite,
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 300.ms)
              .slideY(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 10.h),
          Text(
            'Complete your profile to connect with other students, showcase your projects, and discover events on campus.',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textGray,
              height: 1.4,
            ),
          )
              .animate()
              .fadeIn(duration: 800.ms, delay: 500.ms)
              .slideY(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 28.h),
          
          StepIndicator(
            currentStep: _currentStep,
            totalSteps: 5,
            stepLabels: _stepLabels,
            onStepTap: _canNavigateToStep,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 700.ms)
              .slideX(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 28.h),
          
          ProfileCompletionCard(
            completionPercentage: setupState.completionPercentage,
            currentStep: _currentStep,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 900.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 600.ms, curve: Curves.easeOutBack),
          
          const Spacer(),
          
          if (setupState.error != null) ...[
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 14.sp),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      setupState.error!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(profileSetupProvider.notifier).clearError(),
                    child: Icon(Icons.close, color: Colors.red, size: 14.sp),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .shake(hz: 3, curve: Curves.easeInOut)
                .slideY(begin: 0.3, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
            SizedBox(height: 14.h),
          ],
        ],
      ),
    );
  }

  void _canNavigateToStep(int step) {
    if (step <= _currentStep) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    final setupNotifier = ref.read(profileSetupProvider.notifier);
    
    if (!setupNotifier.validateStep(_currentStep)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getValidationMessage(_currentStep)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      );
      return;
    }

    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
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
        await ref.read(authProvider.notifier).refreshProfile();
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ProfileSetupSuccessDialog(
              onContinue: () {
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideController.dispose();
    _progressController.dispose();
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
      padding: EdgeInsets.all(20.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textWhite,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
            
            SizedBox(height: 6.h),
            Text(
              'Let\'s start with the basics. This information will be displayed on your public profile.',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textGray,
                height: 1.4,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
            
            SizedBox(height: 28.h),
            
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
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: CustomInputField(
                    label: 'Last Name',
                    placeholder: 'Enter your last name',
                    controller: _lastNameController,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Last name is required';
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 500.ms)
                      .slideX(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                ),
              ],
            ),
            
            SizedBox(height: 18.h),
            
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
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 600.ms)
                .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
            
            SizedBox(height: 18.h),
            
            CustomInputField(
              label: 'Email',
              placeholder: 'Your email address',
              controller: TextEditingController(text: user?.email ?? ''),
              readOnly: true,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 700.ms)
                .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
            
            SizedBox(height: 3.h),
            Text(
              'Email cannot be changed',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppTheme.textGray,
              ),
            ),
            
            SizedBox(height: 18.h),
            
            CustomInputField(
              label: 'Location (Optional)',
              placeholder: 'City, Country',
              controller: _locationController,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 800.ms)
                .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
            
            SizedBox(height: 36.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 110.w,
                  height: 44.h,
                  child: OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.inputBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textGray,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 110.w,
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed: _saveAndNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      foregroundColor: AppTheme.darkBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Next Step',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 400.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 400.ms, delay: 900.ms),
              ],
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 1000.ms)
                .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }

  void _saveAndNext() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(profileSetupProvider.notifier).updatePersonalInfo({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'location': _locationController.text.trim(),
      });
      
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
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Photo',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textWhite,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 6.h),
          Text(
            'Add a profile photo to help others recognize you. A clear, friendly headshot works best.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textGray,
              height: 1.4,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 36.h),
          
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 140.w,
                      height: 140.h,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(70.r),
                        border: Border.all(
                          color: AppTheme.primaryYellow,
                          width: 3,
                        ),
                      ),
                      child: setupState.profileImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(67.r),
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
                    )
                        .animate()
                        .fadeIn(duration: 800.ms, delay: 400.ms)
                        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 800.ms, curve: Curves.easeOutBack),
                    
                    if (setupState.profileImagePath != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => ref.read(profileSetupProvider.notifier).removeProfileImage(),
                          child: Container(
                            width: 28.w,
                            height: 28.h,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), duration: 300.ms, curve: Curves.easeOutBack),
                    
                    if (setupState.isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(70.r),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryYellow,
                            )
                                .animate(onPlay: (controller) => controller.repeat())
                                .rotate(duration: 1000.ms),
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                SizedBox(
                  width: 140.w,
                  height: 44.h,
                  child: OutlinedButton.icon(
                    onPressed: setupState.isUploadingImage 
                        ? null 
                        : () => _showImagePicker(context, ref),
                    icon: Icon(
                      Icons.upload,
                      size: 18.sp,
                      color: AppTheme.textWhite,
                    ),
                    label: Text(
                      setupState.profileImagePath != null ? 'Change Photo' : 'Add Photo',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textWhite,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.inputBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
                    .then(delay: 200.ms)
                    .shimmer(duration: 2000.ms, color: AppTheme.primaryYellow.withOpacity(0.3)),
              ],
            ),
          ),
          
          SizedBox(height: 36.h),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 110.w,
                height: 44.h,
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 110.w,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Next Step',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 800.ms)
              .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String letter) {
    return Center(
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 50.sp,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: AppTheme.textGray,
                borderRadius: BorderRadius.circular(1.5.r),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), duration: 300.ms),
            
            SizedBox(height: 18.h),
            Text(
              'Select Photo',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textWhite,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
            
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: _buildImageOption(
                    context,
                    ref,
                    'Camera',
                    Icons.camera_alt,
                    ImageSource.camera,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: _buildImageOption(
                    context,
                    ref,
                    'Gallery',
                    Icons.photo_library,
                    ImageSource.gallery,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 300.ms)
                      .slideX(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                ),
              ],
            ),
            SizedBox(height: 20.h),
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
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: AppTheme.darkerBackground,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28.sp,
              color: AppTheme.primaryYellow,
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
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
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Interests',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textWhite,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 6.h),
          Text(
            'Select interests that matter to you. This helps us connect you with relevant projects and people.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textGray,
              height: 1.4,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 20.h),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: customInterestController,
                  style: TextStyle(color: AppTheme.textWhite, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Add a custom interest...',
                    hintStyle: TextStyle(color: AppTheme.textPlaceholder, fontSize: 14.sp),
                    filled: true,
                    fillColor: AppTheme.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: AppTheme.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: AppTheme.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: AppTheme.primaryYellow, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                  ),
                  onFieldSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      ref.read(profileSetupProvider.notifier).addInterest(value.trim());
                      customInterestController.clear();
                    }
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 44.w,
                height: 44.h,
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
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(Icons.add, size: 20.sp),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 20.h),
          
          if (setupState.selectedInterests.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppTheme.inputBackground,
                borderRadius: BorderRadius.circular(10.r),
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
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Selected Interests (${setupState.selectedInterests.length})',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textWhite,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: setupState.selectedInterests.asMap().entries.map((entry) {
                      final index = entry.key;
                      final interest = entry.value;
                      return InterestSkillChip(
                        label: interest,
                        isSelected: true,
                        showRemove: true,
                        onTap: () => ref.read(profileSetupProvider.notifier).removeInterest(interest),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 300.ms, curve: Curves.easeOutBack);
                    }).toList(),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 600.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
            SizedBox(height: 20.h),
          ],
          
          ..._interestCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return _buildInterestCategory(
              context,
              ref,
              category['title'],
              category['interests'],
              setupState.selectedInterests,
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: (800 + index * 200).ms)
                .slideX(begin: index.isEven ? -0.3 : 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
          }).toList(),
          
          SizedBox(height: 36.h),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 110.w,
                height: 44.h,
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 110.w,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: setupState.selectedInterests.isEmpty ? null : onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Next Step',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 1400.ms)
              .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
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
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: interests.asMap().entries.map((entry) {
              final index = entry.key;
              final interest = entry.value;
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
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: (index * 30).ms)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 300.ms, curve: Curves.easeOutBack);
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
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Skills',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textWhite,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 6.h),
          Text(
            'Add skills that showcase your expertise. This helps others understand your strengths and capabilities.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textGray,
              height: 1.4,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 20.h),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: customSkillController,
                  style: TextStyle(color: AppTheme.textWhite, fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Add a custom skill...',
                    hintStyle: TextStyle(color: AppTheme.textPlaceholder, fontSize: 14.sp),
                    filled: true,
                    fillColor: AppTheme.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: AppTheme.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: AppTheme.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: AppTheme.primaryYellow, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                  ),
                  onFieldSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      ref.read(profileSetupProvider.notifier).addSkill(value.trim());
                      customSkillController.clear();
                    }
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 44.w,
                height: 44.h,
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
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Icon(Icons.add, size: 20.sp),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 20.h),
          
          if (setupState.selectedSkills.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppTheme.inputBackground,
                borderRadius: BorderRadius.circular(10.r),
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
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Selected Skills (${setupState.selectedSkills.length})',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textWhite,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: setupState.selectedSkills.asMap().entries.map((entry) {
                      final index = entry.key;
                      final skill = entry.value;
                      return InterestSkillChip(
                        label: skill,
                        isSelected: true,
                        showRemove: true,
                        onTap: () => ref.read(profileSetupProvider.notifier).removeSkill(skill),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (index * 50).ms)
                          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 300.ms, curve: Curves.easeOutBack);
                    }).toList(),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 600.ms)
                .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
            SizedBox(height: 20.h),
          ],
          
          ..._skillCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return _buildSkillCategory(
              context,
              ref,
              category['title'],
              category['skills'],
              setupState.selectedSkills,
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: (800 + index * 200).ms)
                .slideX(begin: index.isEven ? -0.3 : 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
          }).toList(),
          
          SizedBox(height: 36.h),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 110.w,
                height: 44.h,
                child: OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 110.w,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: setupState.selectedSkills.isEmpty ? null : onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Next Step',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 1400.ms)
              .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
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
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textWhite,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: skills.asMap().entries.map((entry) {
              final index = entry.key;
              final skill = entry.value;
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
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: (index * 30).ms)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 300.ms, curve: Curves.easeOutBack);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Step 5: Biography
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
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biography & Social Links',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textWhite,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 6.h),
          Text(
            'Tell others about yourself and connect your social profiles to enhance your network.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textGray,
              height: 1.4,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 20.h),
          
          // Bio Section with AI generation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bio',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textWhite,
                    ),
                  ),
                  GestureDetector(
                    onTap: setupState.isGeneratingBio 
                        ? null 
                        : () async {
                        await ref.read(profileSetupProvider.notifier).generateAIBio();
                        final updatedState = ref.read(profileSetupProvider);
                        final generatedBio = updatedState.biography['bio'];
                        if (generatedBio != null && generatedBio.isNotEmpty) {
                          _bioController.text = generatedBio;
                        }
                      },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (setupState.isGeneratingBio) ...[
                            SizedBox(
                              width: 10.w,
                              height: 10.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(AppTheme.primaryYellow),
                              ),
                            ),
                            SizedBox(width: 5.w),
                          ] else ...[
                            Icon(
                              Icons.auto_awesome,
                              size: 14.sp,
                              color: AppTheme.primaryYellow,
                            ),
                            SizedBox(width: 5.w),
                          ],
                          Text(
                            setupState.isGeneratingBio ? 'Generating...' : 'Generate with AI',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppTheme.primaryYellow,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 600.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 400.ms, curve: Curves.easeOutBack),
                ],
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 300,
                style: TextStyle(color: AppTheme.textWhite, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Write a short bio about yourself...',
                  hintStyle: TextStyle(color: AppTheme.textPlaceholder, fontSize: 14.sp),
                  filled: true,
                  fillColor: AppTheme.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppTheme.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppTheme.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppTheme.primaryYellow, width: 2),
                  ),
                  contentPadding: EdgeInsets.all(18.w),
                  counterStyle: TextStyle(
                    color: AppTheme.textGray,
                    fontSize: 11.sp,
                  ),
                ),
                onChanged: (value) {
                  ref.read(profileSetupProvider.notifier).updateBiography({
                    'bio': value,
                  });
                },
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
            ],
          ),
          
          SizedBox(height: 20.h),
          
          // Social Profiles Section
          Text(
            'Social Profiles (Optional)',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textWhite,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 700.ms)
              .slideX(begin: -0.3, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 14.h),
          
          // Website
          CustomInputField(
            label: 'Personal Website',
            placeholder: 'https://yourwebsite.com',
            controller: _websiteController,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 800.ms)
              .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 14.h),
          
          // GitHub
          CustomInputField(
            label: 'GitHub',
            placeholder: 'github.com/username',
            controller: _githubController,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 900.ms)
              .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 14.h),
          
          // LinkedIn
          CustomInputField(
            label: 'LinkedIn',
            placeholder: 'linkedin.com/in/username',
            controller: _linkedinController,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 1000.ms)
              .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 14.h),
          
          // Twitter
          CustomInputField(
            label: 'Twitter',
            placeholder: 'twitter.com/username',
            controller: _twitterController,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 1100.ms)
              .slideX(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
          
          SizedBox(height: 36.h),
          
          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 110.w,
                height: 44.h,
                child: OutlinedButton(
                  onPressed: widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 130.w,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: setupState.isLoading ? null : _completeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: AppTheme.darkBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: setupState.isLoading
                        ? SizedBox(
                            width: 18.w,
                            height: 18.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppTheme.darkBackground),
                            ),
                          )
                        : Text(
                            'Complete Profile',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              )
                  .animate()
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 600.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 600.ms, delay: 1200.ms)
                  .then(delay: 500.ms)
                  .shimmer(duration: 2000.ms, color: AppTheme.primaryYellow.withOpacity(0.3)),
            ],
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 1300.ms)
              .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
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
