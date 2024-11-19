import 'package:aigro/local_db/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aigro/utils/routes.dart';
import 'package:aigro/utils/bottom_pages_list.dart';
import 'package:aigro/widgets/bottom_nav.dart';
import 'package:aigro/widgets/sparkling_animation.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:hive/hive.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();
  String userName = "User";
  String userDist = "abc";
  String userState= "abc";

  String userimg = "";
  String first = "...";

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

    super.initState();
  }

  final List<Map<String, dynamic>> dashboardData = [
    {
      'color':  Color.fromRGBO(190, 200, 249,1),
      'text': 'Disease Forecasting',
      'image': 'assets/images/forecasting.png',
      'route': Myroutes.profileRoute,
    },
    {
      'color': Color.fromRGBO(232, 213, 207,1),
      'text': 'Offline Model',
      'image': 'assets/images/offline.png',
      'route': Myroutes.offlineDetectionRoute,
    },
    {
      'color': Color.fromRGBO(201, 223, 221,1),
      'text': 'Disease Mapping',
      'image': 'assets/images/mapping.png',
      'route': Myroutes.diseaseMapRoute,
    },
    {
      'color': Color.fromRGBO(230, 238, 155,1),
      'text': 'Weather Report',
      'image': 'assets/images/weather.png',
      'route': Myroutes.weatherReportRoute,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,   
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Container(
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
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.black, size: 16,),
                Text(
                  "$userDist, $userState",
                  style: TextStyle(color: Colors.black, fontSize: 16), 
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: context.theme.highlightColor,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(CupertinoIcons.bell, color: Colors.black, size: 22,),
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
                SizedBox(height: 5),
                Text("Hello, ${first} 🌱",style: TextStyle(fontSize: 26,color: context.theme.primaryColorDark),),
                SizedBox(height: 5),
                Text("Welcome to your dashboard. Scroll to see amazing features we provide.",style: TextStyle(fontSize: 14,color: Colors.grey[600]),),
                SizedBox(height: 15),
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
                                    "Detect and Treat Diseases with a Simple Image Upload",
                                    style: TextStyle(
                                      color: context.theme.highlightColor,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    // Navigator.pushNamed(context, '/findRecipe');
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.25, // 25% of screen width
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: context.theme.highlightColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Analyse Now",
                                        style: TextStyle(color: context.theme.cardColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          Image.asset(
                            width: MediaQuery.of(context).size.width * 0.3, // 30% of screen width
                            height: 175,
                            "assets/images/woman_farmer.png",
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
                  child: Text("Other Key Features of AIgro",style: TextStyle(fontSize: 16,color: Colors.grey[700]),),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),                  
                  child: GridView.builder(    
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: 1, 
                    ),
                    itemCount: 4, 
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
                                    style: TextStyle(color: Colors.white, fontSize: 18),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Spacer(),
                                Row(
                                  children: [
                                    Image.asset(
                                      width: 70, 
                                      height: 70,
                                     dashboardInfo['image'],
                                      fit: BoxFit.cover,
                                    ),
                                    Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(FeatherIcons.arrowUpRight, color: Colors.black, size: 22,),
                                      ), 
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
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
