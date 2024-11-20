import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> translateText(String text, String targetLanguage, String apiKey) async {
  final String url = 'https://translation.googleapis.com/language/translate/v2';

  final response = await http.post(
    Uri.parse(url),
    body: {
      'q': text,
      'target': targetLanguage,
      'key': apiKey,
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data']['translations'][0]['translatedText'];
  } else {
    throw Exception('Failed to translate text');
  }
}
