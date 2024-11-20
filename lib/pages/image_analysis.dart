import 'dart:io';
import 'dart:convert';
import 'package:aigro/pages/crop_details.dart';
import 'package:aigro/secret.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:velocity_x/velocity_x.dart';

class ImageAnalysis extends StatefulWidget {
  @override
  _ImageAnalysisState createState() => _ImageAnalysisState();
}

class _ImageAnalysisState extends State<ImageAnalysis> {
  Map<String, dynamic>? _analysisData;
  List<Map<String, dynamic>> cropDiseaseList = [];

  // Load crop diseases from JSON
  Future<void> loadCropDiseases() async {
    final data = await DefaultAssetBundle.of(context)
        .loadString('assets/others/crop_disease_18nov.json');
    final Map<String, dynamic> jsonResult = json.decode(data);

    setState(() {
      cropDiseaseList = (jsonResult['cropDiseases'] as List)
          .expand((crop) => (crop['diseaseDetails'] as List).map((disease) {
                return {
                  "diseaseName": disease['diseaseName'] as String,
                  "scientificName": disease['scientificName'] as String,
                  "category": disease['category'] as String,
                  "images": (disease['images'] as List).map((img) => img as String).toList(),
                  "symptoms": disease['symptoms'] as String? ?? '',
                  "causes": disease['causes'] as String? ?? '',
                  "remedies": (disease['remedies'] as List?)?.map((r) => r as String).toList() ?? [],
                  "chemicalControl": disease['chemicalControl'] as String? ?? '',
                  "cropName": crop['cropName'] as String,
                };
              }))
          .toList();
    });
  }

  // Fetch analysis data from API
  Future<void> _fetchAnalysisData() async {
    const fetchUrl = 'https://api.thefuturetech.xyz/api/imageAnalysis/fetchDetailsByUid/${BACKEND_UID}';
    final response = await http.get(Uri.parse(fetchUrl));

    if (response.statusCode == 200) {
      setState(() {
        _analysisData = jsonDecode(response.body);
      });
    } else {
      print("Error: ${response.body}");
    }
  }

  @override
  void initState() {
    super.initState();
    loadCropDiseases();  // Load crop diseases data
    _fetchAnalysisData(); // Fetch analysis data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(title: Text("Image Analysis")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 16),
              Flexible(
                child: _buildAnalysisResult(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/uploadImage');
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: context.theme.primaryColorDark,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      'Analyse New Image',
                      style: TextStyle(color: context.theme.highlightColor, fontSize: 22),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the analysis result
  Widget _buildAnalysisResult() {
    if (_analysisData == null) {
      return Center(child: Text("Loading data..."));
    }

    if (!_analysisData!['exists']) {
      return Center(child: Text("No analysis results found."));
    }

    final results = _analysisData!['results'];
    if (results.isEmpty) {
      return Center(child: Text("No analysis details found."));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final cropName = result['cropName'] ?? "Unknown";
        final status = result['status'] ?? "Unknown";
        final diseaseName = result['diseaseName'] ?? "Unknown";
        final symptoms = result['symptoms'] ?? "Unknown";
        final cropImage = result['cropImage'] ?? '';

        return GestureDetector(
onTap: () {
    // Find the disease from cropDiseaseList based on the diseaseName
    final selectedDisease = cropDiseaseList.firstWhere(
      (disease) => disease['diseaseName'] == diseaseName, 
      orElse: () => <String, Object>{} // Explicitly cast to Map<String, Object>
    );

    // Check if the disease was found
    if (selectedDisease.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropDetails(disease: selectedDisease),
        ),
      );
    } else {
      // Handle case when disease is not found, e.g., show a message
      print("Disease not found: $diseaseName");
    }
  },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: context.theme.highlightColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cropImage.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        cropImage,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$diseaseName in $cropName", style: TextStyle(fontSize: 20, )),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.theme.focusColor,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text('$status'),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    "$symptoms",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
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

