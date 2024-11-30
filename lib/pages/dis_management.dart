import 'package:flutter/material.dart';

class DiseaseManagement extends StatefulWidget {
  final Map<String,dynamic> soilDeficiency;
  final Map<String,dynamic> weatherSeverity;
  final String severity;
  final int yieldLoss;
  final int recoveryDays;
  const DiseaseManagement({super.key, required this.soilDeficiency, required this.weatherSeverity, required this.severity, required this.yieldLoss, required this.recoveryDays});

  @override
  State<DiseaseManagement> createState() => _DiseaseManagementState();
}

class _DiseaseManagementState extends State<DiseaseManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:Text(
          "${widget.weatherSeverity}"
        )
      ),
    );
  }
}