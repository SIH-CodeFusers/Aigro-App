// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';
import 'package:aigro/local_db/db.dart';
import 'package:aigro/pages/crop_details.dart';
import 'package:aigro/secret.dart';
import 'package:aigro/utils/get_lat_long.dart';
import 'package:aigro/widgets/voice_icon.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter/services.dart';

import '../utils/translate.dart';

class DiseaseManagement extends StatefulWidget {
  final Map<String,dynamic> soilDeficiency;
  final Map<String,dynamic> weatherSeverity;
  final String severity;
  final String diseaseName;
  final String cropName;
  final String cropId;
  final int yieldLoss;
  final int recoveryDays;
  const DiseaseManagement(
    {
      super.key, 
      required this.soilDeficiency, 
      required this.weatherSeverity, 
      required this.severity, 
      required this.yieldLoss, 
      required this.recoveryDays,
      required this.diseaseName,
      required this.cropId,
      required this.cropName
    }
  );

  @override
  State<DiseaseManagement> createState() => _DiseaseManagementState();
}

class _DiseaseManagementState extends State<DiseaseManagement> {

  FlutterTts flutterTts = FlutterTts();
  _speak(String text) async {
    String translatedText = await translateTextInput(text, ldb.language);
    await flutterTts.setLanguage(ldb.language);
    await flutterTts.setPitch(0.7);
    await flutterTts.speak(translatedText);
  }
  
  final Map<String, Map<String, dynamic>> severityMap = {
    'high': {
      'color': const Color.fromRGBO(255, 204, 128,1),
      'icon': Icons.warning,
      'iconColor': Colors.red, 
      'text': 'High Severity',
      'perc':75,
    },
    'medium': {
      'color': const Color.fromRGBO(255, 245, 156,1),
      'icon': Icons.error_outline,
      'iconColor': Colors.orange,
      'text': 'Medium Severity',
      'perc':50,
    },
    'low': {
      'color': const Color.fromARGB(255, 208, 255, 210),
      'icon': Icons.check_circle,
      'iconColor': Colors.green,
      'text': 'Low Severity',
      'perc':25,
    },
  };

  Color getColorForNutrient(int level) {
    if (level < 25) {
      return Colors.green; 
    } else if (level >= 25 && level < 50) {
      return Colors.orange; 
    } else {
      return Colors.red; 
    }
  }

  Map<String, dynamic> weather = {
    'humidity': null,
    'temperature': null,
    'raining': null,
  };

  Map<String, dynamic> getSeverityLevel(String parameter, int value) {
    Map<String, dynamic> result = {};

    if (parameter == 'temperature') {
      if (value < 25) {
        result = {'color': const Color.fromARGB(255, 167, 250, 171), 'text': 'Low Temperature, Continue normal operations.'};
      } else if (value >= 25 && value <= 35) {
        result = {'color': const Color.fromRGBO(255, 241, 114, 1), 'text': 'Medium Temperature, Stay vigillant and alert.'};
      } else {
        result = {'color': const Color.fromARGB(255, 255, 137, 101), 'text': 'High Temperature, Warning! Take shelter.'};
      }
    } else if (parameter == 'humidity') {
      if (value < 80) {
        result = {'color': const Color.fromARGB(255, 167, 250, 171), 'text': 'Low Humidity, Continue normal operations.'};
      } else if (value >= 80 && value <= 90) {
        result = {'color': const Color.fromRGBO(255, 241, 114, 1), 'text': 'Medium Humidity, Stay vigillant and alert.'};
      } else {
        result = {'color': const Color.fromARGB(255, 255, 137, 101), 'text': 'High Humidity, Warning! Take shelter.'};
      }
    } else if (parameter == 'raining') {
      if (value < 15) {
        result = {'color': const Color.fromARGB(255, 167, 250, 171), 'text': 'Low Rainfall, Continue normal operations.'};
      } else if (value >= 15 && value <= 25) {
        result = {'color': const Color.fromRGBO(255, 241, 114, 1), 'text': 'Medium Rainfall, Stay vigillant and alert.'};
      } else {
        result = {'color': const Color.fromARGB(255, 255, 137, 101), 'text': 'Heavy Rainfall, Warning! Take shelter.'};
      }
    }

    return result;
  }

  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();
  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();
  late double lat=27.0416;
  late double long=88.2664;
  bool isLoading = false;
  double organicProgress = Random().nextInt(11) + 0; 
  double inorganicProgress = Random().nextInt(11) + 0; 
  Map<String, dynamic>? treatmentData;
  final _quancontroller = TextEditingController();
  String? fertSel;
  bool updated=false;
  List<Map<String, dynamic>> cropDiseaseList = [];
  List<Map<String, dynamic>> treatmentList = [];
  int _selectedIndex = -1;
  int recommended=-1;

