import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  final String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> sendMessage(String message) async {
    if (_apiKey.isEmpty) return 'API key not found. Please check .env file.';

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          // ✅ UPDATED: Use a currently supported model
          'model': 'llama-3.3-70b-versatile',  // New stable model
          // Alternative models:
          // 'model': 'llama-3.1-8b-instant',  // Faster, lower quality
          // 'model': 'mixtral-8x7b-32768',    // Good for complex tasks
          'messages': [
            {'role': 'system', 'content': 'You are a helpful farming assistant for Sri Lankan farmers called GoviMaga Assistant.'},
            {'role': 'user', 'content': message},
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final errorData = jsonDecode(response.body);
        return 'API Error: ${errorData['error']['message']}';
      }
    } catch (e) {
      return 'Connection error: ${e.toString()}';
    }
  }
}