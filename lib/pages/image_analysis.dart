import 'dart:convert';
import 'package:aigro/pages/crop_details.dart';
import 'package:aigro/secret.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';
import 'package:aigro/secret.dart';

class ImageAnalysis extends StatefulWidget {
  const ImageAnalysis({super.key});

  @override
  _ImageAnalysisState createState() => _ImageAnalysisState();
}

class _ImageAnalysisState extends State<ImageAnalysis> {
  Map<String, dynamic>? _analysisData;
  List<Map<String, dynamic>> cropDiseaseList = [];

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
                  "summary":(disease['summary'] as List?)?.map((r) => r as String).toList() ?? [],
                  "chemicalControl": disease['chemicalControl'] as String? ?? '',
                  "cropName": crop['cropName'] as String,
                };
              }))
          .toList();
    });
  }

  Future<void> _fetchAnalysisData() async {
    const fetchUrl = '$BACKEND_URL/api/imageAnalysis/fetchDetailsByUid/$BACKEND_UID';
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
    loadCropDiseases();
    _fetchAnalysisData(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(title: const Text("Image Analysis")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
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


  Widget _buildAnalysisResult() {
    if (_analysisData == null) {
      return const Center(child: Text("Loading data..."));
    }

    if (!_analysisData!['exists']) {
      return const Center(child: Text("No analysis results found."));
    }

    final results = _analysisData!['results'];
    if (results.isEmpty) {
      return const Center(child: Text("No analysis details found."));
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
            final selectedDisease = cropDiseaseList.firstWhere(
              (disease) => disease['diseaseName'] == diseaseName, 
              orElse: () => <String, Object>{} // Explicitly cast to Map<String, Object>
            );

            if (selectedDisease.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CropDetails(disease: selectedDisease),
                ),
              );
            } else {

              print("Disease not found: $diseaseName");
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: diseaseName == "Unknown" 
          ? context.theme.highlightColor.withOpacity(0.8)
          : context.theme.highlightColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 200
                        ),
                        child: Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          "$diseaseName in $cropName", style: const TextStyle(fontSize: 20, )
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.theme.focusColor,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text('$status'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "$symptoms",
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

