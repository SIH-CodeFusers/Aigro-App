import 'dart:io';
import 'dart:convert';
import 'package:aigro/local_db/db.dart';
import 'package:aigro/pages/image_analysis.dart';
import 'package:aigro/secret.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:velocity_x/velocity_x.dart';

class UploadImage extends StatefulWidget {
  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  final ImagePicker _picker = ImagePicker();
  File? _cropImage;
  bool uploaded=false;
  bool isAnalyzing=false;
  String selectedCrop = "Corn";

  final List<String> cropOptions = [
    "Corn",
    "Tomato",
    "Rice",
    "Apple",
    "Mango",
    "Banana",
    "Tea",
  ];

  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();

   @override
  void initState() {
    bdb.loadDataInfo(); 
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
          _showAlert("File size exceeds 500kb limit.");
        }
      } else {
        _showAlert("Please select a correct Image Format.");
      }
    }
  }

  Future<void> _uploadAndAnalyzeImage() async {
    if (_cropImage == null) {
      _showAlert("Please upload a crop image.");
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
    const analysisUrl = '${BACKEND_URL}/api/imageAnalysis/newAnalysis';

    final data = {
      "useruid":BACKEND_UID,
      "cropName": selectedCrop,
      "cropImage": imgURL,
      "block": bdb.userBlock,
      "pinCode": bdb.userPin,
    };

    final response = await http.post(
      Uri.parse(analysisUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      _showSuccessMessage("New Analysis added successfully!");
      
    } else {
      print("Error: ${response.body}");
    }
    setState(() {
      uploaded=true;
      isAnalyzing=false;
    });
  }


  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(title: Text("Create New Analysis")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_cropImage != null) 
              Image.file(
                  File(_cropImage!.path),
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                )
              else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: _pickImage,
                  child: DottedBorder(
                        color: context.theme.cardColor,
                        dashPattern: [8, 4],
                        strokeWidth: 1,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: context.theme.highlightColor,
                        borderRadius: BorderRadius.circular(10),
                      ),  
                      child: Center(
                        child: Text('Pick a Image from your Gallery',
                          style: TextStyle(color: context.theme.primaryColorDark,fontSize: 16),
                        )
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity, 
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.theme.cardColor, 
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8), 
                  ),
                  child: DropdownButton<String>(
                    value: selectedCrop,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCrop = newValue!;
                      });
                    },
                    items: cropOptions.map<DropdownMenuItem<String>>((String crop) {
                      return DropdownMenuItem<String>(
                        value: crop,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(crop),
                        ),
                      );
                    }).toList(),
                    isExpanded: true, 
                    underline: SizedBox(), 
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.black, 
                    ),
                    icon: Icon(Icons.arrow_drop_down),
                  ),
                ),
              ),
              SizedBox(height: 40,),

              if(uploaded==false)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      _uploadAndAnalyzeImage();
                      setState(() {
                        isAnalyzing=true;
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
                          'Submit for Analysis',
                          style: TextStyle(color: context.theme.highlightColor, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
                // SizedBox(height: 20,),

                if(uploaded==true)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      // _uploadAndAnalyzeImage();
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
                        child: Text(
                          'Image Analyzed Successfully',
                          style: TextStyle(color: context.theme.highlightColor, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20,),

                if(isAnalyzing==true)
                Text("Analyzing Image. Please wait for few seconds...")

            ],
          ),
        ),
      ),
    );
  }


}
