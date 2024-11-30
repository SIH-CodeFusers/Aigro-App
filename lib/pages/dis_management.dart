import 'dart:convert';
import 'dart:math';
import 'package:aigro/local_db/db.dart';
import 'package:aigro/pages/crop_details.dart';
import 'package:aigro/secret.dart';
import 'package:aigro/utils/get_lat_long.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter/services.dart';

class DiseaseManagement extends StatefulWidget {
  final Map<String,dynamic> soilDeficiency;
  final Map<String,dynamic> weatherSeverity;
  final String severity;
  final String diseaseName;
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
    }
  );

  @override
  State<DiseaseManagement> createState() => _DiseaseManagementState();
}

class _DiseaseManagementState extends State<DiseaseManagement> {
  
  final Map<String, Map<String, dynamic>> severityMap = {
    'high': {
      'color': Color.fromRGBO(255, 204, 128,1),
      'icon': Icons.warning,
      'iconColor': Colors.red, 
      'text': 'High Severity',
      'perc':75,
    },
    'medium': {
      'color': Color.fromRGBO(255, 245, 156,1),
      'icon': Icons.error_outline,
      'iconColor': Colors.orange,
      'text': 'Medium Severity',
      'perc':50,
    },
    'low': {
      'color': Color.fromARGB(255, 208, 255, 210),
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
        result = {'color': Color.fromARGB(255, 167, 250, 171), 'text': 'Low Temperature, Continue normal operations.'};
      } else if (value >= 25 && value <= 35) {
        result = {'color': Color.fromRGBO(255, 241, 114, 1), 'text': 'Medium Temperature, Stay vigillant and alert.'};
      } else {
        result = {'color': Color.fromARGB(255, 255, 137, 101), 'text': 'High Temperature, Warning! Take shelter.'};
      }
    } else if (parameter == 'humidity') {
      if (value < 80) {
        result = {'color': Color.fromARGB(255, 167, 250, 171), 'text': 'Low Humidity, Continue normal operations.'};
      } else if (value >= 80 && value <= 90) {
        result = {'color': Color.fromRGBO(255, 241, 114, 1), 'text': 'Medium Humidity, Stay vigillant and alert.'};
      } else {
        result = {'color': Color.fromARGB(255, 255, 137, 101), 'text': 'High Humidity, Warning! Take shelter.'};
      }
    } else if (parameter == 'raining') {
      if (value < 15) {
        result = {'color': Color.fromARGB(255, 167, 250, 171), 'text': 'Low Rainfall, Continue normal operations.'};
      } else if (value >= 15 && value <= 25) {
        result = {'color': Color.fromRGBO(255, 241, 114, 1), 'text': 'Medium Rainfall, Stay vigillant and alert.'};
      } else {
        result = {'color': Color.fromARGB(255, 255, 137, 101), 'text': 'Heavy Rainfall, Warning! Take shelter.'};
      }
    }

