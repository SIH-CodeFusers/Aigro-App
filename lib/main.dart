import 'package:aigro/pages/community.dart';
import 'package:aigro/pages/disease_forecasting.dart';
import 'package:aigro/pages/disease_mapping.dart';
import 'package:aigro/pages/gov_schemes.dart';
import 'package:aigro/pages/image_analysis.dart';
import 'package:aigro/pages/khetisathi.dart';
import 'package:aigro/pages/learning_resources.dart';
import 'package:aigro/pages/new_analysis_nav.dart';
import 'package:aigro/pages/offline_detection.dart';
import 'package:aigro/pages/upload_image.dart';
import 'package:aigro/pages/user_onbaording.dart';
import 'package:aigro/pages/weather_report.dart';
import 'package:aigro/utils/authenticate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aigro/pages/about_us.dart';
import 'package:aigro/pages/get_started.dart';
import 'package:aigro/pages/home.dart';
import 'package:aigro/pages/profile.dart';
import 'package:aigro/pages/crop_list.dart';
import 'package:aigro/utils/routes.dart';
import 'package:aigro/utils/themes.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("Start_db");
  await Hive.openBox("BasicInfo-db");
  await Hive.openBox("Language_db");
  await Firebase.initializeApp(
   
);
  runApp(
    const MyApp(), 
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromRGBO(244, 244, 244, 1),
      statusBarColor: Color.fromRGBO(244, 244, 244, 1),
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        builder: (context, _) {
          final themeProvider = Provider.of<ThemeProvider>(context);

    
    return MaterialApp(
      
      themeMode: themeProvider.themeMode,
      theme: MyThemes.lightTheme,
      debugShowCheckedModeBanner: false,              
      initialRoute: "/",   
      builder: (context, child) {
              return MediaQuery(
                child: child!,
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0, // Disable text scaling globally
                ),
              );
            },                          
      
      routes: {                                       
       "/": (context) => const Authenticate(),                  
        Myroutes.getStartedRoute: (context) => const GetStarted(),
        Myroutes.onbaordingRoute: (context) => const UserOnboarding(),
        Myroutes.homeRoute: (context) => const HomePage(),
        Myroutes.aboutUsRoute: (context) => const AboutUs(),
        Myroutes.cropListRoute: (context) => const CropListPage(),
        Myroutes.profileRoute: (context) => const ProfilePage(),
        Myroutes.newAnalysisRoute: (context) => const NewAnalysisNav(),
        Myroutes.khetiSathiRoute: (context) => const KhetiSathi(),
        // Myroutes.cropDetailsRoute: (context) => CropDetails(),

        Myroutes.diseaseMapRoute: (context) => const DiseaseMapping(),
        Myroutes.offlineDetectionRoute: (context) => OfflineDetection(),
        Myroutes.weatherReportRoute: (context) => const WeatherReport(),
        Myroutes.diseaseForecastRoute: (context) => const DiseaseForecasting(),
        Myroutes.imageAnalysisRoute: (context) => ImageAnalysis(),
        Myroutes.uploadImageRoute: (context) => UploadImage(),
        Myroutes.learningResourcesRoute: (context) => LearningResources(),
        Myroutes.communityRoute: (context) => const Community(),
        Myroutes.schemesRoute: (context) => GovernmentSchemes(),
      },
    );   
  }
  );
}

