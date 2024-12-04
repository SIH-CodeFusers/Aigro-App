import 'dart:convert';
import 'package:aigro/local_db/db.dart';
import 'package:aigro/pages/crop_details.dart';
import 'package:aigro/pages/dis_management.dart';
import 'package:aigro/secret.dart';
import 'package:aigro/utils/translate.dart';
import 'package:aigro/widgets/voice_icon.dart';
import 'package:aigro/widgets/analysis_result_card.dart';
import 'package:aigro/widgets/leafy_ui.dart';
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
  String _translatedTitle = "Analysis Results";
  String _translatedNoData = "No analysis results found.";
  String _translatedLoading = "Loading data...";
  String _translatedNoDetails = "No analysis details found.";
  String _translatedAnalyzeNew = "Analyze New Image";
  String _translatedImageSaved = "Image saved successfully!";
  String _translatedImageSavedTitle = "Image Saved";
  String _translatedOpenImage = "Would you like to open the saved image?";
  String _translatedCancel = "Cancel";
  String _translatedOpen = "Open";
  String _translatedSaveAsPNG = "Save as PNG";
  String _translatedNoAnalysisData = "No analysis data available";
  String _translatedDataRefreshed = "Data refreshed successfully.";

  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();
  FlutterTts flutterTts = FlutterTts();
  final GlobalKey _pngKey = GlobalKey();

  Future<void> _translateUITexts() async {
    String targetLanguage = ldb.language;
    if(targetLanguage=="en"){
      return;
    }
    setState(() async {
      _translatedTitle = await translateTextInput("Analysis Results", ldb.language);
      _translatedNoData = await translateTextInput("No analysis results found.", ldb.language);
      _translatedLoading = await translateTextInput("Loading data...", ldb.language);
      _translatedNoDetails = await translateTextInput("No analysis details found.", ldb.language);
      _translatedAnalyzeNew = await translateTextInput("Analyze New Image", ldb.language);
      _translatedImageSaved = await translateTextInput("Image saved successfully!", ldb.language);
      _translatedImageSavedTitle = await translateTextInput("Image Saved", ldb.language);
      _translatedOpenImage = await translateTextInput("Would you like to open the saved image?", ldb.language);
      _translatedCancel = await translateTextInput("Cancel", ldb.language);
      _translatedOpen = await translateTextInput("Open", ldb.language);
      _translatedSaveAsPNG = await translateTextInput("Save as PNG", ldb.language);
      _translatedNoAnalysisData = await translateTextInput("No analysis data available", ldb.language);
      _translatedDataRefreshed = await translateTextInput("Data refreshed successfully.", ldb.language);
    });
  }

  _speak(String text) async {
    String translatedText = await translateTextInput(text, ldb.language);
    await flutterTts.setLanguage(ldb.language);
    await flutterTts.setPitch(0.7);
    await flutterTts.speak(translatedText);
  }

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
          SnackBar(
            content: Text(_translatedImageSaved),
            duration: const Duration(seconds: 2),
          ),
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                _translatedImageSavedTitle,
                style: TextStyle(color: context.theme.cardColor),
              ),
              content: Text(_translatedOpenImage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_translatedCancel, style: TextStyle(color: context.theme.cardColor)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    OpenFile.open(filePath);
                  },
                  child: Text(_translatedOpen, style: TextStyle(color: context.theme.highlightColor)),
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

  void _handleCardTap(Map<String, dynamic> result) {
    final diseaseName = result['diseaseName'] ?? "Unknown";
    final cropName = result['cropName'] ?? "Unknown";
    final manStatus = result['managementStatus'] ?? '';
    final soilDeficiency = result['soilDeficiency'] ?? {};
    final weatherSeverity = result['weatherSeverity'] ?? {};
    final severity = result['severity'] ?? '';
    final recoveryDays = result['recoveryDays'] ?? 0;
    final yieldLoss = result['yeildLoss'] ?? 0;
    final cropid = result['id'] ?? 0;

    final selectedDisease = cropDiseaseList.firstWhere(
      (disease) => disease['diseaseName'] == diseaseName,
      orElse: () => <String, Object>{},
    );

    if (manStatus == 'completed' && selectedDisease.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiseaseManagement(
            soilDeficiency: soilDeficiency,
            recoveryDays: recoveryDays,
            weatherSeverity: weatherSeverity,
            severity: severity,
            yieldLoss: yieldLoss,
            diseaseName: diseaseName,
            cropId: cropid,
            cropName: cropName,
          ),
        ),
      );
    } else if (manStatus == 'failed' && selectedDisease.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropDetails(disease: selectedDisease),
        ),
      );
    } else {
      print("Disease not found: $diseaseName");
    }
  }

  @override
  void initState() {
    super.initState();
    if (languageBox.get("LANG") == null) {
      ldb.createLang();
    } else {
      ldb.loadLang();
    }
    loadCropDiseases();
    _fetchAnalysisData();
    _translateUITexts();
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
            const SizedBox(width: 8),
            Text(
              _translatedTitle,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(FeatherIcons.volume2, color: context.theme.primaryColorDark),
              tooltip: 'Speak',
              onPressed: () {
                final text = "Here are the Results of the Image Analysis";
                _speak(text);
              },
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.theme.primaryColorDark),
            tooltip: 'Refresh',
            onPressed: () {
              setState(() {
                _fetchAnalysisData();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_translatedDataRefreshed),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
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
                        LeafyUI(
                          cropName: cropName,
                          diseaseName: diseaseName,
                          symptoms: symptoms,
                          cropImage: cropImage,
                          language: ldb.language,
                          repaintKey: _pngKey,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_analysisData != null && _analysisData!['results'] != null) {
                                _captureAndSaveImage();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(_translatedNoAnalysisData)),
                                );
                              }
                            },
                            icon: Icon(Icons.save_alt, color: context.theme.highlightColor),
                            label: Text(_translatedSaveAsPNG,
                                style: TextStyle(color: context.theme.highlightColor)),
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
              SnackBar(content: Text(_translatedNoAnalysisData)),
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
                      _translatedAnalyzeNew,
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
      return Center(child: Text(_translatedLoading));
    }

    if (!_analysisData!['exists']) {
      return Center(child: Text(_translatedNoData));
    }

    final results = _analysisData!['results'];
    if (results.isEmpty) {
      return Center(child: Text(_translatedNoDetails));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return AnalysisResultCard(
          result: result,
          onTap: () => _handleCardTap(result),
          onSpeak: _speak,
          language: ldb.language,
        );
      },
    );
  }
}