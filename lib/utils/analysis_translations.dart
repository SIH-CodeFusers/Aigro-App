import 'package:aigro/utils/translate.dart';

class AnalysisTranslations {
  static Future<Map<String, String>> getTranslations(String targetLanguage) async {
    return {
      'title': await translateTextInput('🌱 Create New Analysis', targetLanguage),
      'voice_message': await translateTextInput(
        'Create a new analysis by selecting the crop, growth stage, and uploading an image.',
        targetLanguage
      ),
      'pick_image': await translateTextInput('Pick a Image from your Gallery', targetLanguage),
      'file_size_error': await translateTextInput('File size exceeds 500kb limit.', targetLanguage),
      'format_error': await translateTextInput('Please select a correct Image Format.', targetLanguage),
      'upload_prompt': await translateTextInput('Please upload a crop image.', targetLanguage),
      'submit_analysis': await translateTextInput('Submit for Analysis', targetLanguage),
      'analysis_success': await translateTextInput('Image Analyzed Successfully', targetLanguage),
      'analyzing': await translateTextInput('Analyzing Image. Please wait for few seconds...', targetLanguage),
    };
  }

  static Future<List<String>> translateCropOptions(List<String> options, String targetLanguage) async {
    List<String> translatedOptions = [];
    for (String option in options) {
      translatedOptions.add(await translateTextInput(option, targetLanguage));
    }
    return translatedOptions;
  }
}