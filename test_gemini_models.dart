import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final apiKey = "";
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=' + apiKey);
  
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final models = json['models'] as List;
      for (var m in models) {
        print(m['name']);
      }
    } else {
      print('Status: ' + response.statusCode.toString());
      print('Error body: ' + response.body);
    }
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
