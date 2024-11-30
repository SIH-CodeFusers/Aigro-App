import 'package:aigro/pages/about_us.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:velocity_x/velocity_x.dart';

class DiseaseManagement extends StatefulWidget {
  final Map<String,dynamic> soilDeficiency;
  final Map<String,dynamic> weatherSeverity;
  final String severity;
  final String diseaseName;
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
      required this.diseaseName
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  int calculateWeek(int day) {
    return ((day - 1) ~/ 7) + 1;
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
        child: SingleChildScrollView(
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



              ],
            ),
          ),
        ),
      ),
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
}