  @override
  void initState() {
    
    bdb.loadDataInfo(); 
    if(languageBox.get("LANG") == null){
      ldb.createLang();
    }
    else{
      ldb.loadLang();
    }
    getLatLongFromPincode(bdb.userPin).then((latLon) {
     if (latLon != null) {
        setState(() {
          lat = latLon['lat']!;
          long = latLon['lon']!;
          fetchWeatherData();
          print("Weather done");
        });
      }
      }); 
     fetchFarmDetails().then((data) {
      if (data != null) {
         setState(() {
            treatmentData = data;
            updated = isCurrentDateLater(treatmentData?['updatedAt']!);
            updateSelectionAndProgress(); 
            print("update SelectionAnd Progress");
            fetchAndStoreTreatments();
            print("fetch AndStore Treatments");
        });
      }
     
    });
     print("load Crop Diseases");
    loadCropDiseases();
     print("load Crop Diseases");
    super.initState();
  }

  void updateSelectionAndProgress() {
    if (widget.severity == "low" && widget.yieldLoss <= 21) {
      _selectedIndex=0;
      recommended=0;
      organicProgress = Random().nextInt(11) + 70;
      inorganicProgress = Random().nextInt(11) + 50;
    } else if (widget.severity == "medium" && widget.yieldLoss <= 13) {
      _selectedIndex=0;
      recommended=0;
      organicProgress = Random().nextInt(11) + 70;
      inorganicProgress = Random().nextInt(11) + 50;
    } else {
     _selectedIndex=1;
      recommended=1;
      organicProgress = Random().nextInt(11) + 50;
      inorganicProgress = Random().nextInt(11) + 70;
    }
  }


  Future<String> _translateText(String text) async {
    return await translateTextInput(text, ldb.language);
  }

