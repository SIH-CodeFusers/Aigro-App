import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:aigro/utils/translate.dart';
import 'package:aigro/widgets/voice_icon.dart';

class AnalysisResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onTap;
  final Function(String) onSpeak;
  final String language;

  const AnalysisResultCard({
    Key? key,
    required this.result,
    required this.onTap,
    required this.onSpeak,
    required this.language,
  }) : super(key: key);

  Future<String> _getTranslatedText(String text) async {
    return await translateTextInput(text, language);
  }

  @override
  Widget build(BuildContext context) {
    final cropName = result['cropName'] ?? "Unknown";
    final status = result['status'] ?? "Unknown";
    final diseaseName = result['diseaseName'] ?? "Unknown";
    final symptoms = result['symptoms'] ?? "Unknown";
    final cropImage = result['cropImage'] ?? '';

    return FutureBuilder<List<String>>(
      future: Future.wait([
        _getTranslatedText(cropName),
        _getTranslatedText(status),
        _getTranslatedText(diseaseName),
        _getTranslatedText(symptoms),
        _getTranslatedText("in"),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final translatedCropName = snapshot.data![0];
        final translatedStatus = snapshot.data![1];
        final translatedDiseaseName = snapshot.data![2];
        final translatedSymptoms = snapshot.data![3];
        final translatedIn = snapshot.data![4];

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: diseaseName == "Unknown"
                  ? context.theme.highlightColor.withOpacity(0.8)
                  : context.theme.highlightColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cropImage.isNotEmpty)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            cropImage,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => onSpeak(
                              "$translatedDiseaseName $translatedIn $translatedCropName. $translatedSymptoms",
                            ),
                            child: voiceIcon(context),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "$translatedDiseaseName $translatedIn $translatedCropName",
                          style: const TextStyle(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.theme.focusColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(translatedStatus),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    translatedSymptoms,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}