import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final apiKey = "";
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=' + apiKey);
  
  final body = jsonEncode({
    "contents": [{"parts":[{"text": "Hello"}]}]
  });

  try {
    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
    print('Status: ' + response.statusCode.toString());
    print('Body: ' + response.body);
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
