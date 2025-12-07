import 'package:supabase_flutter/supabase_flutter.dart';

class OpenAIService {
  Future<String> translate({
    required String text,
    required String targetLang,
    String? sourceLang,
  }) async {
    try {
      // Call the Supabase Edge Function named 'translate'
      final response = await Supabase.instance.functions.invoke(
        'translate',
        body: {
          'text': text,
          'sourceLang': sourceLang,
          'targetLang': targetLang,
        },
      );

      final data = response.data;
      
      if (data != null && data['choices'] != null && data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'].trim();
      }
      
      if (data != null && data['error'] != null) {
        throw Exception(data['error']);
      }

      return 'No translation returned.';
    } catch (e) {
      // If Supabase is not initialized or function fails
      if (e.toString().contains('Supabase not initialized')) {
        throw Exception('Please connect a Supabase project to enable translation.');
      }
      throw Exception('Failed to translate: $e');
    }
  }
}
