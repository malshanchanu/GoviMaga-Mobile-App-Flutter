import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
  print("API Key loaded: \${apiKey.isNotEmpty}");

  try {
    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      systemInstruction: Content.system('You are GoviMaga Assistant. Respond in the language user asks.'),
    );
    final chatSession = model.startChat();
    final response = await chatSession.sendMessage(Content.text('Hello'));
    print('Response: \${response.text}');
  } catch (e) {
    print('Error: \$e');
  }
}
