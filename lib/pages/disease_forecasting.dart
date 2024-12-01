import 'dart:convert';
import 'package:aigro/local_db/db.dart';
import 'package:aigro/pages/crop_details.dart';
import 'package:aigro/secret.dart';
import 'package:aigro/utils/translate.dart';
import 'package:aigro/widgets/voice_icon.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  List<Map<String, dynamic>> cropDiseaseList = [];

  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();
  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();

  @override
  void initState() {
    super.initState();
    if(languageBox.get("LANG") == null){
      ldb.createLang();
    }
    else{
      ldb.loadLang();
    }
    bdb.loadDataInfo(); 
    fetchAlerts();
    loadCropDiseases();
  }


  FlutterTts flutterTts = FlutterTts();
  _speak(String text) async {
    String translatedText = await translateTextInput(text, ldb.language);
    await flutterTts.setLanguage(ldb.language);
    await flutterTts.setPitch(0.7);
    await flutterTts.speak(translatedText);
  }

  String findRisk(int value) {
    if (value < 7) {
      return "Low Risk";
    } else if (value >= 7 && value <= 15) {
      return "Rising";
    } else {
      return "High Warning";
    }
  }

  Color getRiskColor(int count) {
    if (count < 7) {
      return  Color.fromARGB(255, 208, 255, 210); 
    } else if (count >= 7 && count <= 15) {
      return Color.fromRGBO(255, 245, 156,1);
    } else {
      return Color.fromRGBO(255, 204, 128,1);
    }
  }

  String toSentenceCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  String placeholderImage = 'https://placehold.co/600x400/EEE/31343C';
  late Future<List<Map<String, String>>> cropDiseases;

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
                  "remedies":
                      (disease['remedies'] as List?)?.map((r) => r as String).toList() ?? [],
                  "summary":
                      (disease['summary'] as List?)?.map((r) => r as String).toList() ?? [],
                  "chemicalControl": disease['chemicalControl'] as String? ?? '',
                  "organicControl": disease['organicControl'] as String? ?? '',
                  "cropName": crop['cropName'] as String,
                  "fertilizers": (disease['fertilisers'] as List?)?.map((fertilizer) {
                    return {
                      "name": fertilizer['name'] as String,
                      "products": (fertilizer['products'] as List).map((product) {
                        return {
                          "companyName": product['companyName'] as String,
                          "productImage": product['productImage'] as String,
                          "price": product['price'] as String,
                          "id": product['id'] as String,
                        };
                      }).toList(),
                      "id": fertilizer['id'] as String,
                    };
                  }).toList() ?? [],
                };
              }))
          .toList();
    });
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
                          MaterialPageRoute(builder: (context) => const DiseaseForecasting()), 
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
                      ...alert['diseaseDetails'].map<Widget>((dis) {
                        final imageUrl = (dis['images'] as List).isNotEmpty 
                            ? dis['images'][0] 
                            : placeholderImage;
              
                        return GestureDetector(
                          onTap: () {    
                            final selectedDisease = cropDiseaseList.firstWhere(
                              (disease) => disease['diseaseName']?.trim() == toSentenceCase(dis['diseaseName']?.trim() ?? ''),
                              orElse: () => <String, Object>{},
                            );
              
                            if (selectedDisease.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CropDetails(disease: selectedDisease),
                                ),
                              );
                            } else {
              
                              print("Disease not found: ${toSentenceCase(dis['diseaseName'] ?? '')}");
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Stack(             
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.network(
                                            placeholderImage,
                                            width: double.infinity,
                                            height: 150,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          '${alert['cropName']}',
                                          style: TextStyle(
                                            color: context.theme.primaryColorDark,
                                            fontSize: 22,
                                          ),
                                        ),
                                        Spacer(),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: getRiskColor(dis['count']),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${findRisk(int.parse(dis['count'].toString()))}',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${toTitleCase(dis['diseaseName'])}',
                                      style: TextStyle(
                                        color: context.theme.primaryColorDark,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8, 
                                  child: GestureDetector(
                                    onTap: () {
                                      _speak("Detected ${dis['diseaseName']} in ${alert['cropName']} ");
                                    },
                                    child: voiceIcon(context),
                                  )
                                ),
                              ],
                            ),
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