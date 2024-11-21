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
  String userLang = "en"; // Default language
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

  // Function to translate the disease details
  Future<void> translateDiseaseDetails(Map<String, dynamic> disease) async {
    String targetLanguage = userLang;
    String apiKey = GCP_API_KEY;

    try {
      // Translate disease name, category, symptoms, causes, and remedies
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        title: Text("${diseaseDetails["diseaseName"]} Details"),
        backgroundColor: context.theme.primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Disease Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF004D3F),
                ),
              ).centered(),
              const SizedBox(height: 20),


              Text(
                "Disease Name: ${diseaseDetails['diseaseName']}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Category: ${diseaseDetails['category']}",
                style: TextStyle(fontSize: 14, color: context.theme.splashColor),
              ),
              const SizedBox(height: 20),


              Text(
                "Symptoms: ${diseaseDetails['symptoms']}",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),


              Text(
                "Causes: ${diseaseDetails['causes']}",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),


              Text(
                "Remedies:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              for (var remedy in diseaseDetails['remedies']) 
                Text("• $remedy", style: TextStyle(fontSize: 14)),
              const SizedBox(height: 20),


              Text(
                "Chemical Control: ${diseaseDetails['chemicalControl']}",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
