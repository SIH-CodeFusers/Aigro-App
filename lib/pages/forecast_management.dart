import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ForecastManagement extends StatefulWidget {
  final String diseaseName;
  final int count;

  const ForecastManagement({
    Key? key,
    required this.diseaseName,
    required this.count,
  }) : super(key: key);

  @override
  State<ForecastManagement> createState() => _ForecastManagementState();
}

class _ForecastManagementState extends State<ForecastManagement> {
  String alertLevel = "";
  List<Map<String, dynamic>> cropDiseaseList = [];
  

  static const Color lightGreen = Color(0xFFA5D6A7);
  static const Color primaryColorDark = Color(0xFF66BB6A);

  @override
  void initState() {
    super.initState();
    _determineAlertLevel();
    loadCropDiseases();
  }

  void _determineAlertLevel() {
    if (widget.count <= 7) {
      alertLevel = "Low";
    } else if (widget.count > 7 && widget.count <= 15) {
      alertLevel = "Rising";
    } else {
      alertLevel = "Alert";
    }
  }

  Future<void> loadCropDiseases() async {
    final data = await DefaultAssetBundle.of(context)
        .loadString('assets/others/forecast.json');
    List<dynamic> jsonResult = json.decode(data);

    setState(() {
      cropDiseaseList = jsonResult
          .where((disease) =>
              disease["disease_name"].toLowerCase() ==
              widget.diseaseName.toLowerCase())
          .map((disease) => Map<String, dynamic>.from(disease))
          .toList();
    });
  }

  Color _getAlertColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return primaryColorDark;
      case 'rising':
        return Colors.orange;
      case 'alert':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBreadcrumbNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.canvasColor,
        border: Border(
          bottom: BorderSide(color: lightGreen),
        ),
      ),
      child: Row(
        children: [
          Text(
            widget.diseaseName,
            style: TextStyle(color: context.theme.primaryColorDark, fontWeight: FontWeight.w500),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getAlertColor(alertLevel).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              alertLevel,
              style: TextStyle(
                color: _getAlertColor(alertLevel),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.theme.primaryColorDark),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: context.theme.primaryColorDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard(Map<String, dynamic> measure, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: lightGreen),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Day: ${measure["day"]}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.theme.primaryColorDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.science_outlined,
              'Chemical Treatment',
              measure["chemical_treatment"],
            ),
            _buildInfoRow(
              Icons.water_damage,
              'Application Method',
              measure["application_method"],
            ),
            _buildInfoRow(
              Icons.water_drop_outlined,
              'Dosage',
              measure["dosage"],
            ),
            _buildInfoRow(
              Icons.shield_outlined,
              'Target Prevention',
              measure["target_prevention"],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.theme.canvasColor,
        title: Row(
          children: [
            Text(
              'Forecasting Management',
              style: TextStyle(color: context.theme.primaryColorDark, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.eco,
              color: context.theme.primaryColorDark,
              size: 20,
            ),
          ],
        ),
        iconTheme: IconThemeData(color: primaryColorDark),
      ),
      body: cropDiseaseList.isEmpty
          ? Center(child: CircularProgressIndicator(color: primaryColorDark))
          : Column(
              children: [
                _buildBreadcrumbNavigation(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: cropDiseaseList[0]["prevention_plan"][alertLevel]
                            ["measures"]
                        .length,
                    itemBuilder: (context, index) {
                      var measure = cropDiseaseList[0]["prevention_plan"]
                          [alertLevel]["measures"][index];
                      return _buildTreatmentCard(measure, index);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}