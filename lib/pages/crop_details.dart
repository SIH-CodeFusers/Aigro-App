import 'package:aigro/widgets/voice_icon.dart';
import 'package:flutter/material.dart';
import 'package:aigro/utils/translate.dart';
import 'package:aigro/secret.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:aigro/local_db/db.dart';
import 'package:velocity_x/velocity_x.dart';

class CropDetails extends StatefulWidget {
  final Map<String, dynamic> disease;

  const CropDetails({Key? key, required this.disease}) : super(key: key);

  @override
  State<CropDetails> createState() => _CropDetailsState();
}

class _CropDetailsState extends State<CropDetails> {
  String userLang = "en";
  late Map<String, dynamic> diseaseDetails;
  final languageBox = Hive.box("Language_db");
  final LanguageDB ldb = LanguageDB();

  @override
  void initState() {
    super.initState();
    if (languageBox.get("LANG") == null) {
      ldb.createLang();
      userLang = ldb.language;
    } else {
      ldb.loadLang();
      userLang = ldb.language;
    }
    diseaseDetails = widget.disease;
    if (userLang != "en") {
      translateDiseaseDetails(diseaseDetails);
    }
  }

  FlutterTts flutterTts = FlutterTts();

  _speak(String text) async {
    await flutterTts.setLanguage("en-US"); 
    await flutterTts.setPitch(0.7); 
    await flutterTts.speak(text); 
  }

  Future<void> translateDiseaseDetails(Map<String, dynamic> disease) async {
    final String targetLanguage = userLang;
    final String apiKey = GCP_API_KEY;

    try {
      final String translatedDiseaseName = await translateText(disease['diseaseName'], targetLanguage, apiKey);
      final String translatedCategory = await translateText(disease['category'], targetLanguage, apiKey);
      final String translatedSymptoms = await translateText(disease['symptoms'], targetLanguage, apiKey);
      final String translatedCauses = await translateText(disease['causes'], targetLanguage, apiKey);
      final String translatedChemicalControl = await translateText(disease['chemicalControl'], targetLanguage, apiKey);

      final List<String> translatedRemedies = [];
      for (final remedy in disease['remedies']) {
        translatedRemedies.add(await translateText(remedy, targetLanguage, apiKey));
      }

      if (mounted) {
        setState(() {
          disease['diseaseName'] = translatedDiseaseName;
          disease['category'] = translatedCategory;
          disease['symptoms'] = translatedSymptoms;
          disease['causes'] = translatedCauses;
          disease['remedies'] = translatedRemedies;
          disease['chemicalControl'] = translatedChemicalControl;
        });
      }
    } catch (e) {
      debugPrint("Error translating disease details: $e");
    }
  }

