import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  final apiKey = "";
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      for (var model in data['models']) {
        print("${model['name']} - ${model['supportedGenerationMethods']}");
      }
    } else {
      print("Error: ${response.statusCode} ${response.body}");
    }
  } catch (e) {
    print("Exception: $e");
  }
}
