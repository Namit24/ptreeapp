import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileSetupState {
  final Map<String, dynamic> personalInfo;
  final String? profileImagePath;
  final File? profileImageFile;
  final List<String> selectedInterests;
  final List<String> selectedSkills;
  final Map<String, dynamic> biography;
  final bool isLoading;
  final String? error;
  final bool isUploadingImage;
  final bool isGeneratingBio;

  ProfileSetupState({
    this.personalInfo = const {},
    this.profileImagePath,
    this.profileImageFile,
    this.selectedInterests = const [],
    this.selectedSkills = const [],
    this.biography = const {},
    this.isLoading = false,
    this.error,
    this.isUploadingImage = false,
    this.isGeneratingBio = false,
  });

  ProfileSetupState copyWith({
    Map<String, dynamic>? personalInfo,
    String? profileImagePath,
    File? profileImageFile,
    List<String>? selectedInterests,
    List<String>? selectedSkills,
    Map<String, dynamic>? biography,
    bool? isLoading,
    String? error,
    bool? isUploadingImage,
    bool? isGeneratingBio,
  }) {
    return ProfileSetupState(
      personalInfo: personalInfo ?? this.personalInfo,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      profileImageFile: profileImageFile ?? this.profileImageFile,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      selectedSkills: selectedSkills ?? this.selectedSkills,
      biography: biography ?? this.biography,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isGeneratingBio: isGeneratingBio ?? this.isGeneratingBio,
    );
  }

  // Calculate completion percentage
  int get completionPercentage {
    int completed = 0;
    int total = 5;

    // Personal info (required fields)
    if (personalInfo['first_name']?.isNotEmpty == true &&
        personalInfo['last_name']?.isNotEmpty == true &&
        personalInfo['username']?.isNotEmpty == true) {
      completed++;
    }

    // Profile photo
    if (profileImagePath != null || profileImageFile != null) {
      completed++;
    }

    // Interests
    if (selectedInterests.isNotEmpty) {
      completed++;
    }

    // Skills
    if (selectedSkills.isNotEmpty) {
      completed++;
    }

    // Biography
    if (biography['bio']?.isNotEmpty == true) {
      completed++;
    }

    return ((completed / total) * 100).round();
  }

  // Get first letter for avatar
  String get avatarLetter {
    final firstName = personalInfo['first_name'] as String?;
    if (firstName?.isNotEmpty == true) {
      return firstName!.substring(0, 1).toUpperCase();
    }
    return 'U';
  }
}

class ProfileSetupNotifier extends StateNotifier<ProfileSetupState> {
  final Ref ref;

  ProfileSetupNotifier(this.ref) : super(ProfileSetupState()) {
    _initializeFromExistingProfile();
  }

  void _initializeFromExistingProfile() {
    final authState = ref.read(authProvider);
    final profile = authState.profile;

    if (profile != null) {
      // Pre-populate with existing data
      state = state.copyWith(
        personalInfo: {
          'first_name': profile['first_name'] ?? '',
          'last_name': profile['last_name'] ?? '',
          'username': profile['username'] ?? '',
          'location': profile['location'] ?? '',
        },
        profileImagePath: profile['profile_image_url'],
        selectedInterests: List<String>.from(profile['interests'] ?? []),
        selectedSkills: List<String>.from(profile['skills'] ?? []),
        biography: {
          'bio': profile['bio'] ?? '',
          'website': profile['website'] ?? '',
          'github': profile['github'] ?? '',
          'twitter': profile['twitter'] ?? '',
          'linkedin': profile['linkedin'] ?? '',
        },
      );
    }
  }

  void updatePersonalInfo(Map<String, dynamic> info) {
    state = state.copyWith(personalInfo: {...state.personalInfo, ...info});
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      state = state.copyWith(isUploadingImage: true, error: null);

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Validate file size (5MB max)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          state = state.copyWith(
            isUploadingImage: false,
            error: 'Image size must be less than 5MB',
          );
          return;
        }

