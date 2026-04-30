import 'dart:io';
import 'dart:convert';
void main() async {
  try {
    final env = await File('.env').readAsString();
    final keyMatch = RegExp(r'GROQ_API_KEY=(.*)').firstMatch(env);
    if (keyMatch == null) {
      print('GROQ_API_KEY not found');
      return;
    }
    final key = keyMatch.group(1)!.trim();
    final req = await HttpClient().getUrl(Uri.parse('https://api.groq.com/openai/v1/models'));
    req.headers.add('Authorization', 'Bearer $key');
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    final data = jsonDecode(body)['data'];
    for (var m in data) {
      print(m['id']);
    }
  } catch (e) {
    print('Error: $e');
  }
}
