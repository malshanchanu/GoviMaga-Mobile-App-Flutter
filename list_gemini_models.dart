import 'dart:io';
import 'dart:convert';
void main() async {
  try {
    final env = await File('.env').readAsString();
    final keyMatch = RegExp(r'GEMINI_API_KEY=(.*)').firstMatch(env);
    if (keyMatch == null) {
      print('GEMINI_API_KEY not found');
      return;
    }
    final key = keyMatch.group(1)!.trim();
    
    final req = await HttpClient().getUrl(Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=' + key));
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    
    final data = jsonDecode(body)['models'];
    for (var m in data) {
      print(m['name']);
    }
  } catch (e) {
    print('Error: ' + e.toString());
  }
}
