import 'package:aigro/local_db/db.dart';
import 'package:aigro/pages/course_player.dart';
import 'package:aigro/secret.dart';
import 'package:aigro/utils/translate.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:velocity_x/velocity_x.dart';

class LearningResources extends StatefulWidget {
  const LearningResources({super.key});

  @override
  _LearningResourcesState createState() => _LearningResourcesState();
}

class _LearningResourcesState extends State<LearningResources> {

  String hint='Search for courses';

  Map<String, Map<String, dynamic>> courseMap = {
    '1': {
      'title': 'Soil Health & Preparation',
      'domain': 'Basics',
      'image': 'https://online.maryville.edu/wp-content/uploads/sites/97/2021/02/hands-in-soil.jpg?w=750',
      'items': [
        "Understanding Soil Types",
        "Soil Testing Techniques",
        "Improving Soil Fertility",
      ],
    },
    '2': {
      'title': 'Water Management Techniques',
      'domain': 'Basics',
      'image': 'https://enterclimate.com/blog/wp-content/uploads/2023/01/Water-Management-Techniques-for-Businesses.png',
      'items': [
        "Irrigation Methods",
        "Water Conservation Practices",
        "Drip Irrigation Basics",
      ],
    },
    '3': {
      'title': 'Crop-Specific Courses',
      'domain': 'Basics',
      'image': 'https://elearning.fao.org/pluginfile.php/506754/course/overviewfiles/Climate-smart-crop-production.jpg',
      'items': [
        "Rice Farming Techniques",
        "Corn Cultivation Methods",
        "Tomato Farming Best Practices",
        "Banana Plantations 101",
        "Mango Cultivation and Care",
        "Tea Plantation Basics",
      ],
    },
    '4': {
      'title': 'Sustainable & Organic Farming',
      'domain': 'Organic',
      'image': 'https://www.aromaticandallied.com/uploads/blog/202404/img_660be77949ffa7-73444220-84857755.jpg',
      'items': [
        "Basics of Organic Farming",
        "Composting Techniques",
        "Using Natural Fertilizers",
      ],
    },
    '5': {
      'title': 'Livestock Management',
      'domain': 'Husbandry',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTFEd8rHHJuVyGym9QqmEmu21u90LlSJGxCA&s',
      'items': [
        "Introduction to Livestock Farming",
        "Cattle Management",
        "Poultry Farming Basics",
      ],
    },
  };

  List<String> categories = [
    'Basics',
    'Organic',
    'Agroforestry',
    'Mixed Farming',
    'Hydroponics',
    'Husbandry',
  ];
    

  List<String> selectedCategories = [];
  String query = '';

  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();
  String userLang = "hello";


  void translateAllTexts() async {
    String targetLanguage = userLang;
    String apiKey = GCP_API_KEY;

    if (targetLanguage == "en") {
      return;
    }

    try {
      String welcomeTextresult = await translateText(hint, targetLanguage, apiKey);

      List<String> translatedCategories = await Future.wait(
      categories.map((category) {
        return translateText(category, targetLanguage, apiKey);
      }).toList()
    );

      List<MapEntry<String, Map<String, dynamic>>> translatedCourses = [];
      for (var entry in courseMap.entries) {
        String key = entry.key;
        var value = entry.value;
        String translatedTitle = await translateText(value['title'], targetLanguage, apiKey);
        String translatedDomain = await translateText(value['domain'], targetLanguage, apiKey);
        List<String> translatedItems = await Future.wait(
          (value['items'] as List<String>).map((item) {
            return translateText(item, targetLanguage, apiKey);
          }).toList()
        );
        translatedCourses.add(MapEntry(key, {
          "title": translatedTitle,
          "domain": translatedDomain,
          "items": translatedItems,
          "image": value['image'],
        }));
      }

      setState(() {
        hint=welcomeTextresult;
        categories = translatedCategories;
        courseMap = Map.fromEntries(translatedCourses);
      });
    } catch (e) {
      print("Error translating course data: $e");
    }
  }


  @override
  void initState() {
    if (languageBox.get("LANG") == null) {
      ldb.createLang();
      userLang = ldb.language;
    } else {
      ldb.loadLang();
      userLang = ldb.language;
    }
    super.initState();
    translateAllTexts();
  }


  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredCourses = courseMap.values.where((course) {
      final matchesCategory = selectedCategories.isEmpty ||
          selectedCategories.contains(course['domain']);
      final matchesQuery =
          course['title'].toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

  return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        title: const Text(
          'Courses',
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.theme.highlightColor,
                        boxShadow: [
                          BoxShadow(
                            color: context.theme.cardColor,                
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 0),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: TextField(
                        cursorColor: context.theme.cardColor,
                        style:
                            TextStyle(color: context.theme.splashColor),
                        onChanged: (newQuery) {
                          setState(() {
                            query = newQuery;
                          });
                        },
                        decoration: InputDecoration(
                          hintStyle: TextStyle(
                            color: context.theme.primaryColorDark,
                          ),
                          hintText: hint,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(top: 12),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Icon(
                              Icons.search,
                              size: 22,
                              color: context.theme.cardColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    String cat = categories.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.all(6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: FilterChip(
                          selected: selectedCategories.contains(cat),
                          label: Text(
                            cat,
                            style: TextStyle(
                              color: context.theme.splashColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          backgroundColor:
                              context.theme.highlightColor,
                          selectedColor: context.theme.focusColor,
                          side: BorderSide.none,
                          showCheckmark: false,
                          onSelected: (selected) {
                            setState(() {
                              selected
                                  ? selectedCategories.add(cat)
                                  : selectedCategories.remove(cat);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    String id = courseMap.keys.firstWhere(
                      (key) => courseMap[key] == filteredCourses[index],
                    );
                    return courseCard(id, context, filteredCourses[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      
    );
  }

  Widget courseCard(
    String id, BuildContext context, Map<String, dynamic> courseData) {
    return GestureDetector(
      onTap: () async {
       Navigator.push
       (context,MaterialPageRoute(builder: (context) => CoursesPlayer(coursetitle:courseData['title'],)),);
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.theme.highlightColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.theme.canvasColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 57, 59, 57).withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    courseData['image'] ?? 
                    "https://online.maryville.edu/wp-content/uploads/sites/97/2021/02/hands-in-soil.jpg?w=750",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
           
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                courseData['title'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  color: context.theme.primaryColorDark,
                  fontFamily: "Raleway",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                courseData['domain'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: context.theme.primaryColorDark,
                  fontFamily: "Raleway",
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const SizedBox(height: 10),
           
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  courseData['items']?.length ?? 0,
                  (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        "* ${courseData['items'][index]} ",
                        style: TextStyle(
                          fontSize: 12,
                          color: context.theme.primaryColorDark,
                          fontFamily: "Raleway",
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),

          ],
        ),
      ),
    );
  }

}

