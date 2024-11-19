import 'dart:io';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

class ImageAnalysis extends StatefulWidget {
  @override
  _ImageAnalysisState createState() => _ImageAnalysisState();
}

class _ImageAnalysisState extends State<ImageAnalysis> {
  final ImagePicker _picker = ImagePicker();
  File? _cropImage;
  Map<String, dynamic>? _analysisData;

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
      await _fetchAnalysisData();
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
    const analysisUrl = 'https://api.thefuturetech.xyz/api/imageAnalysis/newAnalysis';

    final data = {
      "useruid": "user_2ozYA1JorKYVMjC0kVNdnLTLevt",
      "cropName": "Mango",
      "cropImage": imgURL,
      "block": "DHANIAKHALI",
      "pinCode": "700042"
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
  }

  Future<void> _fetchAnalysisData() async {
    const fetchUrl = 'https://api.thefuturetech.xyz/api/imageAnalysis/fetchDetailsByUid/user_2ozYA1JorKYVMjC0kVNdnLTLevt';

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
    _fetchAnalysisData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Analysis")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_cropImage != null) Image.file(_cropImage!, height: 150),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("Upload Crop Image"),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _uploadAndAnalyzeImage,
                  child: Text("Submit for Analysis"),
                ),
              SizedBox(height: 16),
              _buildAnalysisResult(),
              SizedBox(height: 16),
              
            ],
          ),
        ),
      ),
    );
  }

Widget _buildAnalysisResult() {
  if (_analysisData == null) {
    return Text("Loading data...");
  }

  if (!_analysisData!['exists']) {
    return Text("No analysis results found.");
  }

  final results = _analysisData!['results'];
  if (results.isEmpty) {
    return Text("No analysis details found.");
  }

  return Container(
    height: 300,
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final cropName = result['cropName'] ?? "Unknown";
        final status = result['status'] ?? "Unknown";
        final diseaseName = result['diseaseName'] ?? "Unknown";
    
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Crop Name: $cropName", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Status: $status", style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text("Disease Name: $diseaseName", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    ),
  );
}
}

