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
      body: SafeArea(
        child: Container(
          // decoration: BoxDecoration(
          //   image: DecorationImage(
          //     image: AssetImage('assets/images/onboard-bg.png'),
          //     fit: BoxFit
          //         .cover, 
          //   ),
          // ),
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
  Column NameSelect(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ProgressIndicatorWidget(
        //   questionInd: questionInd,
        //   totalQuestions: totalQuestions,
        //   onBackButtonPressed: _handleBackButtonPressed,
        // ),
        Spacer(),
        Center(
          child: Text(
            "What is your name ?",
            style: TextStyle(color: context.theme.splashColor, fontSize: 26),
          ),
        ),
        SizedBox(height: 30),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [context.theme.cardColor, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: context.theme.highlightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: TextStyle(color: context.theme.splashColor),
                  controller: _namecontroller,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(color: context.theme.splashColor),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: _handleBackButtonPressed,
                child: NextButton(
                  text: "Back"
                ),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    questionInd = questionInd + 1;
                  });
                },
                child: NextButton(
                  text: "Next",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  //Phone Number
  Column PhoneSelect(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProgressIndicatorWidget(
          questionInd: questionInd,
          totalQuestions: totalQuestions,
          onBackButtonPressed: _handleBackButtonPressed,
        ),
        Spacer(),
        Center(
          child: Text(
            "What is your contact number ?",
            style: TextStyle(color: context.theme.splashColor, fontSize: 26),
          ),
        ),
        SizedBox(height: 30),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [context.theme.cardColor, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: context.theme.highlightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  style: TextStyle(color: context.theme.splashColor),
                  controller: _phonecontroller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: '+91 ',
                    hintText: 'Enter your number',
                    hintStyle: TextStyle(color: context.theme.splashColor),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: _handleBackButtonPressed,
                child: NextButton(
                  text: "Back"
                ),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    questionInd = questionInd + 1;
                  });
                },
                child: NextButton(
                  text: "Next",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}