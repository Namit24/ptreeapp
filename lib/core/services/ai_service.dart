import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/ai_config.dart';

class AIService {
  static GenerativeModel? _model;
  
  static GenerativeModel get model {
    if (_model == null) {
      if (!AIConfig.isConfigured) {
        throw Exception('Gemini API key not configured');
      }
      
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: AIConfig.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 200,
        ),
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
  }) async {
    try {
      if (!AIConfig.isConfigured) {
        print('⚠️ Gemini API key not configured, using fallback');
        return _getFallbackBio(firstName, interests, skills);
      }

      final prompt = _buildBioPrompt(
        firstName: firstName,
        lastName: lastName,
        interests: interests,
        skills: skills,
        location: location,
      );

      print('🤖 Generating AI bio with Gemini...');
      print('Prompt: ${prompt.substring(0, 100)}...');

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        final generatedBio = response.text!.trim();
        print('✅ AI bio generated successfully');
        print('Generated bio: ${generatedBio.substring(0, 50)}...');
        return generatedBio;
      } else {
        print('⚠️ AI response was empty, using fallback');
        return _getFallbackBio(firstName, interests, skills);
      }
    } catch (e) {
      print('❌ Error generating AI bio: $e');
      print('Using fallback bio instead');
      return _getFallbackBio(firstName, interests, skills);
    }
  }

  static String _buildBioPrompt({
    required String firstName,
    required String lastName,
    required List<String> interests,
    required List<String> skills,
    String? location,
  }) {
    final interestsText = interests.take(5).join(', ');
    final skillsText = skills.take(5).join(', ');
    final locationText = location?.isNotEmpty == true ? ' from $location' : '';

    return '''
Write a professional and engaging bio for a college student named $firstName$locationText.

Their interests include: $interestsText
Their skills include: $skillsText

Requirements:
- Keep it under 150 words
- Make it personal and authentic
- Focus on their passion for learning and collaboration
- Mention their interest in connecting with other students
- Use a friendly, approachable tone
- Don't use quotes or special formatting
- Write in first person (I am, I love, etc.)

Example style: "Hi, I'm [name]! I'm passionate about [interests] and skilled in [skills]. I love collaborating on innovative projects and connecting with like-minded students. Let's build something amazing together!"
''';
  }

  static String _getFallbackBio(String firstName, List<String> interests, List<String> skills) {
    final topInterests = interests.take(3).join(', ');
    final topSkills = skills.take(3).join(', ');
    
    return "Hi, I'm $firstName! I'm passionate about $topInterests and skilled in $topSkills. "
           "I love collaborating on innovative projects and connecting with like-minded students. "
           "Always excited to learn new things and work on meaningful projects. Let's build something amazing together!";
  }
}
