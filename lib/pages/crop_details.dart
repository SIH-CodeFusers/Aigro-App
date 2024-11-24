import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:aigro/utils/translate.dart';
import 'package:aigro/secret.dart';
import 'package:hive/hive.dart';
import 'package:aigro/local_db/db.dart';

class CropDetails extends StatefulWidget {
  final Map<String, dynamic> disease;

  const CropDetails({Key? key, required this.disease}) : super(key: key);

  @override
  State<CropDetails> createState() => _CropDetailsState();
}

class _CropDetailsState extends State<CropDetails> {
  String userLang = "en";
  late Map<String, dynamic> diseaseDetails;
  final languageBox = Hive.box("Language_db");
  final LanguageDB ldb = LanguageDB();

  @override
  void initState() {
    super.initState();
    if (languageBox.get("LANG") == null) {
      ldb.createLang();
      userLang = ldb.language;
    } else {
      ldb.loadLang();
      userLang = ldb.language;
    }
    diseaseDetails = widget.disease;
    if (userLang != "en") {
      translateDiseaseDetails(diseaseDetails);
    }
  }

  Future<void> translateDiseaseDetails(Map<String, dynamic> disease) async {
    final String targetLanguage = userLang;
    final String apiKey = GCP_API_KEY;

    try {
      final String translatedDiseaseName = await translateText(disease['diseaseName'], targetLanguage, apiKey);
      final String translatedCategory = await translateText(disease['category'], targetLanguage, apiKey);
      final String translatedSymptoms = await translateText(disease['symptoms'], targetLanguage, apiKey);
      final String translatedCauses = await translateText(disease['causes'], targetLanguage, apiKey);
      final String translatedChemicalControl = await translateText(disease['chemicalControl'], targetLanguage, apiKey);

      final List<String> translatedRemedies = [];
      for (final remedy in disease['remedies']) {
        translatedRemedies.add(await translateText(remedy, targetLanguage, apiKey));
      }

      if (mounted) {
        setState(() {
          disease['diseaseName'] = translatedDiseaseName;
          disease['category'] = translatedCategory;
          disease['symptoms'] = translatedSymptoms;
          disease['causes'] = translatedCauses;
          disease['remedies'] = translatedRemedies;
          disease['chemicalControl'] = translatedChemicalControl;
        });
      }
    } catch (e) {
      debugPrint("Error translating disease details: $e");
    }
  }

  Widget _buildImageGallery(List<String> images) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                images[index],
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error_outline),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    IconData? icon,
    List<String>? bulletPoints,
    List<String>? images,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: const Color(0xFF004D3F), size: 24),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004D3F),
                    ),
                  ),
                ),
              ],
            ),
            if (images != null && images.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildImageGallery(images),
            ],
            const SizedBox(height: 12),
            if (bulletPoints != null)
              ...bulletPoints.map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ", style: TextStyle(fontSize: 16, color: Color(0xFF004D3F))),
                        Expanded(
                          child: Text(
                            point,
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ))
            else
              Text(
                content,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
          ],
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F6F9),
    appBar: AppBar(
      elevation: 0,
      title: Text(
        diseaseDetails["diseaseName"] ?? "Disease Details",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFF004D3F),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004D3F), Color(0xFF00684A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diseaseDetails['diseaseName'] ?? "Unknown Disease",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        diseaseDetails['category'] ?? "Unknown Category",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (diseaseDetails['images'] != null && (diseaseDetails['images'] as List).isNotEmpty)
              _buildInfoCard(
                title: 'Disease Images',
                content: '',
                icon: Icons.image_outlined,
                images: List<String>.from(diseaseDetails['images']),
              ),
            _buildInfoCard(
              title: 'Symptoms',
              content: diseaseDetails['symptoms'] ?? "No symptoms information available",
              icon: Icons.medical_information_outlined,
            ),
            _buildInfoCard(
              title: 'Causes',
              content: diseaseDetails['causes'] ?? "No causes information available",
              icon: Icons.bug_report_outlined,
            ),
            _buildInfoCard(
              title: 'Remedies',
              content: '',
              icon: Icons.healing_outlined,
              bulletPoints: List<String>.from(diseaseDetails['remedies'] ?? []),
            ),
            _buildInfoCard(
              title: 'Chemical Control',
              content: diseaseDetails['chemicalControl'] ?? "No chemical control information available",
              icon: Icons.science_outlined,
            ),
            // Fertilizer Section
           if (diseaseDetails['fertilisers'] != null && (diseaseDetails['fertilisers'] as List).isNotEmpty)
  Padding(
    padding: const EdgeInsets.only(top: 20), // Add some top spacing
    child: _buildFertilizersSection(List<Map<String, dynamic>>.from(diseaseDetails['fertilisers'])),
  ),

          ],
        ),
      ),
    ),
  );
}

// Method to Build Fertilizer Section
Widget _buildFertilizersSection(List<Map<String, dynamic>> fertilisers) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Fertilizers',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF004D3F),
        ),
      ),
      const SizedBox(height: 10),
      ...fertilisers.map((fertilizer) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fertilizer['name'] ?? "Unknown Fertilizer",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                ...List<Map<String, dynamic>>.from(fertilizer['products'] ?? []).map((product) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display Fertilizer Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product['productImage'] ?? '',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              size: 70,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Display Fertilizer Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['companyName'] ?? "Unknown Company",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              product['price'] ?? "Unknown Price",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }).toList(),
    ],
  );
}


}
