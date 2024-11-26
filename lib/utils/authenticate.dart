import 'package:aigro/local_db/db.dart';
import 'package:aigro/pages/get_started.dart';
import 'package:aigro/pages/home.dart';
import 'package:aigro/pages/select_lang.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';


class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  final startbox = Hive.box("Start_db");
  StartPointer db = StartPointer();

  bool onboarded=false;

  @override
  void initState() {
    if (startbox.get("START") == null) {
      db.createTheme();
      onboarded = db.startHome;
    }
    else{
      db.loadTheme();
      onboarded=db.startHome;
    }
    
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(onboarded==true){
      return  const HomePage();
    }
    else if(onboarded==false){
      return  const SelectLang();
    }
    return const Scaffold();
  }
}