import 'dart:convert';
import 'package:aigro/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:aigro/utils/translate.dart';
import 'package:aigro/secret.dart';
import 'package:hive/hive.dart';
import 'package:aigro/local_db/db.dart';

class CropDetails extends StatefulWidget {
  final Map<String, dynamic> disease;

  const CropDetails({super.key, required this.disease});

  @override
  State<CropDetails> createState() => _CropDetailsState();
}

class _CropDetailsState extends State<CropDetails> {
  String userLang = "en";
  late Map<String, dynamic> diseaseDetails;
  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();

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
    String targetLanguage = userLang;
    String apiKey = GCP_API_KEY;

    try {
      String translatedDiseaseName = await translateText(disease['diseaseName'], targetLanguage, apiKey);
      String translatedCategory = await translateText(disease['category'], targetLanguage, apiKey);
      String translatedSymptoms = await translateText(disease['symptoms'], targetLanguage, apiKey);
      String translatedCauses = await translateText(disease['causes'], targetLanguage, apiKey);
      String translatedChemicalControl = await translateText(disease['chemicalControl'], targetLanguage, apiKey);

      List<String> translatedRemedies = [];
      for (var remedy in disease['remedies']) {
        translatedRemedies.add(await translateText(remedy, targetLanguage, apiKey));
      }

      setState(() {
        disease['diseaseName'] = translatedDiseaseName;
        disease['category'] = translatedCategory;
        disease['symptoms'] = translatedSymptoms;
        disease['causes'] = translatedCauses;
        disease['remedies'] = translatedRemedies;
        disease['chemicalControl'] = translatedChemicalControl;
      });
    } catch (e) {
      print("Error translating disease details: $e");
    }
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    IconData? icon,
    List<String>? bulletPoints,
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004D3F),
                  ),
                ),
              ],
            ),
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
          diseaseDetails["diseaseName"],
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
                        diseaseDetails['diseaseName'],
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
                          diseaseDetails['category'],
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
              _buildInfoCard(
                title: 'Symptoms',
                content: diseaseDetails['symptoms'],
                icon: Icons.medical_information_outlined,
              ),
              _buildInfoCard(
                title: 'Causes',
                content: diseaseDetails['causes'],
                icon: Icons.bug_report_outlined,
              ),
              _buildInfoCard(
                title: 'Remedies',
                content: '',
                icon: Icons.healing_outlined,
                bulletPoints: List<String>.from(diseaseDetails['remedies']),
              ),
              _buildInfoCard(
                title: 'Chemical Control',
                content: diseaseDetails['chemicalControl'],
                icon: Icons.science_outlined,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}