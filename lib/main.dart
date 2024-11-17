import 'package:aigro/pages/user_onbaording.dart';
import 'package:aigro/utils/authenticate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aigro/pages/about_us.dart';
import 'package:aigro/pages/get_started.dart';
import 'package:aigro/pages/home.dart';
import 'package:aigro/pages/profile.dart';
import 'package:aigro/pages/recipe_details.dart';
import 'package:aigro/pages/recipes.dart';
import 'package:aigro/utils/routes.dart';
import 'package:aigro/utils/themes.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox("Start_db");
  await Hive.openBox("BasicInfo-db");

  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    
    MyApp(),
    
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
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
      
      //themeMode: ThemeMode.system,                      

      debugShowCheckedModeBanner: false,              

      initialRoute: "/",                             
      
      routes: {                                       
       "/": (context) => Authenticate(),                  
        Myroutes.getStartedRoute: (context) => GetStarted(),
         Myroutes.onbaordingRoute: (context) => UserOnboarding(),
        Myroutes.homeRoute: (context) => HomePage(),
        Myroutes.aboutUsRoute: (context) => AboutUs(),
        Myroutes.recipesRoute: (context) => RecipesPage(),
        Myroutes.profileRoute: (context) => ProfilePage(),
        Myroutes.recipeDetailsRoute: (context) => RecipeDetails()
      },
    );   
  }
  );
}

