import 'package:aigro/local_db/db.dart';
import 'package:aigro/secret.dart';
import 'package:aigro/utils/translate.dart';
import 'package:flutter/material.dart';
import 'package:aigro/utils/bottom_pages_list.dart';
import 'package:aigro/widgets/bottom_nav.dart';
import 'package:hive/hive.dart';
import 'package:velocity_x/velocity_x.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {

  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();
  String userLang="hello";

  String aboutUsTitle = '🌱 About Us';
  String motiveTitle = "What's Our Motive";
  String motiveContent =
    "Our motive is to empower farmers by providing them with the necessary tools and resources to succeed in their agricultural endeavors.";
  String futurePlanningTitle = 'Our Future Planning';
  String futurePlanningContent =
    "We are planning to expand our services to more regions, ensuring that every farmer has access to the support they need.";
  String provideTitle = 'What We Provide';
  String provideContent =
    "We provide a wide range of agricultural products and services, tailored to meet the unique needs of each farmer.";

  void translateAllTexts() async {
  String targetLanguage = userLang;
  String apiKey = GCP_API_KEY;

  
  if (targetLanguage == "en") {
    return; 
  }

  try {
    String aboutUsTitleResult = await translateText(aboutUsTitle, targetLanguage, apiKey);
    setState(() {
      aboutUsTitle = aboutUsTitleResult;
    });
  } catch (e) {
    print("Error: $e");
  }

  try {
    String motiveTitleResult = await translateText(motiveTitle, targetLanguage, apiKey);
    setState(() {
      motiveTitle = motiveTitleResult;
    });

    String motiveContentResult = await translateText(motiveContent, targetLanguage, apiKey);
    setState(() {
      motiveContent = motiveContentResult;
    });
  } catch (e) {
    print("Error: $e");
  }

  try {
    String futurePlanningTitleResult = await translateText(futurePlanningTitle, targetLanguage, apiKey);
    setState(() {
      futurePlanningTitle = futurePlanningTitleResult;
    });

    String futurePlanningContentResult = await translateText(futurePlanningContent, targetLanguage, apiKey);
    setState(() {
      futurePlanningContent = futurePlanningContentResult;
    });
  } catch (e) {
    print("Error: $e");
  }

  try {
    String provideTitleResult = await translateText(provideTitle, targetLanguage, apiKey);
    setState(() {
      provideTitle = provideTitleResult;
    });

    String provideContentResult = await translateText(provideContent, targetLanguage, apiKey);
    setState(() {
      provideContent = provideContentResult;
    });
  } catch (e) {
    print("Error: $e");
  }
}


  @override
  void initState() {

    if(languageBox.get("LANG") == null){
      ldb.createLang();
      userLang = ldb.language;
    }
    else{
      ldb.loadLang();
      userLang = ldb.language;
    }

    super.initState();
    translateAllTexts();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                aboutUsTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004D3F),
                ),
              ),
              const SizedBox(height: 24),


              Expanded(
                child: ListView(
                  children: [
                    _buildInfoCard(title: motiveTitle, content: motiveContent),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                        title: futurePlanningTitle, content: futurePlanningContent),
                    const SizedBox(height: 16),
                    _buildInfoCard(title: provideTitle, content: provideContent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        pages: pages,
        selectedInd: 3,
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.primaryColorDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
