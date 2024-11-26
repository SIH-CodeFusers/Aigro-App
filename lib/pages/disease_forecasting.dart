import 'dart:convert';
import 'package:aigro/local_db/db.dart';
import 'package:aigro/secret.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class DiseaseForecasting extends StatefulWidget {
  const DiseaseForecasting({super.key});

  @override
  State<DiseaseForecasting> createState() => _DiseaseForecastingState();
}

class _DiseaseForecastingState extends State<DiseaseForecasting> {
  bool isLoading = true;
  bool exists = false;
  List alerts = [];
  String imageUrl = "";

  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();

  @override
  void initState() {
    super.initState();
    bdb.loadDataInfo(); 
    fetchAlerts();
  }

  String placeholderImage = 'https://placehold.co/600x400/EEE/31343C';
  late Future<List<Map<String, String>>> cropDiseases;

  Future<List<Map<String, String>>> loadCropDiseases() async {
    final String data = await DefaultAssetBundle.of(context)
        .loadString('assets/others/crop_disease_18nov.json');
    final Map<String, dynamic> jsonResult = json.decode(data);

    return (jsonResult['cropDiseases'] as List)
        .expand((crop) => (crop['diseaseDetails'] as List)
            .map((disease) => {
                  "diseaseName": disease['diseaseName'] as String,
                  "category": disease['category'] as String,
                  "image": (disease['images'] as List).isNotEmpty
                      ? disease['images'][0] as String
                      : '',
                }))
        .toList();
  }

  Future<String> getDiseaseImageUrl(String diseaseName) async {
    final diseases = await loadCropDiseases();
    final disease = diseases.firstWhere(
      (disease) => disease['diseaseName']!.toLowerCase() == diseaseName.toLowerCase(),
      orElse: () => {},
    );
    return disease.isNotEmpty ? disease['image']! : placeholderImage;
  }

  Future<void> fetchAlerts() async {
    final url = Uri.parse('${BACKEND_URL}/api/futurePred/fetchAlerts/${bdb.userPin}'); 
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          exists = data['exists'];
          if (exists) {
            alerts = data['alerts'];
          }
          isLoading = false;
        });
    
        for (var alert in alerts) {
          for (var disease in alert['diseaseDetails']) {
            final diseaseName = disease['diseaseName'] as String;
            final diseaseImageUrl = await getDiseaseImageUrl(diseaseName);
            setState(() {
              imageUrl = diseaseImageUrl;
            });
          }
        }
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load alerts');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  String toTitleCase(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text.split(' ').map((word) {
      return word.isNotEmpty
          ? word[0].toUpperCase() + word.substring(1).toLowerCase()
          : '';
    }).join(' ');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        title: Text('Disease Forecasting'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(
              color: context.theme.primaryColorDark,
            ))
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Expanded(
                  child: _buildForecasting(),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => DiseaseForecasting()), 
                        );
                      });
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
                          'Check Alerts',
                          style: TextStyle(color: context.theme.highlightColor, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildForecasting() {
    if (!exists) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FeatherIcons.slash, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Text(
                  'No alerts found.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(FeatherIcons.slash, color: Colors.red, size: 18),
              ],
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Container(
            padding: EdgeInsets.all(12),
            width: double.infinity, 
            decoration: BoxDecoration(
              color: context.theme.highlightColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                            imageUrl)
                        : Image.network(
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                            placeholderImage),
                  ),
                  SizedBox(height: 10),
                  ...alert['diseaseDetails'].map<Widget>((disease) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${alert['cropName']}',
                                style: TextStyle(
                                  color: context.theme.primaryColorDark,
                                  fontSize: 24,
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('${disease['alertLevel']} Risk'),
                              ),
                            ],
                          ),
                          Text(
                            '${toTitleCase(disease['diseaseName'])}',
                            style: TextStyle(
                              color: context.theme.primaryColorDark,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}