  Future<void> fetchWeatherData() async {
    final lati = lat;
    final lon = long;
    try {
      final weatherResponse = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$lati&lon=$lon&appid=$OPEN_WEATHER_API_KEY&units=metric'),
      );

      if (weatherResponse.statusCode == 200) {
        final weatherData = jsonDecode(weatherResponse.body);
        setState(() {
          weather['humidity'] = weatherData['main']['humidity'].toInt();
          weather['temperature'] = (weatherData['main']['temp']).toInt();
        });
      } else {
        // print('Failed to load weather data');
      }
      final rainReport = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?lat=$lati&lon=$lon&appid=$OPEN_WEATHER_API_KEY&units=metric'),
      );
      if (rainReport.statusCode == 200) {
        final rainData = jsonDecode(rainReport.body)['list']
            .map((item) => {'rain': item['rain'] != null ? item['rain']['3h'] : 0})
            .toList();

        int rainAmount = (rainData[0]['rain'] ?? 0.0).round();

        if (rainAmount == 0) {
          String severity = "medium"; 
          if (severity == "low") {
            rainAmount = (4 + (7 - 4 + 1) * (1 + 0)).toInt(); 
          } else if (severity == "medium") {
            rainAmount = (8 + (12 - 8 + 1) * (1 + 0)).toInt(); 
          } else if (severity == "high") {
            rainAmount = (13 + (17 - 13 + 1) * (1 + 0)).toInt(); 
          }
        }

        setState(() {
          weather['raining'] = rainAmount;
        });
      } else {
        // print('Failed to load rain forecast data');
      }
    } catch (e) {
      // print('Error fetching weather data: $e');
    }
    isLoading=true;
  }


  int calculateWeek(int day) {
    return ((day - 1) ~/ 7) + 1;
  }

  Future<Map<String, dynamic>> fetchFarmDetails() async {
    final url = '$BACKEND_URL/api/imageAnalysis/fetchDetails/${widget.cropId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'];
        final Map<String, dynamic> resultDetails = {
          'fertilisers': List<String>.from(
            result['fertilisers'].map((fertilizer) => fertilizer['name'])
          ),
          'fertilisersPrice': List<String>.from(
            result['fertilisers'].map((fertilizer) => fertilizer['products'][0]['price'])
          ),
          'farmerTreatmentEmpty': result['farmerTreatment'].isEmpty,
          'createdAt': result['createdAt'],
          'updatedAt': result['updatedAt'],
          'farmerTreatment': result['farmerTreatment'] ?? [],
        };
        print(resultDetails);
        return resultDetails;
      } else {
        // print('Failed to load data');
        return {}; 
      }
    } catch (e) {
      // print('Error occurred: $e');
      return {};
    }
  }

  Future<void> handleFarmerDBUpload({
    required String fertSel, 
    required int quantity,
  }) async {

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final formattedDate = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal().toString().split(' ')[0];

    final data = {
      'id': widget.cropId,
      'fertiliser': fertSel, 
      'quantity': quantity,
      'date': formattedDate,
    };

    try {
      final response = await http.post(
        Uri.parse('$BACKEND_URL/api/imageAnalysis/updateTreatment'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DiseaseManagement(soilDeficiency: widget.soilDeficiency, weatherSeverity: widget.weatherSeverity, severity: widget.severity, yieldLoss: widget.yieldLoss, recoveryDays: widget.recoveryDays, diseaseName: widget.diseaseName, cropId: widget.cropId,cropName: widget.cropName,)), 
          );
        }
      }
    } catch (e) {
      // print('Error: $e');
    }
  }

  Future<void> loadCropDiseases() async {
        print("loaded");
    final data = await DefaultAssetBundle.of(context)
        .loadString('assets/others/crop_disease_18nov.json');
    final Map<String, dynamic> jsonResult = json.decode(data);

    print("loaded");

    setState(() {
      cropDiseaseList = (jsonResult['cropDiseases'] as List)
          .expand((crop) => (crop['diseaseDetails'] as List).map((disease) {
                return {
                  "diseaseName": disease['diseaseName'] as String,
                  "scientificName": disease['scientificName'] as String,
                  "category": disease['category'] as String,
                  "images": (disease['images'] as List).map((img) => img as String).toList(),
                  "symptoms": disease['symptoms'] as String? ?? '',
                  "causes": disease['causes'] as String? ?? '',
                  "remedies":
                      (disease['remedies'] as List?)?.map((r) => r as String).toList() ?? [],
                  "summary":
                      (disease['summary'] as List?)?.map((r) => r as String).toList() ?? [],
                  "chemicalControl": disease['chemicalControl'] as String? ?? '',
                  "organicControl": disease['organicControl'] as String? ?? '',
                  "cropName": crop['cropName'] as String,
                  "fertilizers": (disease['fertilisers'] as List?)?.map((fertilizer) {
                    return {
                      "name": fertilizer['name'] as String,
                      "products": (fertilizer['products'] as List).map((product) {
                        return {
                          "companyName": product['companyName'] as String,
                          "productImage": product['productImage'] as String,
                          "price": product['price'] as String,
                          "id": product['id'] as String,
                        };
                      }).toList(),
                      "id": fertilizer['id'] as String,
                    };
                  }).toList() ?? [],
                };
              }))
          .toList();
    });  
  }

  Future<void> fetchAndStoreTreatments() async {
    try {

      final String response = await rootBundle.loadString('assets/others/organic_control.json');
      final List<dynamic> data = jsonDecode(response);

      final String normalizedCropName = widget.cropName.toLowerCase();
      final String normalizedDiseaseName = widget.diseaseName.toLowerCase().replaceAll(RegExp(r'\s+'), "");
      final String normalizedSeverity = widget.severity.isNotEmpty
      ? widget.severity[0].toUpperCase() + widget.severity.substring(1).toLowerCase()
      : '';


      final Map<String, dynamic>? cropData = data.firstWhere(
        (item) => (item['crop'] as String).toLowerCase() == normalizedCropName,
        orElse: () => null, 
      );

      if (cropData == null) {
        throw Exception('Crop not found: ${widget.cropName}');
      }

      final Map<String, dynamic> diseases = cropData['diseases'];

      print("Searching for disease: ${widget.diseaseName}");
      final String? diseaseKey = diseases.keys.firstWhere(
        (key) => key.toLowerCase().replaceAll(RegExp(r'\s+'), "") == normalizedDiseaseName,
        orElse: () => throw Exception('Error'), 
      );

      if (diseaseKey == null) {
        throw Exception('Disease not found: ${widget.diseaseName}');
      }
      print("Disease found: $diseaseKey");

      final Map<String, dynamic>? treatmentsMap = diseases[diseaseKey];
      
      final List<dynamic>? treatments = treatmentsMap?[normalizedSeverity];

      if (treatments == null || treatments.isEmpty) {
        throw Exception('No treatments found for severity: ${widget.severity}');
      }
      print("Treatments found for severity: ${widget.severity}");


      treatmentList.clear();
      print("Storing treatments...");
      for (var treatment in treatments) {
        treatmentList.add({
          'method': treatment['method'],
          'preparation': treatment['preparation'],
          'frequency': treatment['frequency'],
        });
        print("Stored treatment: ${treatment['method']}");
      }

      print('Data fetched and stored successfully!');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> handleGroupComm(BuildContext context) async {
    setState(() {
      isLoading=true;
    });
    final data = {
      'diseaseName': widget.diseaseName,
      'userClerkId': BACKEND_UID,
      'cropName':widget.cropName,
      'pincode': bdb.userPin,
      'members': {
        'userClerkId': BACKEND_UID,
      },
    };

    print(data);

    try {
      final response = await http.post(
        Uri.parse('$CHAT_BACKEND/createorjoingroups'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      // print(response.body);
      setState(() {
        isLoading=true;
      });
      Future.delayed(const Duration(milliseconds: 1200), () {
        Navigator.pushNamed(context, '/grpHomeRoute');
      });
    } catch (error) {
      // print('Error creating or joining group: $error');
    }
  }


  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('d MMM, yyyy').format(parsedDate);
  }

  String formatAddDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    DateTime newDate = parsedDate.add(const Duration(days: 5));
    return DateFormat('d MMM, yyyy').format(newDate);
  }

  String formatDateNow(DateTime date) {
    return DateFormat('d MMM, yyyy').format(date);
  }

  bool isCurrentDateLater(String updatedAt) {
    DateTime currentDate = DateTime.now();
    DateTime formattedDate = DateTime.parse(updatedAt);
    if (!treatmentData?['farmerTreatmentEmpty']!) {
      formattedDate = formattedDate.add(const Duration(days: 5));
    } 
    return currentDate.isAfter(formattedDate) || currentDate.isAtSameMomentAs(formattedDate);
  }

  @override
  Widget build(BuildContext context) {
    final severityData = severityMap[widget.severity.toLowerCase()] ?? severityMap['low'];
 
    
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
         title: translateHelper("Disease Management", TextStyle(fontSize: 20), ldb.language)
      ),
      body: SafeArea(
        child: isLoading?
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(       
                      child: translateHelper(widget.diseaseName,TextStyle(fontSize: 24,color: context.theme.primaryColorDark),ldb.language)                 
                    ),
                    const SizedBox(width: 10,),
                    GestureDetector(
                      onTap: () {
                        _speak("This is Disease Management Dashboard. Scroll to see all about your current crop disease");
                      },
                      child: voiceIcon(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                GestureDetector(
                  onTap: (){
                    final selectedDisease = cropDiseaseList.firstWhere(
                      (disease) => disease['diseaseName'] == widget.diseaseName, 
                      orElse: () => <String, Object>{} 
                    );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CropDetails(disease: selectedDisease),
                    ),
                  );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.25, 
                    height: 30,
                    decoration: BoxDecoration(
                      color: context.theme.primaryColorDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: translateHelper( "See More", TextStyle(color: context.theme.highlightColor,fontSize: 12), ldb.language)
                    ),
                  ),
                ),
                          
                const SizedBox(height: 30,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: severityData?['color'],
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(severityData?['icon'],color: severityData?['iconColor'],),
                        const SizedBox(width: 10,),
                        Flexible(
                          child: translateHelper("${widget.severity.upperCamelCase} severity detected. Expected reccovery: ${calculateWeek(widget.recoveryDays)-1} - ${calculateWeek(widget.recoveryDays)} weeks",const TextStyle(),ldb.language),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.theme.highlightColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(FeatherIcons.activity,color: severityData?['iconColor'],),
                            const SizedBox(width: 10,),              
                            Expanded(
                              child: translateHelper("Disease Severity", TextStyle(fontSize: 18,fontWeight: FontWeight.w600),ldb.language)
                            ),
                            GestureDetector(
                              onTap: () {
                                _speak("This shows the disease severity of your crops.");
                              },
                              child: voiceIcon(context),
                            ),              
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: translateHelper("${widget.severity.upperCamelCase} Risk",const TextStyle(fontSize: 18,fontWeight: FontWeight.w600),ldb.language)
                        ),
                        const SizedBox(height: 5,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: translateHelper("Around ${severityData?['perc']} % of crops affected", const TextStyle(fontSize: 14,),ldb.language)
                        )    
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.theme.highlightColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.seedling,color: severityData?['iconColor'],size: 16,),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: translateHelper("Expected Crop Loss", TextStyle(fontSize: 18,fontWeight: FontWeight.w600),ldb.language)
                            ),
                            GestureDetector(
                              onTap: () {
                                _speak("This shows how much crop yield is expected to be lost.");
                              },
                              child: voiceIcon(context),
                            ),  
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child:translateHelper("${widget.yieldLoss} %", const TextStyle(fontSize: 18,fontWeight: FontWeight.w600),ldb.language)
                        ),
                        const SizedBox(height: 5,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: translateHelper("of your crop will be affected if untreated", TextStyle(fontSize: 14,),ldb.language)
                        )    
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.theme.highlightColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.tree,color: severityData?['iconColor'],size: 16,),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: translateHelper("Soil Health Status", TextStyle(fontSize: 18,fontWeight: FontWeight.w600),ldb.language)
                            ),
                            GestureDetector(
                              onTap: () {
                                _speak("This shows the estimated soil health status of your field.");
                              },
                              child: voiceIcon(context),
                            ), 
                          ],
                        ),
                        const SizedBox(height: 15,),
                        _buildSoilNutrientRow("Nitrogen (N)", widget.soilDeficiency['n'].round(), getColorForNutrient(widget.soilDeficiency['n'].round())),
                        _buildSoilNutrientRow("Phosphorus (P)", widget.soilDeficiency['p'].round(), getColorForNutrient(widget.soilDeficiency['p'].round())),
                        _buildSoilNutrientRow("Potassium (K)",widget.soilDeficiency['k'].round(), getColorForNutrient(widget.soilDeficiency['k'].round())),              
                      ],
                    ),
                  ),
                ),


                const SizedBox(height: 30,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.theme.highlightColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.buildingColumns,size: 16,color: Colors.grey[500],),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: translateHelper("Weather Conditions for next 5 days", TextStyle(fontSize: 18,fontWeight: FontWeight.w600),ldb.language)
                            ),
                            GestureDetector(
                              onTap: () {
                                _speak("Weather Conditions for next 5 days.");
                              },
                              child: voiceIcon(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                       _buildWeatherDetail('Temperature', weather['temperature'], 'temperature', FeatherIcons.thermometer,Colors.red,"°C"),  
                       _buildWeatherDetail('Humidity', weather['humidity'], 'humidity', FeatherIcons.droplet,Colors.blue,"%"),
                       _buildWeatherDetail('Rainfall', weather['raining'], 'raining', FeatherIcons.cloudDrizzle,Colors.grey,"mm"),
                      ],
                    ),
                  ),
                ),


                const SizedBox(height: 30,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.theme.highlightColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(FeatherIcons.clock,size: 18,color: Colors.grey[500],),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: translateHelper("Recovery Timeline", TextStyle(fontSize: 18,fontWeight: FontWeight.w600),ldb.language)
                            ),
                             GestureDetector(
                              onTap: () {
                                _speak("Your crops recovery timeline");
                              },
                              child: voiceIcon(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        for (int week = 1; week <= calculateWeek(widget.recoveryDays); week++) 
                          _buildRecoveryWeek(week, calculateWeek(widget.recoveryDays)),
                      ],
                    ),
                  ),
                ),


                const SizedBox(height: 30,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.theme.highlightColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.handHoldingHeart,size: 18,color: Colors.grey[500],),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: translateHelper("Treatment Options", TextStyle(fontSize: 18,fontWeight: FontWeight.w600),ldb.language)
                            ),
                             GestureDetector(
                              onTap: () {
                                _speak("View treatment options for your crops disease");
                              },
                              child: voiceIcon(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Column(
                          children: 
                          recommended==0?
                            [
                              buildProgressCard(
                                title: "Organic",
                                progress: organicProgress,
                                description: "Safe for soil health",
                                progressColor: Colors.green,
                                index: 0,
                                backgroundColor: Colors.green[50]!,
                              ),
                              const SizedBox(height: 10),
                              buildProgressCard(
                                title: "Inorganic",
                                progress: inorganicProgress,
                                description: "Fast acting solution",
                                progressColor: const Color.fromARGB(255, 250, 171, 22),
                                index: 1,
                                backgroundColor: Colors.orange[50]!,
                              ),
                              ]:
                              [
                              buildProgressCard(
                                title: "Inorganic",
                                progress: inorganicProgress,
                                description: "Fast acting solution",
                                progressColor: const Color.fromARGB(255, 250, 171, 22),
                                index: 1,
                                backgroundColor: Colors.orange[50]!,
                              ),
                              const SizedBox(height: 10),
                              buildProgressCard(
                                title: "Organic",
                                progress: organicProgress,
                                description: "Safe for soil health",
                                progressColor: Colors.green,
                                index: 0,
                                backgroundColor: Colors.green[50]!,
                              ),        
                            ],
                          )
                      ],
                    ),
                  ),
                ),

               const SizedBox(height: 30,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.theme.highlightColor,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(FontAwesomeIcons.leaf,size: 18,color: Colors.grey[500],),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: translateHelper("Methods",TextStyle(fontSize: 18,fontWeight: FontWeight.w600),ldb.language),       
                            ),
                             GestureDetector(
                              onTap: () {
                                _speak("If the method is organic you can check out the product and if it is chemical you can check out the product and its prices");
                              },
                              child: voiceIcon(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        treatmentData != null && treatmentData?['fertilisers'] != null && _selectedIndex==1
                        ? buildChemicalFert()
                          : SizedBox.shrink(),

                          _selectedIndex==0?
                          buildOrganicFert(context)
                          :SizedBox.shrink(),
                        ],
                    ),
                  ),
                ),


                treatmentData?['farmerTreatmentEmpty']==false?
                Column(
                  children: [
                    SizedBox(height: 20,),
                     Row(
                      children: [
                        Icon(FeatherIcons.clock,size: 18,color: Colors.grey[500],),
                        const SizedBox(width: 10,),
                         Expanded(
                          child: translateHelper("Previous Tracking", TextStyle(fontSize: 20,fontWeight: FontWeight.w600), ldb.language)
                        ),
                        GestureDetector(
                          onTap: () {
                            _speak("This shows the Previous Tracking of your crops.");
                          },
                          child: voiceIcon(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  if (value.toInt() == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    value.toInt().toString(),
                                    style:  TextStyle(color: context.theme.primaryColorDark, fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  if (value == 0) {
                                    return const Text("Date", style: TextStyle(color: Colors.black));
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: const FlGridData(show: true),
                          borderData: FlBorderData(
                            show: true,
                            border: const Border(
                              left: BorderSide(color: Colors.black, width: 2),
                              right: BorderSide.none,
                              top: BorderSide.none, 
                              bottom:BorderSide(color: Colors.black, width: 1), 
                            ),
                          ),
                          minY: 0,
                          maxY: 20,
                          lineBarsData: [
                            LineChartBarData(
                              spots: treatmentData!['farmerTreatment']
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    double xPosition = entry.key.toDouble();
                                    if (treatmentData!['farmerTreatment'].length == 1) {
                                      xPosition = 0.5;
                                    }
                                    return FlSpot(xPosition, (entry.value['quantity'] as num).toDouble());
                                  })
                                  .toList()
                                  .cast<FlSpot>(),
                              isCurved: true,  
                              color: context.theme.primaryColorDark,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: context.theme.cardColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
             
                :const SizedBox.shrink(),

                const SizedBox(height: 30,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.theme.highlightColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: treatment(context),
                  ),
                ),
      
              ],
            ),
          ),
        )
        :Center(
          child: CircularProgressIndicator(color: context.theme.primaryColorDark,)
        ),
      ),
    );
  }

  Column buildOrganicFert(BuildContext context) {
    return Column(
      children: List.generate(
        treatmentList.length,
        (index) {
          var treatment = treatmentList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
                padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon( FontAwesomeIcons.seedling,size: 16,color: context.theme.primaryColorDark,),
                      SizedBox(width: 5,),
                      Flexible(
                        child: translateHelper('${treatment['method']}',TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: context.theme.primaryColorDark,),ldb.language)
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                 Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ 
                      translateHelper('Preparation:', TextStyle(fontSize: 12,color: context.theme.primaryColorDark,fontWeight: FontWeight.bold), ldb.language),    
                      Expanded(
                        child: translateHelper(' ${treatment['preparation']}',TextStyle(fontSize: 12,),ldb.language)
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ 
                      translateHelper('Frequency:', TextStyle(fontSize: 12,color: context.theme.primaryColorDark,fontWeight: FontWeight.bold), ldb.language),    
                      Expanded(
                        child: translateHelper(' ${treatment['frequency']}',TextStyle(fontSize: 12,),ldb.language)
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Column buildChemicalFert() {
    return Column(
      children: List.generate(
        treatmentData?['fertilisers'].length,
        (index) {
          final name = treatmentData?['fertilisers'][index];
          final price = treatmentData?['fertilisersPrice'][index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                                  
                  Row(    
                    children: [
                      Icon(FeatherIcons.tag,size: 14,),
                      SizedBox(width: 10,),
                      Flexible(
                        child: FutureBuilder<String>(
                            future: _translateText(name),
                            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text(
                                  'Translating...',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                );
                              } else if (snapshot.hasError) {
                                return Text(
                                  'Error loading name',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                );
                              } else {
                                return Text(
                                  snapshot.data ?? name, 
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                            },
                          ),
                      ),
                    ],
                  ),  
                  const SizedBox(width: 10),
                    Row(    
                    children: [
                      Icon(FeatherIcons.dollarSign,size: 14,),
                      SizedBox(width: 10,),
                      Flexible(
                        child: FutureBuilder<String>(
                          future: _translateText(price), 
                          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Text(
                                'Translating...',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error loading price',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              );
                            } else {
                              return Text(
                                snapshot.data ?? price, 
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                    const SizedBox(width: 10),
                    Row(    
                    children: [
                      Icon(FeatherIcons.box,size: 14,),
                      SizedBox(width: 10,),
                      Flexible(
                        child: FutureBuilder<String>(
                          future: _translateText('20'), 
                          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Text(
                                'Translating...',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error loading quantity',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              );
                            } else {
                              return Text(
                                'Quantity: ${snapshot.data ?? '20'}', 
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildProgressCard({
      required String title,
      required double progress,
      required String description,
      required Color progressColor,
      required int index,
      required Color backgroundColor,
    }) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _selectedIndex == index ? backgroundColor : Colors.transparent,
            border: Border.all(width: 1, color: context.theme.canvasColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  translateHelper(title, TextStyle(fontSize: 16), ldb.language),
                  const Spacer(),
                  Text("${progress.toStringAsFixed(0)}%"),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              translateHelper(description, const TextStyle(fontSize: 12), ldb.language)
            ],
          ),
        ),
      );
    }

  Column treatment(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.disease, size: 18, color: Colors.grey[500]),
            const SizedBox(width: 10),
             Expanded(
              child:
              translateHelper("Treatment Tracking", TextStyle(fontSize: 18, fontWeight: FontWeight.w600), ldb.language)
            ),
            GestureDetector(
              onTap: () {
                _speak("Treatment Tracking using pesticides");
              },
              child: voiceIcon(context),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             translateHelper("Last Treatment:",  TextStyle(fontSize: 16), ldb.language),
            Text(
              treatmentData?['farmerTreatmentEmpty']! ? "NA"
              :formatDate(treatmentData?['updatedAt']!), 
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            translateHelper("Next Treatment:",  TextStyle(fontSize: 16), ldb.language),
            Text(
                treatmentData?['farmerTreatmentEmpty']! ? formatDateNow(DateTime.now())
              :formatAddDate(treatmentData?['updatedAt']!), 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
            ),
          ],
        ),
        const SizedBox(height: 20),
        translateHelper("Select Pesticide", TextStyle(fontSize: 16), ldb.language),
        const SizedBox(height: 8),
        IgnorePointer(
          ignoring: treatmentData?['farmerTreatmentEmpty']! ?false:true,
          child: DropdownButtonFormField<String>(
            value: treatmentData?['fertilisers']?.isNotEmpty == true
                ? (!(treatmentData?['farmerTreatmentEmpty'] ?? true)
                    ? (treatmentData?['farmerTreatment']?.isNotEmpty == true
                        ? treatmentData!['farmerTreatment'][0]['fertiliser']
                        : treatmentData!['fertilisers'][0])
                    : treatmentData!['fertilisers'][0])
                : '',
            style: TextStyle(fontSize: 12, color: context.theme.primaryColorDark),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.theme.primaryColorDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: context.theme.primaryColorDark, width: 2),
              ),
            ),
            items: treatmentData?['fertilisers'] != null
                ? treatmentData!['fertilisers']
                    .map<DropdownMenuItem<String>>(
                      (fertiliser) => DropdownMenuItem<String>(
                        value: fertiliser,
                        child: FutureBuilder<String>(
                          future: _translateText(fertiliser),
                          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Text(
                                'Translating...',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error loading text',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              );
                            } else {
                              final translatedText = snapshot.data ?? '';
                              final displayText = translatedText.length > 30 
                                  ? '${translatedText.substring(0, 30)}...' 
                                  : translatedText;

                              return Text(
                                displayText,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              );
                            }
                          },
                        )
                      ),
                    )
                    .toList()
                : [], 
            onChanged: (value) { 
              setState(() {
                fertSel = value;
              });   
            },     
          ),
        ),

        const SizedBox(height: 20),
        translateHelper("Quantity Used",  TextStyle(fontSize: 16), ldb.language),
        const SizedBox(height: 8),
        TextField(
          controller: _quancontroller,
          cursorColor: context.theme.primaryColorDark,
          decoration: InputDecoration(    
            hintText: "Enter Quantity",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: context.theme.primaryColorDark)),
            focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(8),borderSide: BorderSide(color: context.theme.primaryColorDark,width: 2),),
          ),
          maxLines: 1,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
        ),
        const SizedBox(height: 20), 
        IgnorePointer(                 
          ignoring: updated ?false:true,
          child: ElevatedButton(
            onPressed: () {
            int quantity = int.tryParse(_quancontroller.text) ?? 0;
            handleFarmerDBUpload(fertSel: fertSel ?? '', quantity:quantity,);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:updated? context.theme.primaryColorDark:const Color.fromRGBO(109, 143, 132,1),
              foregroundColor: context.theme.highlightColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: translateHelper("Save Treatment Details", const TextStyle(), ldb.language)
          ),
        ),
        const SizedBox(height: 20), 
        ElevatedButton(
          onPressed: () => handleGroupComm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.theme.primaryColorDark,
            foregroundColor: context.theme.highlightColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child:translateHelper("Fertilizer Group", const TextStyle(), ldb.language)
        ),
      ],
    );
  }

  Widget _buildSoilNutrientRow(String nutrient, int level, Color color) {
    return Row(
      children: [
        Icon(
          FeatherIcons.target, 
          color: color,
          size: 10,
        ),
        const SizedBox(width: 10),
        translateHelper("$nutrient: $level%", const TextStyle(fontSize: 16), ldb.language)
      ],
    );
  }

  Widget _buildWeatherDetail(String header, int value, String parameter,IconData iconData,Color iconColor,String unit) {
    Map<String, dynamic> severity = getSeverityLevel(parameter, value);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: severity['color'].withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData,color: iconColor,size: 22,),
              const SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  translateHelper(header, const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), ldb.language),
                  translateHelper('$value $unit',const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),ldb.language)
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: translateHelper( '${severity['text']}', const TextStyle(fontSize: 14), ldb.language)
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryWeek(int week, int totalWeeks) {
    String weekText = '';
    Color color = Colors.blue;

    if (week == 1) {
      weekText = 'Initial treatment applied';
      color = Colors.orange;
    } else if (week == totalWeeks) {
      weekText = 'Nearly fully recovered';
      color = Colors.green;
    } else {
      weekText = 'Treatment ongoing';
      color = Colors.yellow;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0,vertical: 8),
        decoration: BoxDecoration(
          color:week==1? Colors.grey[200]:context.theme.highlightColor,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: translateHelper(week.toString(),TextStyle(color: context.theme.highlightColor,fontWeight: FontWeight.bold),ldb.language)
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                translateHelper('Week $week',const TextStyle(fontSize: 16),ldb.language),
                translateHelper( ' $weekText',TextStyle(fontSize: 16,color: Colors.grey[500]),ldb.language)
              ],  
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder<String> translateHelper(String title, TextStyle style, String lang) {
    return FutureBuilder<String>(
      future: translateTextInput(title, lang),
      builder: (context, snapshot) {
        String displayText = snapshot.connectionState == ConnectionState.waiting || snapshot.hasError
            ? title
            : snapshot.data ?? title;

        return Text(displayText, style: style);
      },
    );
  }

}