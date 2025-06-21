import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/interest_skill_chip.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();
  
  List<String> _selectedInterests = [];
  List<String> _selectedSkills = [];
  File? _selectedImage;
  bool _isLoading = false;
  bool _isPickingImage = false; // Prevent multiple image picker calls

  final List<String> _availableInterests = [
    'Web Development', 'Mobile Apps', 'AI & Machine Learning', 'Blockchain',
    'IoT', 'Cloud Computing', 'Cybersecurity', 'Data Science', 'Startups',
    'Entrepreneurship', 'Marketing', 'Finance', 'Product Management',
    'E-commerce', 'Design', 'UI/UX', 'Photography', 'Gaming', 'Travel',
    'Fitness', 'Reading', 'Cooking', 'Sustainability', 'Mental Health'
  ];

  final List<String> _availableSkills = [
    'JavaScript', 'TypeScript', 'Python', 'Java', 'C#', 'Go', 'Ruby', 'PHP',
    'React', 'Vue', 'Angular', 'Next.js', 'Node.js', 'Express', 'Django',
    'Flask', 'Spring Boot', 'Laravel', 'Git', 'Docker', 'Kubernetes', 'AWS'
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    final authState = ref.read(authProvider);
    final profile = authState.profile;
    
    if (profile != null) {
      _firstNameController.text = profile['first_name']?.toString() ?? '';
      _lastNameController.text = profile['last_name']?.toString() ?? '';
      _usernameController.text = profile['username']?.toString() ?? '';
      _bioController.text = profile['bio']?.toString() ?? '';
      _locationController.text = profile['location']?.toString() ?? '';
      _websiteController.text = profile['website']?.toString() ?? '';
      _githubController.text = profile['github']?.toString() ?? '';
      _linkedinController.text = profile['linkedin']?.toString() ?? '';
      _twitterController.text = profile['twitter']?.toString() ?? '';
      
      if (profile['interests'] != null) {
        _selectedInterests = List<String>.from(profile['interests']);
      }
      if (profile['skills'] != null) {
        _selectedSkills = List<String>.from(profile['skills']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.textWhite),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppTheme.primaryYellow),
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: AppTheme.primaryYellow,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(60.r),
                        border: Border.all(color: AppTheme.primaryYellow, width: 3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(57.r),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : profile?['profile_image_url'] != null
                                ? Image.network(
                                    profile!['profile_image_url'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildAvatarPlaceholder();
                                    },
                                  )
                                : _buildAvatarPlaceholder(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isPickingImage ? null : _pickImage,
                        child: Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryYellow,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(color: AppTheme.darkBackground, width: 2),
                          ),
                          child: _isPickingImage
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(AppTheme.darkBackground),
                                  ),
                                )
                              : Icon(
                                  Icons.camera_alt,
                                  color: AppTheme.darkBackground,
                                  size: 18.sp,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Personal Information
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ),
              SizedBox(height: 16.h),
              
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
              
              SizedBox(height: 16.h),
              
              CustomInputField(
                label: 'Username',
                placeholder: 'Choose a unique username',
                controller: _usernameController,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Username is required';
                  if (value!.length < 3) return 'Username must be at least 3 characters';
                  return null;
                },
              ),
              
              SizedBox(height: 16.h),
              
              CustomInputField(
                label: 'Location',
                placeholder: 'City, Country',
                controller: _locationController,
              ),
              
              SizedBox(height: 16.h),
              
              CustomInputField(
                label: 'Bio',
                placeholder: 'Tell us about yourself...',
                controller: _bioController,
                maxLines: 3,
                maxLength: 300,
              ),
              
              SizedBox(height: 24.h),
              
              // Interests Section
              Text(
                'Interests',
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
                children: _availableInterests.map((interest) {
                  final isSelected = _selectedInterests.contains(interest);
                  return InterestSkillChip(
                    label: interest,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedInterests.remove(interest);
                        } else {
                          _selectedInterests.add(interest);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              
              SizedBox(height: 24.h),
              
              // Skills Section
              Text(
                'Skills',
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
                children: _availableSkills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill);
                  return InterestSkillChip(
                    label: skill,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSkills.remove(skill);
                        } else {
                          _selectedSkills.add(skill);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              
              SizedBox(height: 24.h),
              
              // Social Links
              Text(
                'Social Links',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite,
                ),
              ),
              SizedBox(height: 16.h),
              
              CustomInputField(
                label: 'Website',
                placeholder: 'https://yourwebsite.com',
                controller: _websiteController,
              ),
              
              SizedBox(height: 16.h),
              
              CustomInputField(
                label: 'GitHub',
                placeholder: 'github.com/username',
                controller: _githubController,
              ),
              
              SizedBox(height: 16.h),
              
              CustomInputField(
                label: 'LinkedIn',
                placeholder: 'linkedin.com/in/username',
                controller: _linkedinController,
              ),
              
              SizedBox(height: 16.h),
              
              CustomInputField(
                label: 'Twitter',
                placeholder: 'twitter.com/username',
                controller: _twitterController,
              ),
              
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    final profile = ref.read(authProvider).profile;
    final firstName = profile?['first_name']?.toString() ?? profile?['full_name']?.toString() ?? 'U';
    final letter = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';
    
    return Container(
      color: AppTheme.primaryYellow.withOpacity(0.2),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 40.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryYellow,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return; // Prevent multiple calls
    
    setState(() {
      _isPickingImage = true;
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      
      // Prepare update data
      final updateData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'full_name': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'location': _locationController.text.trim(),
        'website': _websiteController.text.trim(),
        'github': _githubController.text.trim(),
        'linkedin': _linkedinController.text.trim(),
        'twitter': _twitterController.text.trim(),
        'interests': _selectedInterests,
        'skills': _selectedSkills,
      };

      // Upload image if selected
      if (_selectedImage != null) {
        final user = ref.read(authProvider).user;
        if (user != null) {
          final imageUrl = await authNotifier.uploadProfileImage(_selectedImage!);
          updateData['profile_image_url'] = imageUrl;
        }
      }

      // Update profile
      await authNotifier.updateProfile(updateData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    super.dispose();
  }
}
