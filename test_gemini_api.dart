import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
void main() async {
  try {
    final env = await File('.env').readAsString();
    final keyMatch = RegExp(r'GEMINI_API_KEY=(.*)').firstMatch(env);
    if (keyMatch == null) {
      print('GEMINI_API_KEY not found');
      return;
    }
    final key = keyMatch.group(1)!.trim();
    print('Key length: \${key.length}');
    
    // Test 1.5 flash
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: key);
    final content = [Content.text('Hello')];
    final response = await model.generateContent(content);
    print('gemini-2.5-flash Response: \${response.text}');
    
    // Test 2.5 flash
    final model2 = GenerativeModel(model: 'gemini-2.5-flash', apiKey: key);
    final response2 = await model2.generateContent(content);
    print('gemini-2.5-flash Response: \${response2.text}');
    
  } catch (e) {
    print('Error: \$e');
  }
}
