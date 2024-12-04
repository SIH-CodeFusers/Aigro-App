import 'package:aigro/utils/translate.dart';

Future<String> getTranslatedText(String title,String futureLang) async {
  try {
    String lang = await futureLang;
    return await translateTextInput(title, lang);
  } catch (e) {
    print("Error: $e");
    return title;
  }
}

