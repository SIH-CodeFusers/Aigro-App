import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:aigro/local_db/db.dart';
import 'package:aigro/utils/routes.dart';
import 'package:aigro/widgets/next_buttons.dart';
import 'package:aigro/widgets/progress_indicator.dart';
import 'package:velocity_x/velocity_x.dart';
import 'dart:async';

class UserOnboarding extends StatefulWidget {
  const UserOnboarding({super.key});

  @override
  State<UserOnboarding> createState() => _UserOnboardingState();
}

class _UserOnboardingState extends State<UserOnboarding> {

  int questionInd = 0;
  int totalQuestions = 2;

  bool olduser = false;
  late StreamSubscription<bool> keyboardSubscription;
  // final List<String> items =
  //     List<String>.generate(100, (index) => "${index + 1}");
  // late FixedExtentScrollController _scrollController;
  final _phonecontroller = TextEditingController();
  final _namecontroller = TextEditingController();



  final startbox = Hive.box("Start_db");
  StartPointer db = StartPointer();

  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();


  @override
  void initState() {
    super.initState();
    // _scrollController = FixedExtentScrollController(initialItem: 17);
  }

  _saveForm() {
    setState(() {
      db.startHome = true;
      bdb.userName = _namecontroller.text;
      bdb.userPhn = _phonecontroller.text;

    });
    db.updateTheme();
    bdb.updateDbInfo();
    Navigator.pushNamed(context, Myroutes.homeRoute);
  }

  void _handleBackButtonPressed() {
    if (questionInd != 0) {
      setState(() {
        questionInd = questionInd - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      body: SafeArea(
        child: Container(
          child: Builder(
            builder: (BuildContext context) {
              if (questionInd == 0) {
                return NameSelect(context);
              } else if (questionInd == 1) {
                return PhoneSelect(context);
              }  else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  //User Name
  Widget NameSelect(BuildContext context) {
    return Column(
      children: [
        ProgressIndicatorWidget(
          questionInd: questionInd,
          totalQuestions: totalQuestions,
          onBackButtonPressed: _handleBackButtonPressed,
        ),
        Spacer(), 
       Center(
        child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: context.theme.highlightColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), 
                blurRadius: 10, 
                offset: Offset(0, 0), 
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What is your name?",
                    style: TextStyle(color: context.theme.primaryColorDark, fontSize: 24),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _namecontroller,
                style: TextStyle(color: context.theme.primaryColorDark),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(color: context.theme.primaryColorDark),
                  filled: true,
                  fillColor: context.theme.highlightColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: context.theme.primaryColorDark, 
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: context.theme.primaryColorDark,
                      width: 2.0,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded( 
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          questionInd += 1;
                        });
                      },
                      child: NextButton(
                        text: "Next",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
        Spacer(),
      ],
    );
  }



  //Phone Number
  Column PhoneSelect(BuildContext context) {
    return Column(
      children: [
        ProgressIndicatorWidget(
          questionInd: questionInd,
          totalQuestions: totalQuestions,
          onBackButtonPressed: _handleBackButtonPressed,
        ),
        Spacer(), 
       Center(
        child: Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: context.theme.highlightColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), 
                blurRadius: 10, 
                offset: Offset(0, 0), 
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "What is your contact number?",
                    style: TextStyle(color: context.theme.primaryColorDark, fontSize: 24),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _phonecontroller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: context.theme.primaryColorDark),
                decoration: InputDecoration(
                  hintText: 'Enter your number',
                  hintStyle: TextStyle(color: context.theme.primaryColorDark),
                  filled: true,
                  fillColor: context.theme.highlightColor,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: context.theme.primaryColorDark, 
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: context.theme.primaryColorDark,
                      width: 2.0,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded( 
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _saveForm();
                        });
                      },
                      child: NextButton(
                        text: "Next",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
        Spacer(),
      ],
    );
  }
}