  Widget _buildImageGallery(List<String> images) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                images[index],
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error_outline),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          diseaseDetails["diseaseName"] ?? "Disease Details",
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Chip(
                      label: Text(diseaseDetails["cropName"]),
                      backgroundColor: context.theme.highlightColor,
                      shape: StadiumBorder(side: BorderSide(color: context.theme.highlightColor, width: 1)), 
                      elevation: 0.0,
                    ),
                    SizedBox(width: 8),
                    Chip(
                      label: Text(diseaseDetails["category"]),
                      backgroundColor: context.theme.highlightColor,
                      shape: StadiumBorder(side: BorderSide(color: context.theme.highlightColor, width: 1)),
                      elevation: 0.0, 
                    ),
                    SizedBox(width: 8),
                    Chip(
                      label: Text(diseaseDetails["scientificName"]),
                      backgroundColor: Colors.green[200],
                      shape: StadiumBorder(side: BorderSide(color: context.theme.highlightColor, width: 1)),
                      elevation: 0.0, 
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
             
              if (diseaseDetails['images'] != null && (diseaseDetails['images'] as List).isNotEmpty)
               _buildImageGallery(diseaseDetails['images']),
               
              _buildInfoCard(
                title: 'Symptoms',
                content: diseaseDetails['symptoms'] ?? "No symptoms information available",
                icon: Icons.medical_information_outlined,
              ),
              _buildInfoCard(
                title: 'What caused it?',
                content: diseaseDetails['causes'] ?? "No causes information available",
                icon: Icons.bug_report_outlined,
              ),
               Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.theme.focusColor,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recommendations",
                      style:  TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.theme.primaryColorDark,
                      ),
                    ),
                    _buildRecomCard(
                      title: 'Organic Control',
                      content: diseaseDetails['organicControl'] ?? "No chemical control information available",
                      icon: Icons.science_outlined,
                    ),
                    _buildRecomCard(
                      title: 'Chemical Control',
                      content: diseaseDetails['chemicalControl'] ?? "No chemical control information available",
                      icon: Icons.science_outlined,
                    ),
                    if (diseaseDetails['fertilizers'] != null && (diseaseDetails['fertilizers'] as List).isNotEmpty)
                      _buildFertilizersSection(diseaseDetails['fertilizers'])
                  ],
                ),
              ),
              _buildInfoCard(
                title: 'Preventive Measures',
                content: '',
                icon: Icons.healing_outlined,
                bulletPoints: List<String>.from(diseaseDetails['remedies'] ?? []),
              ),
              _buildInfoCard(
                title: 'Summary',
                content: '',
                icon: Icons.healing_outlined,
                bulletPoints: List<String>.from(diseaseDetails['summary'] ?? []),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    IconData? icon,
    List<String>? bulletPoints,
    List<String>? images,
  }) {
    return Container(
      color: context.theme.canvasColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: (){
                    if(bulletPoints == null) {
                      _speak(content);
                    } else {
                      _speak(bulletPoints.join('\n'));
                    }
                  },
                  child: voiceIcon(context),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Text(
                    title,
                    style:  TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.theme.primaryColorDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (bulletPoints != null)
              ...bulletPoints.map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(title=='Preventive Measures')
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: context.theme.focusColor,
                            child: Icon(
                              FeatherIcons.check,
                              size: 12,
                              color: context.theme.primaryColorDark,
                            ),
                        )
                        else
                        Text('•',style: TextStyle(color: context.theme.primaryColorDark,fontSize: 16,fontWeight: FontWeight.bold),),
                        SizedBox(width: 10,),        
                        Expanded(
                          child:  Padding(
                          padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              point,
                              style: const TextStyle(fontSize: 13, height: 1.4),
                            ),
                          ),
                        )                   
                      ],
                    ),
                  ))
            else
              Text(
                content,
                style: const TextStyle(fontSize: 12, height: 1.4),
              ),
          ],
        ),
      ),
    );
  }

   Widget _buildRecomCard({
    required String title,
    required String content,
    IconData? icon,
    List<String>? bulletPoints,
    List<String>? images,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.plantWilt,
                  size: 12,
                  color: context.theme.primaryColorDark,
                ),
                SizedBox(width: 5,),
                Expanded(
                  child: Text(
                    title,
                    style:  TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.theme.primaryColorDark,
                    ),
                  ),
                ),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: (){
                    _speak(content);
                  },
                  child: voiceIcon(context),
                ),
                
              ],
            ),
            const SizedBox(height: 12),
              Text(
                content,
                style: const TextStyle(fontSize: 11, height: 1.4),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFertilizersSection(List<Map<String, dynamic>> fertilisers) {
    return   Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
             Icon(
                FontAwesomeIcons.plantWilt,
                size: 12,
                color: context.theme.primaryColorDark,
              ),
              SizedBox(width: 5,),
              Expanded(
                child: Text(
                  "Pesticides",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.theme.primaryColorDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20,),
          ...List.generate((diseaseDetails['fertilizers'] as List).length, (index) {
            final fertilizer = diseaseDetails['fertilizers'][index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        fertilizer['name'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    GestureDetector(
                  onTap: (){
                    _speak(fertilizer['name']);
                  },
                  child: voiceIcon(context),
                ),
                  ],
                ),
                SizedBox(height: 4),
                ...List.generate((fertilizer['products'] as List).length, (productIndex) {
                  final product = fertilizer['products'][productIndex];
                  return Column(
                    children: [
                      Card(
                        color: context.theme.highlightColor,
                        elevation: 0,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                          leading: Image.network(
                            product['productImage'],
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                          title: Text(product['companyName']),
                          subtitle: Text(product['price']),
                        ),
                      ),
                     
                    ],
                  );
                }),
                 if (index != (diseaseDetails['fertilizers'] as List).length - 1)
                  SizedBox(height: 16),
              ],
            );
          }),
          
        ],
      ),
    );

  }


}
