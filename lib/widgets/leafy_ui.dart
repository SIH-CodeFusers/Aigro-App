import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:aigro/utils/translate.dart';

class LeafyUI extends StatelessWidget {
  final String cropName;
  final String diseaseName;
  final String symptoms;
  final String cropImage;
  final String language;
  final GlobalKey repaintKey;

  const LeafyUI({
    Key? key,
    required this.cropName,
    required this.diseaseName,
    required this.symptoms,
    required this.cropImage,
    required this.language,
    required this.repaintKey,
  }) : super(key: key);

  Future<String> _getTranslatedText(String text) async {
    return await translateTextInput(text, language);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Future.wait([
        _getTranslatedText("Crop Analysis Result"),
        _getTranslatedText("Crop"),
        _getTranslatedText("Disease"),
        _getTranslatedText("Symptoms"),
        _getTranslatedText(cropName),
        _getTranslatedText(diseaseName),
        _getTranslatedText(symptoms),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final translatedTitle = snapshot.data![0];
        final translatedCropLabel = snapshot.data![1];
        final translatedDiseaseLabel = snapshot.data![2];
        final translatedSymptomsLabel = snapshot.data![3];
        final translatedCropName = snapshot.data![4];
        final translatedDiseaseName = snapshot.data![5];
        final translatedSymptoms = snapshot.data![6];

        return RepaintBoundary(
          key: repaintKey,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [context.theme.cardColor, Colors.lightGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    translatedTitle,
                    style: TextStyle(
                      fontSize: 24,
                      color: context.theme.highlightColor,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (cropImage.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        cropImage,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    "$translatedCropLabel: $translatedCropName",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$translatedDiseaseLabel: $translatedDiseaseName",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$translatedSymptomsLabel: $translatedSymptoms",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                    textAlign: TextAlign.center,
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