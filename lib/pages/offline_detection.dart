import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class OfflineDetection extends StatefulWidget {
  @override
  _OfflineDetectionState createState() => _OfflineDetectionState();
}

class _OfflineDetectionState extends State<OfflineDetection> {
  late Interpreter interpreter;
  bool isModelLoaded = false;
  int? modelResult;
  Uint8List? inputImage;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {

      interpreter = await Interpreter.fromAsset('assets/others/app_model.tflite');
      setState(() {
        isModelLoaded = true;
      });
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  Future<void> selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        inputImage = bytes;
      });
      // Automatically run the model after selecting an image
      runModelOnImage(bytes);
    }
  }

  Future<void> runModelOnImage(Uint8List input) async {
    if (!isModelLoaded) return;

    // Preprocess input if necessary (resize, normalize, etc.)
    var output = List.filled(1, 0).reshape([1, 1]);

    try {
      interpreter.run(input, output); // Run the model on the input
      setState(() {
        modelResult = output[0][0]; // Update the result
      });
    } catch (e) {
      print("Error running model: $e");
    }
  }

  @override
  void dispose() {
    interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TFLite Model Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            if (inputImage != null)
              Image.memory(
                inputImage!,
                 height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            else
              Text('No image selected'),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: selectImage,
              child: Text('Select Image'),
            ),

            SizedBox(height: 20),

            if (modelResult != null)
              Text(
                'Model Output: $modelResult',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            else
              Text('Run the model to see output'),
          ],
        ),
      ),
    );
  }
}
