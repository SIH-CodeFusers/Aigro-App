import 'dart:convert';
import 'package:aigro/pages/crop_details.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:aigro/widgets/bottom_nav.dart';
import 'package:aigro/utils/bottom_pages_list.dart';
import 'package:aigro/secret.dart';
import 'package:aigro/utils/translate.dart';
import 'package:hive/hive.dart';
import 'package:aigro/local_db/db.dart';

class CropListPage extends StatefulWidget {
  const CropListPage({super.key});

  @override
  State<CropListPage> createState() => _CropListPageState();
}

class _CropListPageState extends State<CropListPage> {
  late Future<List<Map<String, dynamic>>> cropDiseases;
  String selectedCrop = "Crops";
  String selectedCategory = "Category";
  final List<String> cropOptions = [
    "Crops",
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
  final List<String> categoryOptions = ["Category", "Fungus", "Virus", "Bacteria"];

  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();
  String userLang = "en";

  Future<List<Map<String, dynamic>>> loadCropDiseases() async {
    final String data = await DefaultAssetBundle.of(context)
        .loadString('assets/others/crop_disease_18nov.json');
    final Map<String, dynamic> jsonResult = json.decode(data);
    final diseases = (jsonResult['cropDiseases'] as List)
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

    if (userLang != "en") {
      return await translateCropDiseases(diseases);
    }
    return diseases;
  }

  // Translation function
  Future<List<Map<String, dynamic>>> translateCropDiseases(
      List<Map<String, dynamic>> diseases) async {
    List<Map<String, dynamic>> translatedDiseases = [];
    String targetLanguage = userLang;
    String apiKey = GCP_API_KEY;

    try {
      for (var disease in diseases) {
        String translatedDiseaseName =
            await translateText(disease['diseaseName'], targetLanguage, apiKey);
        String translatedCategory =
            await translateText(disease['category'], targetLanguage, apiKey);

        translatedDiseases.add({
          ...disease,
          "diseaseName": translatedDiseaseName,
          "category": translatedCategory,
        });
      }
    } catch (e) {
      print("Error translating diseases: $e");
      return diseases; // Fallback to untranslated data
    }

    return translatedDiseases;
  }

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
    cropDiseases = loadCropDiseases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Crop Pests and Diseases 🌱",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF004D3F),
                ),
              ).centered(),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: selectedCrop,
                    onChanged: (value) {
                      setState(() {
                        selectedCrop = value!;
                      });
                    },
                    items: cropOptions
                        .map((option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option, style: const TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                    borderRadius: BorderRadius.circular(8),
                    dropdownColor: context.theme.highlightColor,
                  ).expand(),

                  const SizedBox(width: 10),

                  DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    items: categoryOptions
                        .map((option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option, style: const TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                    borderRadius: BorderRadius.circular(8),
                    dropdownColor: context.theme.highlightColor,
                  ).expand(),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: cropDiseases,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Color(0xFF004D3F),
                      ));
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text("Error loading data."));
                    }

                    final diseases = snapshot.data!
                        .where((disease) =>
                            (selectedCrop == "Crops" ||
                                disease['cropName']
                                    .toLowerCase()
                                    .contains(selectedCrop.toLowerCase())) &&
                            (selectedCategory == "Category" ||
                                disease['category']
                                    .toLowerCase()
                                    .contains(selectedCategory.toLowerCase())))
                        .toList();

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: diseases.length,
                      itemBuilder: (context, index) {
                        final disease = diseases[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CropDetails(disease: disease),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.theme.highlightColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  child: Image.network(
                                    disease['images'][0] as String,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image, size: 120);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${disease["diseaseName"]}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF004D3F),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Category: ${disease["category"]}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: context.theme.splashColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        pages: pages,
        selectedInd: 1,
      ),
    );
  }
}
