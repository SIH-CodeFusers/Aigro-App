import 'package:aigro/pages/home.dart';
import 'package:aigro/utils/translate.dart';
import 'package:aigro/widgets/voice_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import 'package:aigro/local_db/db.dart';
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

  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();
  FlutterTts flutterTts = FlutterTts();
  _speak(String text) async {
    String translatedText = await translateTextInput(text, ldb.language);
    await flutterTts.setLanguage(ldb.language);
    await flutterTts.setPitch(0.7);
    await flutterTts.speak(translatedText);
  }

  int questionInd = 0;
  int totalQuestions = 7;

  bool _isError = false;

  bool olduser = false;
  late StreamSubscription<bool> keyboardSubscription;
  final _phonecontroller = TextEditingController();
  final _namecontroller = TextEditingController();
  final _pincontroller = TextEditingController();
  

  final List<String> states = [
    "West Bengal",
  ];

  String? selectedState;

  final List<String> countries = [
    "India",
  ];

  String selectedCountry="India";

  Map<String, List<String>> districtData = {
    "PURULIA": ["PUNCHA", "BPURULIA-I", "MANBAZAR-II"],
    "24 PARGANAS SOUTH": ["HARAO"],
    "ALIPURDUAR": ["KALCHINI"],
    "BANKURA": ["HIRBANDH", "GANGAJAL GHATI", "PATRASAYER", "SONAMUKHI", "TALDANGRA", "INDPUR", "BARJORA"],
    "BIRBHUM": ["ILLAMBAZAR", "BOLPUR-SRINIKETAN", "MOHAMMAD BAZAR", "SURI-II"],
    "COOCHBEHAR": ["SITALKUCHI"],
    "DARJEELING": ["KHARIBARI", "KURSEONG", "PHANSIDEWA"],
    "PURBA BARDHAMAN": ["KALNA II", "KATWA-I", "MANTESWAR", "MEMARI-II", "BURDWAN-II", "BHATAR", ""],
    "NADIA": ["KRISHNAGAR-II", "SANTIPUR", "HARINGHATA"],
    "MURSHIDABAD": ["KANDI", "SAGARDIGHI", "KHARGRAM", "NABAGRAM", "RANINAGAR-II", "LALGOLA"],
    "MEDINIPUR WEST": ["GHATAL", "SALBANI", "GARBETA-II", "NARAYANGARH", "KHARAGPUR-II", "MIDNAPORE", "DEBRA", "DASPUR-II", "DASPUR-I", "GARBETA-I"],
    "MEDINIPUR EAST": ["TAMLUK", "SHAHID MATANGINI", "PANSKURA-I"],
    "JHARGRAM": ["JAMBANI"],
    "HOWRAH": ["DOMJUR", "AMTA-II", "UDAYNARAYANPUR"],
    "HOOGHLY": ["CHINSURAH-MAGRAH", "DHANIAKHALI", "SINGUR", "SIRAMPUR-UTTARPARA", "GOGHAT-II", "POLBA-DADPUR"],
    "KALIAGANJ": ["KALIAGANJ"],
    "DINAJPUR DAKSHIN": ["HILI", "BANSIHARI", "TAPAN"],
    "PASCHIM BARDHAMAN": ["JAMURIA"],
  };

  List<String> crops = [
    "Tomato", "Corn", "Rice", "Mango", "Apple", "Tea", "Banana","Cotton","Sugarcane","Jute"
  ];

  List<String> selectedCrops = [];


  String? selectedDistrict;
  String? selectedBlock;

  final startbox = Hive.box("Start_db");
  StartPointer db = StartPointer();

  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();


  @override
  void initState() {
    super.initState();
    if(languageBox.get("LANG") == null){
      ldb.createLang();
    }
    else{
      ldb.loadLang();
    }
  }

  _saveForm() {
    setState(() {
      db.startHome = true;
      bdb.userName = _namecontroller.text;
      bdb.userPhn = _phonecontroller.text;
      bdb.userCountry = selectedCountry ?? "";
      bdb.userPin=_pincontroller.text;
      bdb.userState = selectedState ?? ""; 
      bdb.userDistrict = selectedDistrict ?? "";
      bdb.userBlock = selectedBlock ?? ""; 
      bdb.userCrops = selectedCrops; 
    });
    
    db.updateTheme();
    bdb.updateDbInfo(); 

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false, 
    );
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
              } 
              else if (questionInd == 2) {
                return StateSelect(context);
              }
              else if (questionInd == 3) {
                return DistrictSelect(context);
              }
              else if (questionInd == 4) {
                return BlockSelect(context);
              }
              else if (questionInd == 5) {
                return PinSelect(context);
              }
              else if (questionInd == 6) {
                return CropSelect(context);
              }
              else {
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
        const Spacer(), 
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.theme.highlightColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), 
                  blurRadius: 10, 
                  offset: const Offset(0, 0), 
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "What is your name?",
                            style: TextStyle(color: context.theme.primaryColorDark, fontSize: 22),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        _speak("What is your name?");
                      },
                      child: voiceIcon(context),
                    )
                  ],
                ),
                const SizedBox(height: 20),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isError==true)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Please enter your name.",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded( 
                      child: GestureDetector(
                        onTap: () {
                          if (!_namecontroller.text.isEmpty) {
                            setState(() {
                              questionInd += 1;
                              _isError = false;  
                            });
                          } else {
                            setState(() {
                              _isError = true;  
                            });
                          }
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
        const Spacer(),
      ],
    );
  }


  //Phone Number
  Widget PhoneSelect(BuildContext context) {
    return Column(
      children: [
        ProgressIndicatorWidget(
          questionInd: questionInd,
          totalQuestions: totalQuestions,
          onBackButtonPressed: _handleBackButtonPressed,
        ),
        const Spacer(), 
       Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: context.theme.highlightColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), 
                blurRadius: 10, 
                offset: const Offset(0, 0), 
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "What is your contact number?",
                          style: TextStyle(color: context.theme.primaryColorDark, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                   GestureDetector(
                      onTap: (){
                        _speak("What is your contact number?");
                      },
                      child: voiceIcon(context),
                    )
                ],
              ),
              
              const SizedBox(height: 20),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              if (_isError==true)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Please enter valid phone no.",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 10),
              Row(
                children: [
                  Expanded( 
                    child: GestureDetector(
                       onTap: () {
                          if (_phonecontroller.text.length==10) {
                            setState(() {
                              questionInd += 1;
                              _isError = false;  
                            });
                          } else {
                            setState(() {
                              _isError = true;  
                            });
                          }
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
        const Spacer(),
      ],
    );
  }

 

  //State
  Widget StateSelect(BuildContext context) {
    return Column(
      children: [
        ProgressIndicatorWidget(
          questionInd: questionInd,
          totalQuestions: totalQuestions,
          onBackButtonPressed: _handleBackButtonPressed,
        ),
        const Spacer(),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.theme.highlightColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), 
                  blurRadius: 10, 
                  offset: const Offset(0, 0), 
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Select your State",
                            style: TextStyle(color: context.theme.primaryColorDark, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: (){
                          _speak("Select your state");
                        },
                        child: voiceIcon(context),
                      )
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.theme.primaryColorDark, 
                      width: 2.0, 
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: selectedState,
                    hint: Text(
                      'Select a State',
                      style: TextStyle(color: context.theme.primaryColorDark),
                    ),
                    isExpanded: true,
                    items: states.map((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state, style: TextStyle(color: context.theme.primaryColorDark)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedState = newValue;
                      });
                    },
                    style: TextStyle(color: context.theme.primaryColorDark, fontSize: 18),
                    underline: Container(),
                    iconEnabledColor: context.theme.primaryColorDark, 
                  ),
                ),
                const SizedBox(height: 20),
                if (_isError==true)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Please select a state.",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded( 
                      child: GestureDetector(
                        onTap: () {
                            if (selectedState!=null) {
                              setState(() {
                                questionInd += 1;
                                _isError = false;  
                              });
                            } else {
                              setState(() {
                                _isError = true;  
                              });
                            }
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
        const Spacer(),
      ],
    );
  }

  Widget DistrictSelect(BuildContext context) {
    return Column(
      children: [
        ProgressIndicatorWidget(
          questionInd: questionInd,
          totalQuestions: totalQuestions,
          onBackButtonPressed: _handleBackButtonPressed,
        ),
        const Spacer(),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.theme.highlightColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Select your District",
                            style: TextStyle(color: context.theme.primaryColorDark, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: (){
                          _speak("Select your District");
                        },
                        child: voiceIcon(context),
                      )
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.theme.primaryColorDark,
                      width: 2.0,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: selectedDistrict,
                    hint: Text(
                      'Select a District',
                      style: TextStyle(color: context.theme.primaryColorDark),
                    ),
                    isExpanded: true,
                    items: districtData.keys.map((String district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(district, style: TextStyle(color: context.theme.primaryColorDark)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDistrict = newValue;
                        selectedBlock = null; // Reset the block when district changes
                      });
                    },
                    style: TextStyle(color: context.theme.primaryColorDark, fontSize: 18),
                    underline: Container(),
                    iconEnabledColor: context.theme.primaryColorDark,
                  ),
                ),
                const SizedBox(height: 20),
                if (_isError==true)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Please select a district.",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded( 
                      child: GestureDetector(
                        onTap: () {
                            if (selectedDistrict!=null) {
                              setState(() {
                                questionInd += 1;
                                _isError = false;  
                              });
                            } else {
                              setState(() {
                                _isError = true;  
                              });
                            }
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
        const Spacer(),
      ],
    );
  }

  Widget BlockSelect(BuildContext context) {
    return Column(
      children: [
        ProgressIndicatorWidget(
          questionInd: questionInd,
          totalQuestions: totalQuestions,
          onBackButtonPressed: _handleBackButtonPressed,
        ),
        const Spacer(),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.theme.highlightColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Select your Block",
                            style: TextStyle(color: context.theme.primaryColorDark, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: (){
                          _speak("Select your Block");
                        },
                        child: voiceIcon(context),
                      )
                  ],
                ),
                const SizedBox(height: 20),
                if (selectedDistrict != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: context.theme.primaryColorDark,
                        width: 2.0,
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: selectedBlock,
                      hint: Text(
                        'Select a Block',
                        style: TextStyle(color: context.theme.primaryColorDark),
                      ),
                      isExpanded: true,
                      items: districtData[selectedDistrict]!
                          .map((String block) {
                            return DropdownMenuItem<String>(
                              value: block,
                              child: Text(block, style: TextStyle(color: context.theme.primaryColorDark)),
                            );
                          })
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBlock = newValue;
                        });
                      },
                      style: TextStyle(color: context.theme.primaryColorDark, fontSize: 18),
                      underline: Container(),
                      iconEnabledColor: context.theme.primaryColorDark,
                    ),
                  ),
                if (selectedDistrict == null)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Please select a district first.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 20),
                if (_isError==true)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Please select a block.",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded( 
                      child: GestureDetector(
                        onTap: () {
                            if (selectedBlock!=null) {
                              setState(() {
                                questionInd += 1;
                                _isError = false;  
                              });
                            } else {
                              setState(() {
                                _isError = true;  
                              });
                            }
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
        const Spacer(),
      ],
    );
  }

  Widget PinSelect(BuildContext context) {
  return Column(
    children: [
      ProgressIndicatorWidget(
        questionInd: questionInd,
        totalQuestions: totalQuestions,
        onBackButtonPressed: _handleBackButtonPressed,
      ),
      const Spacer(),
      Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: context.theme.highlightColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "What is your pincode ?",
                          style: TextStyle(color: context.theme.primaryColorDark, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: (){
                        _speak("What is your pincode ?");
                      },
                      child: voiceIcon(context),
                    )
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pincontroller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: context.theme.primaryColorDark),
                decoration: InputDecoration(
                  hintText: 'Enter your pincode',
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              // Display error message if input is invalid
              if (_isError==true)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Please enter a valid 6-digit pincode.",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
       
                        if (_pincontroller.text.length == 6) {
                          setState(() {
                            questionInd += 1;
                            _isError = false;  
                          });
                        } else {
                          setState(() {
                            _isError = true;  
                          });
                        }
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
      const Spacer(),
    ],
  );
}


  Widget CropSelect(BuildContext context) {
    return Column(
      children: [
        ProgressIndicatorWidget(
          questionInd: questionInd,
          totalQuestions: totalQuestions,
          onBackButtonPressed: _handleBackButtonPressed,
        ),
        const Spacer(),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.theme.highlightColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select your Crops",
                          style: TextStyle(color: context.theme.primaryColorDark, fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: (){
                        _speak("Select your Crops");
                      },
                      child: voiceIcon(context),
                    )
                ],
              ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10, 
                  runSpacing: 10,
                  children: crops.map((crop) {
                    return FilterChip(
                      showCheckmark: false,
                      
                      label: Text(
                        crop,
                        style: TextStyle(color: context.theme.primaryColorDark),
                      ),
                      selected: selectedCrops.contains(crop),
                      onSelected: (bool isSelected) {
                        setState(() {
                          if (isSelected) {
                            selectedCrops.add(crop);
                          } else {
                            selectedCrops.remove(crop);
                          }
                        });
                      },
                      selectedColor: context.theme.cardColor,
                      backgroundColor: context.theme.highlightColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                if (_isError==true)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Please select atleast one crop.",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded( 
                      child: GestureDetector(
                        onTap: () {
                            if (selectedCrops.length!=0) {
                              setState(() {
                                _isError = false;  
                                _saveForm();
                              });
                            } else {
                              setState(() {
                                _isError = true;  
                              });
                            }
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
        const Spacer(),
      ],
    );
  }

}