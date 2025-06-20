import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/ai_config.dart';

class AIService {
  static GenerativeModel? _model;

  static GenerativeModel get model {
    if (_model == null) {
      if (!AIConfig.isConfigured) {
        throw Exception('Gemini API key not configured. Please add your API key to AIConfig.');
      }

      _model = GenerativeModel(
        model: AIConfig.modelName,
        apiKey: AIConfig.geminiApiKey,
      );
    }
    return _model!;
  }

  static Future<String> generateBio({
    required String firstName,
    required String lastName,
    required List<String> interests,
    required List<String> skills,
    String? location,
    String? college,
    String? course,
  }) async {
    try {
      if (!AIConfig.isConfigured) {
        return _getFallbackBio(firstName, interests, skills);
      }

      final prompt = _buildBioPrompt(
        firstName: firstName,
        lastName: lastName,
        interests: interests,
        skills: skills,
        location: location,
        college: college,
        course: course,
      );

      print('🤖 Generating AI bio...');
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text != null && response.text!.isNotEmpty) {
        print('✅ AI bio generated successfully');
        return response.text!.trim();
      } else {
        print('⚠️ AI returned empty response, using fallback');
        return _getFallbackBio(firstName, interests, skills);
      }
    } catch (e) {
      print('❌ AI bio generation failed: $e');
      return _getFallbackBio(firstName, interests, skills);
    }
  }

  static String _buildBioPrompt({
    required String firstName,
    required String lastName,
    required List<String> interests,
    required List<String> skills,
    String? location,
    String? college,
    String? course,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Generate a professional and engaging bio for a college student with the following details:');
    buffer.writeln('Name: $firstName $lastName');

    if (college != null && college.isNotEmpty) {
      buffer.writeln('College: $college');
    }

    if (course != null && course.isNotEmpty) {
      buffer.writeln('Course: $course');
    }

    if (location != null && location.isNotEmpty) {
      buffer.writeln('Location: $location');
    }

    if (interests.isNotEmpty) {
      buffer.writeln('Interests: ${interests.join(', ')}');
    }

    if (skills.isNotEmpty) {
      buffer.writeln('Skills: ${skills.join(', ')}');
    }

    buffer.writeln('\nRequirements:');
    buffer.writeln('- Keep it under 150 words');
    buffer.writeln('- Make it professional yet friendly');
    buffer.writeln('- Focus on their interests and skills');
    buffer.writeln('- Suitable for a student networking platform');
    buffer.writeln('- Do not include quotes or special formatting');
    buffer.writeln('- Write in third person');

    return buffer.toString();
  }

  static String _getFallbackBio(String firstName, List<String> interests, List<String> skills) {
    final buffer = StringBuffer();
    buffer.write('$firstName is a passionate student');

    if (interests.isNotEmpty) {
      buffer.write(' with interests in ${interests.take(3).join(', ')}');
    }

    if (skills.isNotEmpty) {
      buffer.write('. Skilled in ${skills.take(3).join(', ')}');
    }

    buffer.write(', $firstName is always eager to learn new things and connect with like-minded individuals.');

    return buffer.toString();
  }
}
