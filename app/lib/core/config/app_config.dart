import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Fallback if .env is missing in dev/test
    }
  }

  static String get apiKey => dotenv.env['AI_API_KEY'] ?? '';
  static String get baseUrl => dotenv.env['AI_BASE_URL'] ?? 'https://api.openai.com/v1';
  static String get model => dotenv.env['AI_MODEL'] ?? 'gpt-4o-mini';

  static bool get isConfigured => apiKey.isNotEmpty;
}
