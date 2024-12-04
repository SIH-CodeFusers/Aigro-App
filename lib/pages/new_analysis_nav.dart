import 'dart:io';
import 'dart:convert';
import 'package:aigro/local_db/db.dart';
import 'package:aigro/pages/image_analysis.dart';
import 'package:aigro/secret.dart';
import 'package:aigro/utils/analysis_translations.dart';
import 'package:aigro/utils/bottom_pages_list.dart';
import 'package:aigro/utils/translate.dart';
import 'package:aigro/widgets/bottom_nav.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:velocity_x/velocity_x.dart';

class NewAnalysisNav extends StatefulWidget {
  const NewAnalysisNav({super.key});

  @override
  _NewAnalysisNavState createState() => _NewAnalysisNavState();
}

class _NewAnalysisNavState extends State<NewAnalysisNav> {
  final ImagePicker _picker = ImagePicker();
  File? _cropImage;
  bool uploaded = false;
  bool isAnalyzing = false;
  String selectedCrop = "Corn";
  late Map<String, String> translations = {};
  late List<String> translatedCropOptions = [];
  late List<String> translatedStageOptions = [];

  final List<String> cropOptions = [
    "Corn",
    "Tomato",
    "Rice",
    "Apple",
    "Mango",
    "Banana",
    "Tea",
    "Cotton",
    "Sugarcane",
    "Jute"
  ];

  String selectedCropStage = "Vegetative Growth";

  final List<String> cropStageOptions = [
    "Vegetative Growth",
    "Reproductive Stage",
    "Seedling Stage",
    "Sowing",
    "Harvesting",
  ];

  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();
  FlutterTts flutterTts = FlutterTts();

  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();

  Future<void> _loadTranslations() async {
    translations = await AnalysisTranslations.getTranslations(ldb.language);
    translatedCropOptions = await AnalysisTranslations.translateCropOptions(cropOptions, ldb.language);
    translatedStageOptions = await AnalysisTranslations.translateCropOptions(cropStageOptions, ldb.language);
    setState(() {});
  }

  _speak(String text) async {
    String translatedText = await translateTextInput(text, ldb.language);
    await flutterTts.setLanguage(ldb.language);
    await flutterTts.setPitch(0.7);
    await flutterTts.speak(translatedText);
  }

