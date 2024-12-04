import 'package:aigro/local_db/db.dart';
import 'package:aigro/utils/translate.dart';
import 'package:aigro/widgets/voice_icon.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:math';
import 'package:image/image.dart' as img;

class OfflineDetection extends StatefulWidget {
  const OfflineDetection({super.key});

  @override
  _OfflineDetectionState createState() => _OfflineDetectionState();
}

class _OfflineDetectionState extends State<OfflineDetection> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var v = "";

  String diseaseName="";

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
    if(languageBox.get("LANG") == null){
      ldb.createLang();
    }
    else{
      ldb.loadLang();
    }
  }

  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();
  FlutterTts flutterTts = FlutterTts();
  _speak(String text) async {
    String translatedText = await translateTextInput(text, ldb.language);
    await flutterTts.setLanguage(ldb.language);
    await flutterTts.setPitch(0.7);
    await flutterTts.speak(translatedText);
  }



  Future<double> calculateMean(File imageFile)  async{

    final imageBytes = await imageFile.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      print("Could not decode image.");
      return 0.0;
    }
    List<int> pixels = [];
    for (int y = 0; y < decodedImage.height; y++) {
      for (int x = 0; x < decodedImage.width; x++) {
        int pixel = decodedImage.getPixel(x, y) as int;
        pixels.add(pixel);
      }
    }
    double mean = pixels.reduce((a, b) => a + b) / pixels.length;

    return mean;
}

  Future<double> calculateStdDev(File imageFile) async  {
    final imageBytes = await imageFile.readAsBytes();
    final img.Image? decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      print("Could not decode image.");
      return 0.0;
    }

    List<int> pixels = [];
    for (int y = 0; y < decodedImage.height; y++) {
      for (int x = 0; x < decodedImage.width; x++) {
        int pixel = decodedImage.getPixel(x, y) as int;
        pixels.add(pixel);
      }
    }

    double mean = pixels.reduce((a, b) => a + b) / pixels.length;


    double variance = pixels
        .map((pixel) => pow(pixel - mean, 2))
        .reduce((a, b) => a + b) /
        pixels.length;
    double stdDev = sqrt(variance);

    return stdDev;
  }

  void showCustomToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100, 
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.theme.highlightColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(FeatherIcons.x,color: context.theme.highlightColor,size: 12,)
                ),
                SizedBox(width: 10,),
                translateHelper(message, TextStyle(color: Colors.red, fontSize: 18), ldb.language)
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
      model: "assets/others/app_model.tflite",
      labels: "assets/others/labels.txt",
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image;
        file = File(image!.path);
      });
      detectimage(file!);
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      // Reset both _image and file to null, removing the selected image
      _image = null;
      file = null;
    });
  }

  Future detectimage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.05,
      imageMean: 100,
      imageStd:100,
    );
    setState(() {
      _recognitions = recognitions;
      v = recognitions.toString();
      diseaseName = recognitions?[0]['label'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        title:  translateHelper('Offline Model', TextStyle(), ldb.language),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
                icon: const Icon(FeatherIcons.volume2),
                color: context.theme.primaryColorDark,
                onPressed: () => _speak('Upload any image and get crop disease results instantly'),
              ),
          ),
        ]   
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_image != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(_image!.path),
                        height: 250,
                        width: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8, 
                      child: GestureDetector(
                        onTap: (){
                         _removeImage();
                        },
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            FeatherIcons.x,
                            size: 16,
                          ),
                        ),
                      )
                    ),
                  ],
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
                            child: translateHelper('Pick a Image from your Gallery',TextStyle(color: context.theme.primaryColorDark,fontSize: 14),ldb.language)
                          ),
                        ],
                      ),
                    ),
                  ),  
                ),
              ),
              const SizedBox(height: 30),
              if (_image == null)
              translateHelper('No image selected', const TextStyle(), ldb.language),
              if (_image != null) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: translateHelper("Detected disease:",TextStyle(color: context.theme.cardColor, fontSize: 24),ldb.language)
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: translateHelper(diseaseName, TextStyle(color: context.theme.cardColor, fontSize: 28), ldb.language)
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: GestureDetector(
                    onTap: () {
                      showCustomToast(context, 'Currently Unavailable');
                    },
                    child: Container(
                      width: 250,
                      height: 60,
                      decoration: BoxDecoration(
                        color: context.theme.primaryColorDark,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(     
                        child:translateHelper('View Remedy', TextStyle(color: context.theme.highlightColor, fontSize: 20), ldb.language)
                      ),
                    ),
                  ),
                ),
              ]
             
            ],
          ),
        ),
      ),
    );
  }
  FutureBuilder<String> translateHelper(String title, TextStyle style, String lang) {
    return FutureBuilder<String>(
      future: translateTextInput(title, lang),
      builder: (context, snapshot) {
        String displayText = snapshot.connectionState == ConnectionState.waiting || snapshot.hasError
            ? title
            : snapshot.data ?? title;

        return Text(displayText, style: style);
      },
    );
  }
}