    return result;
  }

  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();
  late double lat=27.0416;
  late double long=88.2664;
  bool isLoading = false;
  final double organicProgress = Random().nextInt(11) + 50; 
  final double inorganicProgress = Random().nextInt(11) + 70; 
  Map<String, dynamic>? treatmentData;
  final _quancontroller = TextEditingController();
  String? fertSel;
  bool updated=false;
  List<Map<String, dynamic>> cropDiseaseList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bdb.loadDataInfo(); 
    getLatLongFromPincode(bdb.userPin).then((latLon) {
      setState(() {
          lat = latLon['lat']!;
          long = latLon['lon']!;
          fetchWeatherData();
        });
      }); 
    fetchFarmDetails().then((data) {
      setState(() {
        treatmentData = data;
        updated = isCurrentDateLater(treatmentData?['createdAt']!);
      });
    });
    loadCropDiseases();
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
        print('Failed to load weather data');
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
        print('Failed to load rain forecast data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
    isLoading=true;
  }


  int calculateWeek(int day) {
    return ((day - 1) ~/ 7) + 1;
  }

  Future<Map<String, dynamic>> fetchFarmDetails() async {
    final url = 'https://api.thefuturetech.xyz/api/imageAnalysis/fetchDetails/${widget.cropId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'];
        final Map<String, dynamic> resultDetails = {
          'fertilisers': List<String>.from(
            result['fertilisers'].map((fertilizer) => fertilizer['name'])
          ),
          'farmerTreatmentEmpty': result['farmerTreatment'].isEmpty,
          'createdAt': result['createdAt'],
          'updatedAt': result['updatedAt'],
          'farmerTreatment': result['farmerTreatment'] ?? [],
        };
        return resultDetails;
      } else {
        print('Failed to load data');
        return {}; 
      }
    } catch (e) {
      print('Error occurred: $e');
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
        Uri.parse('https://api.thefuturetech.xyz/api/imageAnalysis/updateTreatment'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print(responseData['message']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DiseaseManagement(soilDeficiency: widget.soilDeficiency, weatherSeverity: widget.weatherSeverity, severity: widget.severity, yieldLoss: widget.yieldLoss, recoveryDays: widget.recoveryDays, diseaseName: widget.diseaseName, cropId: widget.cropId,)), 
          );
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

    Future<void> loadCropDiseases() async {
    final data = await DefaultAssetBundle.of(context)
        .loadString('assets/others/crop_disease_18nov.json');
    final Map<String, dynamic> jsonResult = json.decode(data);

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

  

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('d MMM, yyyy').format(parsedDate);
  }

  String formatAddDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    DateTime newDate = parsedDate.add(Duration(days: 5));
    return DateFormat('d MMM, yyyy').format(newDate);
  }

  String formatDateNow(DateTime date) {
    return DateFormat('d MMM, yyyy').format(date);
  }

  bool isCurrentDateLater(String createdAt) {
    DateTime currentDate = DateTime.now();
    DateTime formattedDate = DateTime.parse(createdAt);
    if (!treatmentData?['farmerTreatmentEmpty']!) {
      formattedDate = formattedDate.add(Duration(days: 5));
    } 
    return currentDate.isAfter(formattedDate) || currentDate.isAtSameMomentAs(formattedDate);
  }

  @override
  Widget build(BuildContext context) {
    final severityData = severityMap[widget.severity.toLowerCase()] ?? severityMap['low'];
 
    
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
         title: const Text("Disease Management",style: TextStyle(fontSize: 20),),
      ),
      body: SafeArea(
        child: isLoading?
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 16),
            child: Column(
              children: [
                SizedBox(height: 20,),
                Center(
                    child: Text(
                      "${widget.diseaseName}",
                      style: TextStyle(fontSize: 24,color: context.theme.primaryColorDark),
                    ),      
                ),
                SizedBox(height: 10,),
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
                      child: Text(
                        "See More",
                        style: TextStyle(color: context.theme.highlightColor,fontSize: 12),
                      ),
                    ),
                  ),
                ),
                          
                SizedBox(height: 30,),
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
                        SizedBox(width: 10,),
                        Flexible(
                          child: Text("${widget.severity.upperCamelCase} severity detected. Expected reccovery: ${calculateWeek(widget.recoveryDays)-1} - ${calculateWeek(widget.recoveryDays)} weeks" )
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30,),
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
                            SizedBox(width: 10,),
                            Flexible(
                              child: Text("Disease Severity",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),)
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text("${widget.severity.upperCamelCase} Risk",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                        ),
                        SizedBox(height: 5,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text("Around ${severityData?['perc']} % of crops affected",style: TextStyle(fontSize: 14,),),
                        )    
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30,),
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
                            SizedBox(width: 10,),
                            Flexible(
                              child: Text("Expected Crop Loss",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),)
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text("${widget.yieldLoss} %",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                        ),
                        SizedBox(height: 5,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text("of your crop will be affected if untreated",style: TextStyle(fontSize: 14,),),
                        )    
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30,),
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
                            SizedBox(width: 10,),
                            Flexible(
                              child: Text("Soil Health Status",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),)
                            )
                          ],
                        ),
                        SizedBox(height: 15,),
                        _buildSoilNutrientRow("Nitrogen (N)", widget.soilDeficiency['n'], getColorForNutrient(widget.soilDeficiency['n'])),
                        _buildSoilNutrientRow("Phosphorus (P)", widget.soilDeficiency['p'], getColorForNutrient(widget.soilDeficiency['p'])),
                        _buildSoilNutrientRow("Potassium (K)",widget.soilDeficiency['k'], getColorForNutrient(widget.soilDeficiency['k'])),              
                      ],
                    ),
                  ),
                ),


                SizedBox(height: 30,),
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
                            SizedBox(width: 10,),
                            Flexible(
                              child: Text("Weather Conditions for next 5 days",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),)
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                       _buildWeatherDetail('Temperature', weather['temperature'], 'temperature', FeatherIcons.thermometer,Colors.red,"°C"),  
                       _buildWeatherDetail('Humidity', weather['humidity'], 'humidity', FeatherIcons.droplet,Colors.blue,"%"),
                       _buildWeatherDetail('Rainfall', weather['raining'], 'raining', FeatherIcons.cloudDrizzle,Colors.grey,"mm"),
                      ],
                    ),
                  ),
                ),


                SizedBox(height: 30,),
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
                            SizedBox(width: 10,),
                            Flexible(
                              child: Text("Recovery Timeline",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),)
                            )
                          ],
                        ),
                        SizedBox(height: 20),
                        for (int week = 1; week <= calculateWeek(widget.recoveryDays); week++) 
                          _buildRecoveryWeek(week, calculateWeek(widget.recoveryDays)),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1,color: context.theme.canvasColor),
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text("Organic", style: TextStyle(fontSize: 16)),
                                        Spacer(),
                                        Text("${organicProgress.toStringAsFixed(0)}%")
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: organicProgress / 100,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                        minHeight: 6,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text("Safe for soil health", style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1,color: context.theme.canvasColor),
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text("Inorganic", style: TextStyle(fontSize: 16)),
                                        Spacer(),
                                        Text("${inorganicProgress.toStringAsFixed(0)}%")
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: inorganicProgress / 100,
                                        backgroundColor: Colors.grey[300],
                                        valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 250, 171, 22)),
                                        minHeight: 6,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text("Fast acting solution", style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                treatmentData?['farmerTreatmentEmpty']==false?
                Column(
                  children: [
                    Text(
                      treatmentData?['farmerTreatment'] != null && treatmentData!['farmerTreatment'].isNotEmpty
                          ? "Quantity: ${treatmentData!['farmerTreatment'][0]['quantity']}"
                          : "No farmer treatment data available"
                    ),
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
                                    "${value.toInt().toString()}",
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
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
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
                              dotData: FlDotData(show: true),
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
             
                :SizedBox.shrink(),

                SizedBox(height: 30,),
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

  Column treatment(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.disease, size: 18, color: Colors.grey[500]),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                "Treatment Tracking",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Last Treatment:", style: TextStyle(fontSize: 16)),
            Text(
              treatmentData?['farmerTreatmentEmpty']! ? "NA"
              :formatDate(treatmentData?['createdAt']!), 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Next Treatment:", style: TextStyle(fontSize: 16)),
            Text(
                treatmentData?['farmerTreatmentEmpty']! ? formatDateNow(DateTime.now())
              :formatAddDate(treatmentData?['createdAt']!), 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
            ),
          ],
        ),
        SizedBox(height: 20),
        Text("Select Fertilizer",style: TextStyle(fontSize: 16),),
        SizedBox(height: 8),
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
                        child: Text(
                          fertiliser.length > 30 ? fertiliser.substring(0, 30) + '...' : fertiliser,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
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

        SizedBox(height: 20),
        Text("Quantity Used",style: TextStyle(fontSize: 16),),
        SizedBox(height: 8),
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
        SizedBox(height: 20), 
        IgnorePointer(                 
          ignoring: updated ?false:true,
          child: ElevatedButton(
            onPressed: () {
            int quantity = int.tryParse(_quancontroller.text) ?? 0;
            handleFarmerDBUpload(fertSel: fertSel ?? '', quantity:quantity,);
            },
            child: Text("Save Treatment Details"),
            style: ElevatedButton.styleFrom(
              backgroundColor:updated? context.theme.primaryColorDark:Color.fromRGBO(109, 143, 132,1),
              foregroundColor: context.theme.highlightColor,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        SizedBox(height: 20), 
        ElevatedButton(
          onPressed: () {
            print(updated);
          },
          child: Text("Fertilizer Group"),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.theme.primaryColorDark,
            foregroundColor: context.theme.highlightColor,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
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
        SizedBox(width: 10),
        Text(
          "$nutrient: $level%",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(String header, int value, String parameter,IconData iconData,Color iconColor,String unit) {
    Map<String, dynamic> severity = getSeverityLevel(parameter, value);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(16),
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
              SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    header,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$value $unit',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${severity['text']}',
              style: TextStyle(fontSize: 14),
            ),
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
                child: Text(week.toString(),style: TextStyle(color: context.theme.highlightColor,fontWeight: FontWeight.bold),),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Week $week',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  ' $weekText',
                  style: TextStyle(fontSize: 16,color: Colors.grey[500]),
                ),
              ],  
            ),
          ],
        ),
      ),
    );
  }

}