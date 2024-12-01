import 'dart:convert';
import 'package:aigro/secret.dart';
import 'package:http/http.dart' as http;

Future<String> translateTextInput(String inputText, String targetLanguage) async {
   String apiKey = GCP_API_KEY; 
  if(targetLanguage=="en"){
      return inputText;
    }
  try {
    // Translate the input text
    String translatedText = await translateText(inputText, targetLanguage, apiKey);
    return translatedText;
  } catch (e) {
    print("Error: $e");
    return inputText; // Return original text in case of error
  }
}

Future<String> translateText(String text, String targetLanguage, String apiKey) async {
  const String url = 'https://translation.googleapis.com/language/translate/v2';

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
