// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}


class MyThemes {
  static final lightTheme = ThemeData(
      primarySwatch:Colors.green, // changes all colours with respect to given colour
      canvasColor: Color.fromRGBO(244, 244, 244, 1),
      highlightColor: Colors.white, //secondary background colour
      primaryColorDark: const Color(0xFF004D3F),
      hintColor: Color.fromRGBO(239, 183, 2, 1),
      cardColor: Color.fromRGBO(0, 229, 118, 1),
      focusColor: Color.fromRGBO(185, 246, 202, 1),
      splashColor: Color.fromARGB(255, 134, 132, 132),
      
      appBarTheme: AppBarTheme(
        color: Color.fromRGBO(244, 244, 244, 1),
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.green, size: 28),
      ),
      // pageTransitionsTheme: PageTransitionsTheme(
      //     builders: {
      //       TargetPlatform.android: ZoomPageTransitionsBuilder(),
      //       TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      //     },
      //   ),
    );

}