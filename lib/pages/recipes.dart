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
 
  final List<Map<String, String>> cropDiseases = [
    {
      "diseaseName": "Corn Leaf Blight",
      "category": "Fungus",
      "image": "assets/images/corn-blight-3.jpg",
    },
    {
      "diseaseName": "Common Rust",
      "category": "Fungus",
      "image": "assets/images/corn-common-rust-1.jpg",
    },
    {
      "diseaseName": "Leaf Spot",
      "category": "Fungus",
      "image": "assets/images/corn-gray-leaf-spot-3.jpeg",
    },
    {
      "diseaseName": "Corn Rot",
      "category": "Fungus",
      "image": "assets/images/corn_rot_3.jpg",
    },
  ];

  
  String selectedCrop = "Crops";
  String selectedCategory = "Category";

  
  final List<String> cropOptions = ["Crops", "Corn", "Tomato", "Wheat"];
  final List<String> categoryOptions = ["Category", "Fungus", "Virus", "Bacteria"];

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
                    items: cropOptions.map<DropdownMenuItem<String>>((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
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
                    items: categoryOptions.map<DropdownMenuItem<String>>((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    borderRadius: BorderRadius.circular(8),
                    dropdownColor: context.theme.highlightColor,
                  ).expand(),
                ],
              ),
              const SizedBox(height: 20),

              
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: cropDiseases.length,
                  itemBuilder: (context, index) {
                    final disease = cropDiseases[index];

                    
                    if ((selectedCrop != "Crops" &&
                            !disease["diseaseName"]!.toLowerCase().contains(selectedCrop.toLowerCase())) ||
                        (selectedCategory != "Category" &&
                            disease["category"]!.toLowerCase() != selectedCategory.toLowerCase())) {
                      return const SizedBox.shrink();
                    }

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
                              child: Image.asset(
                                disease["image"]!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
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
                                      fontSize: 16,
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
