class AIConfig {
  // Replace with your actual Gemini API key
  // Get it from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'AIzaSyC2-ZrrxWGcObQeeWYm70zs3d7FT7gmsQ8';

  // Model configuration
  static const String modelName = 'gemini-1.5-flash';

  // Check if API key is configured
  static bool get isConfigured => geminiApiKey != 'AIzaSyC2-ZrrxWGcObQeeWYm70zs3d7FT7gmsQ8';
}




//AIzaSyC2-ZrrxWGcObQeeWYm70zs3d7FT7gmsQ8