import 'package:aigro/local_db/db.dart';
import 'package:aigro/pages/khetisathi.dart';
import 'package:aigro/pages/profile.dart';
import 'package:aigro/utils/translate.dart';
import 'package:aigro/widgets/voice_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aigro/utils/routes.dart';
import 'package:aigro/utils/bottom_pages_list.dart';
import 'package:aigro/widgets/bottom_nav.dart';
import 'package:aigro/widgets/sparkling_animation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:velocity_x/velocity_x.dart';

import '../secret.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();

  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();

  String userName = "User";
  String userDist = "abc";
  String userState= "abc";
  String userLang="hello";

  String userimg = "";
  String first = "...";

  String welcomeText="Welcome to your dashboard. Scroll to see amazing features we provide.";
  String detectAndTreat="Detect and Treat Diseases with a Simple Image Upload";
  String analyzeNow="Analyze Now";
  String otherFeatures="Other Key features of Kheti Sathi";



  void translateAllTexts() async {
    String targetLanguage = userLang;
    String apiKey = GCP_API_KEY; 

    if(targetLanguage=="en"){
      return;
    }

    try {
      String welcomeTextresult = await translateText(welcomeText, targetLanguage, apiKey);
      String detectAndTreatresult = await translateText(detectAndTreat, targetLanguage, apiKey);
      String analyzeNowresult = await translateText(analyzeNow, targetLanguage, apiKey);
      String otherFeaturesresult = await translateText(otherFeatures, targetLanguage, apiKey);

      List<Map<String, dynamic>> translatedDashboardData = [];
      for (var item in dashboardData) {
        String translatedText = await translateText(item['text'], targetLanguage, apiKey);
        translatedDashboardData.add({
          "color": item['color'],  
          "text": translatedText,  
          "image": item['image'],   
          "route": item['route'],   
        });
      }

      setState(() {
        welcomeText=welcomeTextresult;
        detectAndTreat=detectAndTreatresult;
        analyzeNow=analyzeNowresult;
        otherFeatures=otherFeaturesresult;
        dashboardData = translatedDashboardData;
      });
     
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {

    if (infobox.get("NAMEDB") == null) {
      bdb.createInitialInfo();
      userName = bdb.userName;
      userDist = bdb.userDistrict;
      userState = bdb.userState;
      List<String> words = userName.split(' '); // Splitting the string by space
      first = words[0];
    } else {
      bdb.loadDataInfo();
      userName = bdb.userName;
      userDist = bdb.userDistrict;
      userState = bdb.userState;
      List<String> words = userName.split(' '); // Splitting the string by space
      first = words[0];
    }

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

  List<Map<String, dynamic>> dashboardData = [
    {
      'color':  const Color.fromRGBO(190, 200, 249,1),
      'text': 'Disease Forecasting',
      'image': 'assets/images/forecasting.png',
      'route': Myroutes.diseaseForecastRoute,
      'voice':'In disease forecasting, you will get alerts about current diseases that are spreading your area.'
    },
    {
      'color': const Color.fromRGBO(232, 213, 207,1),
      'text': 'Offline Model',
      'image': 'assets/images/offline.png',
      'route': Myroutes.offlineDetectionRoute,
      'voice':'No Internet ? No worry. You can still use our offline model to detect diseases on the go.'
    },
    {
      'color': const Color.fromRGBO(201, 223, 221,1),
      'text': 'Disease Mapping',
      'image': 'assets/images/mapping.png',
      'route': Myroutes.diseaseMapRoute,
      'voice':'Disease mapping can be used to see in which farms near you diseases are spreading and you can also see pesticide shops near you.'
    },
    {
      'color': const Color.fromRGBO(230, 238, 155,1),
      'text': 'Weather Report',
      'image': 'assets/images/weather.png',
      'route': Myroutes.weatherReportRoute,
      'voice':'Get live updates about weather in your current locality and take actions accordingly.'
    },
    {
      'color': const Color.fromRGBO(249, 187, 208,1),
      'text': ' Krishi AI',
      'image': 'assets/images/ks.png',
      'route': Myroutes.khetiSathiRoute,
      'voice':'Krishi AI is our self developed chatbot which will help you to guide you in your farming related queries.'
    },
    {
      'color': const Color.fromRGBO(208, 196, 232,1),
      'text': 'Learning Resources',
      'image': 'assets/images/lr.png',
      'route': Myroutes.learningResourcesRoute,
      'voice':'Learn about various ways of farming techniques to maximize your crop yields and minimize losses.'
    },
    {
      'color': const Color.fromRGBO(255, 204, 128,1),
      'text': 'Farmers Community',
      'image': 'assets/images/cm.png',
      'route': Myroutes.communityRoute,
      'voice':'Stay in touch with your farmer friends using our community feature and prosper together.'
    },
    {
      'color': const Color.fromRGBO(255, 204, 187,1),
      'text': 'Government Schemes',
      'image': 'assets/images/gv.png',
      'route': Myroutes.schemesRoute,
      'voice':'Get live updates about different government schemes that are currently available and take the complete benefits.'
    },
  ];

  FlutterTts flutterTts = FlutterTts();

  _speak(String text) async {
    await flutterTts.setLanguage("en-US"); 
    await flutterTts.setPitch(0.7); 
    await flutterTts.speak(text); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,   
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context)=>const ProfilePage())
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: context.theme.highlightColor,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: context.theme.cardColor,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        width: 30,
                        height: 30,
                        "assets/images/boy.png",
                        fit: BoxFit.cover,
                      ),
                    )
                  ),
                ),
              ),
            ),
            Flexible(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.black, size: 14,),
                    Flexible(
                      child: Text(
                        "$userDist, $userState",
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        overflow: TextOverflow.ellipsis, 
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: context.theme.highlightColor,
                borderRadius: BorderRadius.circular(10)
              ),
              child: GestureDetector(
                onTap: (){
                 Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context)=>const KhetiSathi())
                );
                },
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(FontAwesomeIcons.comments, color: Colors.black, size: 20,),
                ),
              ), 
            ),
          ],
        ), 
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text("Hello, $first 🌱",style: TextStyle(fontSize: 24,color: context.theme.primaryColorDark),),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7, 
                      child: Text(welcomeText,style: TextStyle(fontSize: 12,color: Colors.grey[600]),)
                    ),
                    GestureDetector(
                      onTap: (){
                        _speak("Hi $first. $welcomeText");
                      },
                      child: voiceIcon(context),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  height: 175,
                  decoration: BoxDecoration(
                    color: context.theme.cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      SparklingAnimation(
                        child: Positioned(
                          right: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 175,
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: context.theme.focusColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.elliptical(50, 70),
                                bottomLeft: Radius.elliptical(50, 70),
                                bottomRight: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.45,
                                  child: Text(
                                    detectAndTreat,
                                    style: TextStyle(
                                      color: context.theme.highlightColor,
                                      fontSize: MediaQuery.of(context).size.width * 0.04,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, '/imageAnalysis');
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 0.25, 
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: context.theme.highlightColor,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Text(
                                            analyzeNow,
                                            style: TextStyle(color: context.theme.cardColor,fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    GestureDetector(
                                      onTap: (){
                                        _speak("Analyze any disease in your crops with our disease detection feature, which is fast and efficient.");
                                      },
                                      child: voiceIcon(context),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Image.asset(
                            width: MediaQuery.of(context).size.width * 0.3, // 30% of screen width
                            height: 175,
                            "assets/images/male_farmer.png",
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Flexible(child: Text(otherFeatures,style: TextStyle(fontSize: 14,color: Colors.grey[700]),)),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){
                          _speak("Hi, in Kheti Sathi we have lots of features. This includes, Disease Forecasting, Offline Analysis, Disease Mapping, Weather Forecast, Learning Resources, Community and more.");
                        },
                        child: voiceIcon(context),
                      )
                    ],
                  ),
                  
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),                  
                  child: GridView.builder(    
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1, 
                    ),
                    itemCount: dashboardData.length, 
                    itemBuilder: (context, index) {
                      final dashboardInfo = dashboardData[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, dashboardInfo['route']);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: dashboardInfo['color'], 
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                    child: Text(
                                      dashboardInfo['text'],
                                      style: TextStyle(color: context.theme.highlightColor, fontSize: 16),
                                      textAlign: TextAlign.left,
                                    ),
                                  
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Image.asset(
                                      width: 60, 
                                      height: 60,
                                     dashboardInfo['image'],
                                      fit: BoxFit.cover,
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: (){
                                        _speak(dashboardInfo['voice']);
                                      },
                                      child: voiceIcon(context),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        pages: pages,
        selectedInd: 0,
      ),
    );
  }


}