  @override
  void initState() {
    bdb.loadDataInfo();
    if (languageBox.get("LANG") == null) {
      ldb.createLang();
    } else {
      ldb.loadLang();
    }
    _loadTranslations();
    super.initState();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      String? mimeType = lookupMimeType(file.path);
      if (mimeType != null && (mimeType.contains("jpg") || mimeType.contains("jpeg") || mimeType.contains("png"))) {
        if (await file.length() <= 500 * 1024) {
          setState(() {
            _cropImage = file;
          });
        } else {
          _showAlert(translations['file_size_error'] ?? 'File size exceeds 500kb limit.');
        }
      } else {
        _showAlert(translations['format_error'] ?? 'Please select a correct Image Format.');
      }
    }
  }

  Future<void> _uploadAndAnalyzeImage() async {
    if (_cropImage == null) {
      _showAlert(translations['upload_prompt'] ?? 'Please upload a crop image.');
      return;
    }

    try {
      String imgURL = await uploadImage(_cropImage!);
      await _newAnalysis(imgURL);
    } catch (error) {
      print("Error: $error");
    }
  }

  Future<String> uploadImage(File file) async {
    try {
      final String fileName = 'Test/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      final UploadTask uploadTask = storageRef.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload is $progress% done');
      });

      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      final String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (error) {
      throw Exception("Something went wrong: $error");
    }
  }

  Future<void> _newAnalysis(String imgURL) async {
    const analysisUrl = '$BACKEND_URL/api/imageAnalysis/newAnalysis';

    final data = {
      "useruid": BACKEND_UID,
      "cropName": selectedCrop,
      "cropImage": imgURL,
      "block": bdb.userBlock,
      "cropStage": selectedCropStage,
      "pinCode": bdb.userPin,
    };

    final response = await http.post(
      Uri.parse(analysisUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      _showSuccessMessage(await translateTextInput("New Analysis added successfully!", ldb.language));
    } else {
      print("Error: ${response.body}");
    }
    setState(() {
      uploaded = true;
      isAnalyzing = false;
    });
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: FutureBuilder<String>(
          future: translateTextInput(message, ldb.language),
          builder: (context, snapshot) {
            return Text(snapshot.data ?? message);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: FutureBuilder<String>(
              future: translateTextInput('OK', ldb.language),
              builder: (context, snapshot) {
                return Text(snapshot.data ?? 'OK');
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: FutureBuilder<String>(
          future: translateTextInput(message, ldb.language),
          builder: (context, snapshot) {
            return Text(snapshot.data ?? message);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder<String>(
                    future: translateTextInput(translations['title'] ?? '🌱 Create New Analysis', ldb.language),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? '🌱 Create New Analysis',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: context.theme.primaryColorDark,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon:  Icon(FeatherIcons.volume2),
                    color: context.theme.primaryColorDark,
                    onPressed: () => _speak(translations['voice_message'] ?? ''),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_cropImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_cropImage!.path),
                            height: 250,
                            width: 250,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                color: context.theme.highlightColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DottedBorder(
                                color: Colors.grey,
                                dashPattern: const [8, 4],
                                strokeWidth: 1,
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      width: 50,
                                      height: 50,
                                      "assets/images/upload_image.png",
                                      fit: BoxFit.cover,
                                    ),
                                    Center(
                                      child: FutureBuilder<String>(
                                        future: translateTextInput(
                                          translations['pick_image'] ?? 'Pick a Image from your Gallery',
                                          ldb.language
                                        ),
                                        builder: (context, snapshot) {
                                          return Text(
                                            snapshot.data ?? 'Pick a Image from your Gallery',
                                            style: TextStyle(
                                              color: context.theme.primaryColorDark,
                                              fontSize: 14,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.theme.primaryColorDark,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.theme.highlightColor,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: DropdownButton<String>(
                              value: selectedCrop,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCrop = newValue!;
                                });
                              },
                              dropdownColor: context.theme.highlightColor,
                              items: List.generate(
                                cropOptions.length,
                                (index) => DropdownMenuItem<String>(
                                  value: cropOptions[index],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                    child: FutureBuilder<String>(
                                      future: translateTextInput(cropOptions[index], ldb.language),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data ?? cropOptions[index],
                                          style: TextStyle(color: context.theme.primaryColorDark),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              isExpanded: true,
                              underline: const SizedBox(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              icon: const Icon(Icons.arrow_drop_down),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.theme.primaryColorDark,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.theme.highlightColor,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: DropdownButton<String>(
                              value: selectedCropStage,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCropStage = newValue!;
                                });
                              },
                              dropdownColor: context.theme.highlightColor,
                              items: List.generate(
                                cropStageOptions.length,
                                (index) => DropdownMenuItem<String>(
                                  value: cropStageOptions[index],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                    child: FutureBuilder<String>(
                                      future: translateTextInput(cropStageOptions[index], ldb.language),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data ?? cropStageOptions[index],
                                          style: TextStyle(color: context.theme.primaryColorDark),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              isExpanded: true,
                              underline: const SizedBox(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              icon: const Icon(Icons.arrow_drop_down),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (uploaded == false && isAnalyzing == false)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () {
                              _uploadAndAnalyzeImage();
                              setState(() {
                                isAnalyzing = true;
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
                                child: FutureBuilder<String>(
                                  future: translateTextInput(
                                    translations['submit_analysis'] ?? 'Submit for Analysis',
                                    ldb.language
                                  ),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? 'Submit for Analysis',
                                      style: TextStyle(
                                        color: context.theme.highlightColor,
                                        fontSize: 18,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (uploaded == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => ImageAnalysis()),
                                (Route<dynamic> route) => route.isFirst,
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                color: context.theme.primaryColorDark,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: FutureBuilder<String>(
                                  future: translateTextInput(
                                    translations['analysis_success'] ?? 'Image Analyzed Successfully',
                                    ldb.language
                                  ),
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? 'Image Analyzed Successfully',
                                      style: TextStyle(
                                        color: context.theme.highlightColor,
                                        fontSize: 20,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      if (isAnalyzing == true)
                        FutureBuilder<String>(
                          future: translateTextInput(
                            translations['analyzing'] ?? 'Analyzing Image. Please wait for few seconds...',
                            ldb.language
                          ),
                          builder: (context, snapshot) {
                            return Text(snapshot.data ?? 'Analyzing Image. Please wait for few seconds...');
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        pages: pages,
        selectedInd: 2,
      ),
    );
  }
}