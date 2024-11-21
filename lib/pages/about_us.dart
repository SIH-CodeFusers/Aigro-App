import 'dart:async';

import 'package:aigro/local_db/db.dart';
import 'package:aigro/secret.dart';
import 'package:aigro/utils/translate.dart';
import 'package:flutter/material.dart';
import 'package:aigro/utils/bottom_pages_list.dart';
import 'package:aigro/widgets/bottom_nav.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {

  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();
  String userLang = "hello";

  String aboutUsTitle = '🌱 About Us';
  String ourTeamTitle = 'Meet Our Team 🌱';
  String fnqTitle = 'Frequently Asked Questions';
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
      String aboutUsTitleResult =
          await translateText(aboutUsTitle, targetLanguage, apiKey);
      setState(() {
        aboutUsTitle = aboutUsTitleResult;
      });
    } catch (e) {
      print("Error: $e");
    }

    try {
      String ourTeamTitleResult =
          await translateText(ourTeamTitle, targetLanguage, apiKey);
      setState(() {
        ourTeamTitle = ourTeamTitleResult;
      });
    } catch (e) {
      print("Error: $e");
    }
    try {
      String fnqTitleResult =
          await translateText(fnqTitle, targetLanguage, apiKey);
      setState(() {
        fnqTitle = fnqTitleResult;
      });
    } catch (e) {
      print("Error: $e");
    }

    try {
      List<Map<String, String>> translatedTeamMembers = [];
      for (var item in teamMembers) {
        String translatedRole = await translateText(item["role"] ?? "", targetLanguage, apiKey);        
         translatedTeamMembers.add({
          "name": item["name"] ?? "", 
          "role": translatedRole,
          "image": item["image"] ?? "", 
          "web": item["web"] ?? "",
        });
      }
      setState(() {
        teamMembers = translatedTeamMembers;
      });
    } catch (e) {
      print("Error translating team members: $e");
    }

    try {
      String motiveTitleResult =
          await translateText(motiveTitle, targetLanguage, apiKey);
      setState(() {
        motiveTitle = motiveTitleResult;
      });

      String motiveContentResult =
          await translateText(motiveContent, targetLanguage, apiKey);
      setState(() {
        motiveContent = motiveContentResult;
      });
    } catch (e) {
      print("Error: $e");
    }

    try {
      String futurePlanningTitleResult =
          await translateText(futurePlanningTitle, targetLanguage, apiKey);
      setState(() {
        futurePlanningTitle = futurePlanningTitleResult;
      });

      String futurePlanningContentResult =
          await translateText(futurePlanningContent, targetLanguage, apiKey);
      setState(() {
        futurePlanningContent = futurePlanningContentResult;
      });
    } catch (e) {
      print("Error: $e");
    }

    try {
      String provideTitleResult =
          await translateText(provideTitle, targetLanguage, apiKey);
      setState(() {
        provideTitle = provideTitleResult;
      });

      String provideContentResult =
          await translateText(provideContent, targetLanguage, apiKey);
      setState(() {
        provideContent = provideContentResult;
      });
    } catch (e) {
      print("Error: $e");
    }

    try {
      List<Map<String, String>> translatedTeamMembers = [];
      for (var item in teamMembers) {
        String translatedRole = await translateText(item["role"] ?? "", targetLanguage, apiKey);        
         translatedTeamMembers.add({
          "name": item["name"] ?? "", 
          "role": translatedRole,
          "image": item["image"] ?? "", 
          "web": item["web"] ?? "",
        });
      }
      setState(() {
        teamMembers = translatedTeamMembers;
      });
    } catch (e) {
      print("Error translating team members: $e");
    }


    try {
      List<Map<String, String>> translatedAccordionData = [];
      for (var item in accordionData) {
        String translatedTitle =
            await translateText(item["title"]!, targetLanguage, apiKey);
        String translatedContent =
            await translateText(item["content"]!, targetLanguage, apiKey);
        translatedAccordionData.add({
          "title": translatedTitle,
          "content": translatedContent,
        });
      }
      setState(() {
        accordionData = translatedAccordionData;
      });
    } catch (e) {
      print("Error translating accordion: $e");
    }




  }

  
  List<Map<String, String>> accordionData = [
    {
      "title": "What is Aigro",
      "content":
          "AIgro, developed by the CodeFusers Team, is a website designed to assist farmers with various features such as disease prediction, image analysis, a farmers' community, crop health monitoring, an AI chat assistant, weather updates, cultivation tips, and farm resources."
    },
    {
      "title": "How do the Dieases Prediction Work?",
      "content":
          "The disease prediction feature uses AI algorithms to analyze data and predict potential crop diseases based on historical and real-time information. This helps farmers take preventive measures early."
    },
    {
      "title": "What does the Image Analysis Tool Do?",
      "content":
          "You can reach us via email, phone, or through our in-app support system.The image analysis tool allows farmers to upload images of their crops or plants. The AI then analyzes these images to detect signs of diseases, pests, or nutritional deficiencies, providing actionable insights."
    },
    {
      "title": "How can i connect with other Farmers in Aigro",
      "content":
          "AIgro offers a farmers' community feature where users can join discussions, share experiences, and seek advice from other farmers. This platform fosters collaboration and knowledge sharing."
    },{
      "title": "What kind of Suppourt can I get from AI Chat Assistant",
      "content":
          "The AI chat assistant provides real-time support by answering farming-related questions, offering advice on crop management, and guiding users through the website's features. It aims to assist users with their queries efficiently."
    },{
      "title": "Who do I get Wheather Updates & Cultivtation Tips?",
      "content":
          "AIgro provides personalized weather updates and cultivation tips based on your location and crop type. Users can access these insights through the website's dedicated sections for weather forecasts and farming advice."
    },
  ];

  
  final PageController _controller = PageController(viewportFraction: 1.0);
  int _currentIndex = 0;
  Timer? _timer;

  List<Map<String, String>> teamMembers = [
    {
      "name": "Arunava Dutta", 
      "role": "Frontend Developer", 
      "image": "assets/images/arunava.jpeg",
      "web": "https://meard.vercel.app/",
    },
    {
      "name": "Pretisha Sahoo", 
      "role": "Frontend Developer", 
      "image": "assets/images/pretisha.jpeg",
      "web": "https://pretisha-sahoo.vercel.app/",
    },
    {
      "name": "Satyaki Dey", 
      "role": "Full Stack Developer", 
      "image": "assets/images/satyaki.jpeg",
      "web": "https://satyaki-dey.vercel.app/",
    },
    {
      "name": "Priyanshu Dutta", 
      "role": "App Developer", 
      "image": "assets/images/priyanshu.jpeg",
      "web": "https://priyanshudutta.vercel.app/",
    },
    {
      "name": "Rishi Bhattasali", 
      "role": "ML Engineer", 
      "image": "assets/images/rishi.jpeg",
      "web": "https://rishibhattasali.vercel.app/",
    },
    {
      "name": "Shinjan Saha", 
      "role": "App Developer", 
      "image": "assets/images/shinjan.jpeg",
      "web": "https://shinjansaha02.me/",
    },
  ];

  void _launchURL(String s) async {
    final Uri url = Uri.parse(s);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
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

    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentIndex < 2) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _controller.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
    translateAllTexts();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
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
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        ourTeamTitle,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004D3F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTeamWidget(),
                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        fnqTitle,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004D3F),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildAccordionWidget(),
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

  Widget _buildTeamWidget() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _controller,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContainer(index * 2),
              _buildContainer(index * 2 + 1),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContainer(int index) {
    final member = teamMembers[index];

    return Flexible(
      child: GestureDetector(
        onTap: (){
          _launchURL(member['web']!);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8)
          ),
          margin: EdgeInsets.symmetric(horizontal: 4),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),  
                      BlendMode.darken,
                    ),
                    child: Image.asset(
                      member['image']!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: 
                  Container(
                    margin: EdgeInsets.all(5),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.8),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          member["name"]!,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          member["role"]!,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                
              ),
            ],
          ),
        ),
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

Widget _buildAccordionWidget() {
  return Column(
    children: accordionData.map((item) {
      return ExpansionTile(
        title: Text(
          item["title"]!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        iconColor: Color.fromRGBO(0, 229, 118, 1), 
        collapsedBackgroundColor: Colors.grey.shade200, 
        backgroundColor: Colors.green.shade100, 
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              item["content"]!,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      );
    }).toList(),
  );
}

}
