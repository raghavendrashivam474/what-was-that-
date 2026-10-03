import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/identification_result.dart';
import '../../domain/repositories/image_identifier.dart';
import '../models/identification_result_model.dart';

class VisionImageIdentifier implements ImageIdentifier {
  final http.Client _client;

  VisionImageIdentifier({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<IdentificationResult> identify(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw const InvalidImageFailure('Image file does not exist.');
    }

    if (!AppConfig.isConfigured) {
      throw const ProviderFailure(
        'AI API Key is missing. Please add it to your app/.env file.',
      );
    }

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = Uri.parse('${AppConfig.baseUrl}/chat/completions');
    const systemPrompt = '''
You are "What Was That?", an expert visual identification engine.
The user took a photo of something unfamiliar and asks: "What was that?"

Answer with ONLY a valid JSON object matching this schema:
{
  "identifiable": true or false,
  "title": "Concise name of the object, plant, animal, tool, connector, etc.",
  "explanation": "2-3 concise sentences explaining what it is and what it is used for.",
  "confidence": "high" | "medium" | "low" | "unknown"
}

Important rules:
1. If the photo is too blurry, dark, ambiguous, or you cannot determine what it is with reasonable confidence, set "identifiable": false, "confidence": "unknown", and give a helpful tip in "explanation".
2. Never invent an identification if unsure.
3. Keep the explanation short, direct, and factual.
4. Output raw JSON only. Do not wrap in markdown quotes.
''';

    final body = json.encode({
      'model': AppConfig.model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': 'What was that? Identify this object concisely.',
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
                'detail': 'low',
              },
            },
          ],
        },
      ],
      'max_tokens': 300,
      'temperature': 0.2,
    });

    try {
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AppConfig.apiKey}',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        throw ProviderFailure(
          'Identification service error (Status ${response.statusCode}).',
        );
      }

      final responseJson = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final choices = responseJson['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw const ProviderFailure('Received empty response from vision model.');
      }

      final content = choices[0]['message']?['content'] as String?;
      if (content == null || content.isEmpty) {
        throw const ProviderFailure('Received blank answer from vision model.');
      }

      return IdentificationResultModel.fromRawJson(content);
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw ProviderFailure(e.toString());
    }
  }
}