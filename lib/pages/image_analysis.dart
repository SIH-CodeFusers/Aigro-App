import 'dart:convert';
import 'package:aigro/local_db/db.dart';
import 'package:aigro/pages/crop_details.dart';
import 'package:aigro/pages/dis_management.dart';
import 'package:aigro/secret.dart';
import 'package:aigro/widgets/voice_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:velocity_x/velocity_x.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ImageAnalysis extends StatefulWidget {
  const ImageAnalysis({super.key});

  @override
  _ImageAnalysisState createState() => _ImageAnalysisState();
}

class _ImageAnalysisState extends State<ImageAnalysis> {
  Map<String, dynamic>? _analysisData;
  List<Map<String, dynamic>> cropDiseaseList = [];

  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();
  FlutterTts flutterTts = FlutterTts();
  _speak(String text) async {
    await flutterTts.setLanguage(ldb.language); 
    await flutterTts.setPitch(0.7); 
    await flutterTts.speak(text); 
  }

  final GlobalKey _pngKey = GlobalKey();

  Future<void> _captureAndSaveImage() async {
    try {
      RenderRepaintBoundary boundary = _pngKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/analysis_result.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:  Text(
              'Image Saved',
              style: TextStyle(color: context.theme.cardColor),
            ),
            content: const Text('Would you like to open the saved image?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: context.theme.cardColor)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  OpenFile.open(filePath);
                },
                child:  Text('Open', style: TextStyle(color: context.theme.highlightColor)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          );
        },
      );
      }
    } catch (e) {
      print("Error capturing image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildLeafyUI(String cropName, String diseaseName, String symptoms, String cropImage) {
    return RepaintBoundary(
      key: _pngKey,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient:  LinearGradient(
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
                "Crop Analysis Result",
                style: TextStyle(
                  fontSize: 24,
                  color: context.theme.highlightColor,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
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
                "Crop: $cropName",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "Disease: $diseaseName",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                "Symptoms: $symptoms",
                style: TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Future<void> _fetchAnalysisData() async {
    const fetchUrl = '$BACKEND_URL/api/imageAnalysis/fetchDetailsByUid/$BACKEND_UID';
    final response = await http.get(Uri.parse(fetchUrl));

    if (response.statusCode == 200) {
      setState(() {
        _analysisData = jsonDecode(response.body);

        if (_analysisData?["exists"] == true && _analysisData?["results"] != null) {
          _analysisData?["results"] = List.from(_analysisData?["results"].reversed);
        }
      });
    } else {
      print("Error: ${response.body}");
    }
  }
  @override
  void initState() {
    super.initState();
     if(languageBox.get("LANG") == null){
      ldb.createLang();
    }
    else{
      ldb.loadLang();
    }
    loadCropDiseases();
    _fetchAnalysisData(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  title: Row(
    children: [
      const Icon(
        Icons.spa,
        color: Colors.green,
        size: 24, 
      ),
      const SizedBox(width: 8), 
      const Text(
        "Analysis Results",
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(width: 10), 
      IconButton(
        icon: const Icon(Icons.volume_up_rounded, color: Colors.green),
        tooltip: 'Speak',
        onPressed: () {
          
          final text =
              "Here are the Results of the Image Analysis";
          _speak(text);
        },
      ),
    ],
  ),
  centerTitle: false,
),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_analysisData != null && _analysisData!['results'] != null) {
            final result = _analysisData!['results'][0];
            final cropName = result['cropName'] ?? "Unknown";
            final diseaseName = result['diseaseName'] ?? "Unknown";
            final symptoms = result['symptoms'] ?? "Unknown";
            final cropImage = result['cropImage'] ?? '';
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (_) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  minChildSize: 0.4,
                  maxChildSize: 0.9,
                  expand: false,
                  builder: (_, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLeafyUI(cropName, diseaseName, symptoms, cropImage),
                       Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_analysisData != null && _analysisData!['results'] != null) {
                          _captureAndSaveImage();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No analysis data available")),
                          );
                        }
                      },
                      icon:  Icon(Icons.save_alt, color: context.theme.highlightColor),
                      label:  Text('Save as PNG', style: TextStyle(color: context.theme.highlightColor)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No analysis data available")),
            );
          }
        },
        backgroundColor: context.theme.focusColor,
        child: const Icon(FeatherIcons.save),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
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
                  Navigator.pushNamed(context, '/newAnalysis');
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
                      'Analyze New Image',
                      style: TextStyle(color: context.theme.highlightColor, fontSize: 18),
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

        final manStatus = result['managementStatus'] ?? '';
        final soilDeficiency = result['soilDeficiency'] ?? {};
        final weatherSeverity = result['weatherSeverity'] ?? {};
        final severity = result['severity'] ?? '';
        final recoveryDays = result['recoveryDays'] ?? 0;
        final yieldLoss = result['yeildLoss'] ?? 0;
        final cropid = result['id'] ?? 0;

        return GestureDetector(
           onTap: () {    
            final selectedDisease = cropDiseaseList.firstWhere(
              (disease) => disease['diseaseName'] == diseaseName, 
              orElse: () => <String, Object>{} 
            );

            if (manStatus=='completed'&& selectedDisease.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiseaseManagement(
                    soilDeficiency: soilDeficiency,
                     recoveryDays: recoveryDays, 
                     weatherSeverity: weatherSeverity, 
                     severity: severity, 
                     yieldLoss: yieldLoss,
                     diseaseName:diseaseName,
                     cropId:cropid,
                     cropName:cropName,
                    
                  ),
                ),
              );
            } else if (manStatus=='failed'&& selectedDisease.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CropDetails(disease: selectedDisease),
                ),
              );
            }else {

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
                            onTap: () {
                              _speak("$diseaseName in $cropName. $symptoms ");
                            },
                            child: voiceIcon(context),
                          )
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "$diseaseName in $cropName",
                          style: const TextStyle(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.theme.focusColor,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    symptoms,
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