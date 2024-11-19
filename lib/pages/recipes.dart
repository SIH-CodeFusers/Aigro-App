import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:aigro/widgets/bottom_nav.dart';
import 'package:aigro/utils/bottom_pages_list.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  late Future<List<Map<String, String>>> cropDiseases;

  String selectedCrop = "Crops";
  String selectedCategory = "Category";

  final List<String> cropOptions = ["Crops", "Corn", "Tomato", "Wheat"];
  final List<String> categoryOptions = ["Category", "Fungus", "Virus", "Bacteria"];

  Future<List<Map<String, String>>> loadCropDiseases() async {
  final String data = await DefaultAssetBundle.of(context)
      .loadString('assets/others/crop_disease_18nov.json');
  final Map<String, dynamic> jsonResult = json.decode(data);

  return (jsonResult['cropDiseases'] as List)
      .expand((crop) => (crop['diseaseDetails'] as List)
          .map((disease) => {
                "diseaseName": disease['diseaseName'] as String,
                "category": disease['category'] as String,
                "image": (disease['images'] as List).isNotEmpty
                    ? disease['images'][0] as String
                    : '',
              }))
      .toList();
}


  @override
  void initState() {
    super.initState();
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
                child: FutureBuilder<List<Map<String, String>>>(
                  future: cropDiseases,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text("Error loading data."));
                    }

                    final diseases = snapshot.data!
                        .where((disease) =>
                            (selectedCrop == "Crops" ||
                                disease['diseaseName']!
                                    .toLowerCase()
                                    .contains(selectedCrop.toLowerCase())) &&
                            (selectedCategory == "Category" ||
                                disease['category']!
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
                            Navigator.pushNamed(context, '/recipeDetails');
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
                                    disease['image']!,
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
                                        "Disease Name: ${disease["diseaseName"]}",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF004D3F),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Category: ${disease["category"]}",
                                        style: TextStyle(
                                          fontSize: 14,
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
