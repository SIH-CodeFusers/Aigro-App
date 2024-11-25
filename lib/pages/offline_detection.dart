import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:velocity_x/velocity_x.dart';

class OfflineDetection extends StatefulWidget {
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

  Future detectimage(File image) async {
    // int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.05,
      imageMean: 120.5,
      imageStd: 120.5,
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
        title: Text('Offline Model'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(_image!.path),
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
                      dashPattern: [8, 4],
                      strokeWidth: 1,
                        borderType: BorderType.RRect, 
                        radius: Radius.circular(10),
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
                            child: Text('Pick a Image from your Gallery',
                              style: TextStyle(color: context.theme.primaryColorDark,fontSize: 14),
                            )
                          ),
                        ],
                      ),
                    ),
                  ),  
                ),
              ),
              SizedBox(height: 30),
              if (_image == null)
               Text('No image selected'),
              if (_image != null) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Detected disease:",
                      style: TextStyle(color: context.theme.cardColor, fontSize: 26),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "$diseaseName",
                      style: TextStyle(color: context.theme.cardColor, fontSize: 30),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: GestureDetector(
                    onTap: () {
                      
                    },
                    child: Container(
                      width: 250,
                      height: 60,
                      decoration: BoxDecoration(
                        color: context.theme.primaryColorDark,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'View Remedy',
                          style: TextStyle(color: context.theme.highlightColor, fontSize: 22),
                        ),
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
}
