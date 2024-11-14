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
import 'package:provider/provider.dart';

void main() async{
  
  runApp( MyApp());
}


// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  //const MyApp({super.key});

  bool isSwitched;
  MyApp({Key? key, this.isSwitched=false}) : super(key: key);

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
      
      //themeMode: ThemeMode.system,                       // setting the theme

      debugShowCheckedModeBanner: false,              //removes debug banner

      initialRoute: "/",                              //this route will open first
      
      routes: {                                       //creating routes for different pages in app
        "/": (context) => GetStarted(),                //main root 
        Myroutes.getStartedRoute: (context) => GetStarted(),
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

