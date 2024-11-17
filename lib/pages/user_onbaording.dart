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
  int totalQuestions = 8;

  bool olduser = false;
  late StreamSubscription<bool> keyboardSubscription;
  // final List<String> items =
  //     List<String>.generate(100, (index) => "${index + 1}");
  // late FixedExtentScrollController _scrollController;
  final _phonecontroller = TextEditingController();
  final _namecontroller = TextEditingController();
  final _pincontroller = TextEditingController();

  final List<String> states = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu",
    "Lakshadweep",
    "Delhi",
    "Puducherry",
  ];

  String? selectedState;

  final List<String> countries = [
    "India",
  ];

  String? selectedCountry;

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
    "Tomato", "Corn", "Rice", "Mango", "Apple", "Tea", "Banana"
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
              } 
              else if (questionInd == 2) {
                return CountrySelect(context);
              }
              else if (questionInd == 3) {
                return StateSelect(context);
              }
              else if (questionInd == 4) {
                return DistrictSelect(context);
              }
              else if (questionInd == 5) {
                return BlockSelect(context);
              }
              else if (questionInd == 6) {
                return PinSelect(context);
              }
              else if (questionInd == 7) {
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
                SizedBox(height: 20),
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
  Widget PhoneSelect(BuildContext context) {
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
              SizedBox(height: 20),
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

  //State
  Widget CountrySelect(BuildContext context) {
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
                      "Which country are you from ?",
                      style: TextStyle(color: context.theme.primaryColorDark, fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.theme.primaryColorDark, 
                      width: 2.0, 
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: selectedCountry,
                    hint: Text(
                      'Select a Country',
                      style: TextStyle(color: context.theme.primaryColorDark),
                    ),
                    isExpanded: true,
                    items: countries.map((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state, style: TextStyle(color: context.theme.primaryColorDark)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCountry = newValue;
                      });
                    },
                    style: TextStyle(color: context.theme.primaryColorDark, fontSize: 18),
                    underline: Container(),
                    iconEnabledColor: context.theme.primaryColorDark, 
                  ),
                ),
                SizedBox(height: 20),
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

  //State
  Widget StateSelect(BuildContext context) {
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
                      "Select your State",
                      style: TextStyle(color: context.theme.primaryColorDark, fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
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
                SizedBox(height: 20),
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

  Widget DistrictSelect(BuildContext context) {
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
                      "Select your District",
                      style: TextStyle(color: context.theme.primaryColorDark, fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
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
                SizedBox(height: 20),
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

  Widget BlockSelect(BuildContext context) {
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
                      "Select your Block",
                      style: TextStyle(color: context.theme.primaryColorDark, fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (selectedDistrict != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Please select a district first.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                SizedBox(height: 20),
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

  Widget PinSelect(BuildContext context) {
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
                    "What is your pincode?",
                    style: TextStyle(color: context.theme.primaryColorDark, fontSize: 24),
                  ),
                ),
              ),
              SizedBox(height: 20),
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded( 
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                         questionInd+=1;
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


  Widget CropSelect(BuildContext context) {
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
                      "Select your Crops",
                      style: TextStyle(color: context.theme.primaryColorDark, fontSize: 24),
                    ),
                  ),
                ),
                SizedBox(height: 20),
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
                SizedBox(height: 20),
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