import 'dart:convert';
import 'package:aigro/local_db/db.dart';
import 'package:aigro/secret.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:velocity_x/velocity_x.dart';

class DiseaseMapping extends StatefulWidget {
  const DiseaseMapping({super.key});

  @override
  State<DiseaseMapping> createState() => _DiseaseMappingState();
}

class _DiseaseMappingState extends State<DiseaseMapping> {
  
  Marker? customMarker;
  List<Marker> nearbyMarkers = []; // List to hold markers from the response

  late double lat;
  late double long;
  bool isLoading = true;

  Future<void> getNearbyAlerts(String pincode) async {
    const String apiUrl = 'https://aigro-backend-alpha.vercel.app/api/futurePred/fetchNearbyAlerts';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "pincode": pincode,
        "lat": "22.966",
        "long": "88.2036",
        "range": "100"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['exists'] == true && data['nearbyAlerts'] != null) {
        List<Marker> fetchedMarkers = [];

        for (var alert in data['nearbyAlerts']) {
          double alertLat = alert['lat'];
          double alertLong = alert['lon'];
          String cropName = alert['cropName'];

          fetchedMarkers.add(
            Marker(
              point: LatLng(alertLat, alertLong),
              width: 80,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    cropName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        setState(() {
          nearbyMarkers = fetchedMarkers;
          isLoading = false;
        });
      } else {
        print('No nearby alerts found for this pincode.');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('Failed to fetch data from the API.');
      setState(() {
        isLoading = false;
      });
    }
  }


  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();

   @override
  void initState() {
    super.initState();
    bdb.loadDataInfo(); 
    getLatLongFromPincode(bdb.userPin);
    getLatLongFromPincode(bdb.userPin);
    getNearbyAlerts('700105');
  }

  Future<void> getLatLongFromPincode(String pincode) async {
    final String apiUrl =
        'http://api.openweathermap.org/geo/1.0/zip?zip=$pincode,IN&appid=$OPEN_WEATHER_API_KEY';
    
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        double newLat = data['lat'];
        double newLong = data['lon'];

        setState(() {
          lat = newLat;
          long = newLong;
          customMarker = Marker(
            point: LatLng(lat, long),
            width: 80,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Me',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );

          isLoading = false;
        });
      } else {
        print('No data found for this pincode.');
      }
    } else {
      print('Failed to fetch data.');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Disease Mapping')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
 
      appBar: AppBar(title: const Text('Disease Mapping')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(lat, long),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
                ...nearbyMarkers,
              if (customMarker != null) customMarker!, // Add custom marker conditionally
            ],
          ),
        ],
      ),
    );
  }
}
