import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> translate({
    required String text,
    required String targetLang,
    required String apiKey,
    String? sourceLang,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('Please set your OpenAI API Key in Settings.');
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful translation assistant. Translate the following text ${sourceLang != null && sourceLang != "Auto" ? "from $sourceLang " : ""}to $targetLang. Only return the translated text, no explanations.'
            },
            {
              'role': 'user',
              'content': text
            }
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'].trim();
        }
        return 'No translation returned.';
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Error: ${errorData['error']['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to translate: $e');
    }
  }
}