        state = state.copyWith(
          profileImageFile: file,
          profileImagePath: pickedFile.path,
          isUploadingImage: false,
        );
      } else {
        state = state.copyWith(isUploadingImage: false);
      }
    } catch (e) {
      state = state.copyWith(
        isUploadingImage: false,
        error: 'Failed to pick image: $e',
      );
    }
  }

  void removeProfileImage() {
    state = state.copyWith(
      profileImagePath: null,
      profileImageFile: null,
    );
  }

  void addInterest(String interest) {
    if (!state.selectedInterests.contains(interest) && interest.trim().isNotEmpty) {
      final updatedInterests = [...state.selectedInterests, interest.trim()];
      state = state.copyWith(selectedInterests: updatedInterests);
    }
  }

  void removeInterest(String interest) {
    final updatedInterests = state.selectedInterests.where((i) => i != interest).toList();
    state = state.copyWith(selectedInterests: updatedInterests);
  }

  void addSkill(String skill) {
    if (!state.selectedSkills.contains(skill) && skill.trim().isNotEmpty) {
      final updatedSkills = [...state.selectedSkills, skill.trim()];
      state = state.copyWith(selectedSkills: updatedSkills);
    }
  }

  void removeSkill(String skill) {
    final updatedSkills = state.selectedSkills.where((s) => s != skill).toList();
    state = state.copyWith(selectedSkills: updatedSkills);
  }

  void updateBiography(Map<String, dynamic> bio) {
    state = state.copyWith(biography: {...state.biography, ...bio});
  }

  // Generate AI bio and return the result
  Future<String?> generateAIBio() async {
    try {
      state = state.copyWith(isGeneratingBio: true, error: null);

      // Validate required data
      if (state.personalInfo['first_name']?.isEmpty ?? true) {
        state = state.copyWith(
          isGeneratingBio: false,
          error: 'Please fill in your name first',
        );
        return null;
      }

      if (state.selectedInterests.isEmpty && state.selectedSkills.isEmpty) {
        state = state.copyWith(
          isGeneratingBio: false,
          error: 'Please add some interests or skills first',
        );
        return null;
      }

      print('🤖 Generating AI bio...');

      final generatedBio = await AIService.generateBio(
        firstName: state.personalInfo['first_name'] ?? '',
        lastName: state.personalInfo['last_name'] ?? '',
        interests: state.selectedInterests,
        skills: state.selectedSkills,
        location: state.personalInfo['location'],
      );

      final updatedBio = {...state.biography, 'bio': generatedBio};
      state = state.copyWith(
        biography: updatedBio,
        isGeneratingBio: false,
      );

      print('✅ AI bio generated successfully');
      return generatedBio;
    } catch (e) {
      print('❌ Error generating AI bio: $e');
      state = state.copyWith(
        isGeneratingBio: false,
        error: 'Failed to generate bio. Please try again or write one manually.',
      );
      return null;
    }
  }

  // Validate current step
  bool validateStep(int step) {
    switch (step) {
      case 0: // Personal Info
        return state.personalInfo['first_name']?.isNotEmpty == true &&
            state.personalInfo['last_name']?.isNotEmpty == true &&
            state.personalInfo['username']?.isNotEmpty == true;
      case 1: // Profile Photo (optional)
        return true;
      case 2: // Interests (at least 1)
        return state.selectedInterests.isNotEmpty;
      case 3: // Skills (at least 1)
        return state.selectedSkills.isNotEmpty;
      case 4: // Biography (optional)
        return true;
      default:
        return false;
    }
  }

  Future<bool> completeProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = ref.read(authProvider).user;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No user found',
        );
        return false;
      }

      print('🚀 Completing profile for user: ${user.email}');

      String? profileImageUrl;

      // Upload profile image if exists
      if (state.profileImageFile != null) {
        try {
          print('📸 Uploading profile image...');
          profileImageUrl = await SupabaseService.uploadProfileImage(
            userId: user.id,
            imageFile: state.profileImageFile!,
          );
          print('✅ Profile image uploaded: $profileImageUrl');
        } catch (e) {
          print('❌ Error uploading image: $e');
          // Continue without image if upload fails
        }
      }

      // Combine all profile data
      final profileData = {
        ...state.personalInfo,
        'interests': state.selectedInterests,
        'skills': state.selectedSkills,
        ...state.biography,
        'profile_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add profile image URL if uploaded
      if (profileImageUrl != null) {
        profileData['profile_image_url'] = profileImageUrl;
      }

      print('💾 Updating profile in database...');

      // Update profile in Supabase
      await SupabaseService.updateProfile(
        userId: user.id,
        data: profileData,
      );

      print('✅ Profile updated successfully');

      // Refresh auth state to get updated profile
      await ref.read(authProvider.notifier).refreshProfile();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      print('❌ Error completing profile: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save profile: $e',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final profileSetupProvider = StateNotifierProvider<ProfileSetupNotifier, ProfileSetupState>((ref) {
  return ProfileSetupNotifier(ref);
});
