import 'dart:convert';
import 'package:aigro/secret.dart';
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
  // for testing
  final List<LatLng> markersCoordinates = [
    LatLng(22.54, 88.36),
    LatLng(22.57, 88.33),
    LatLng(22.59, 88.37),
  ];

  Marker? customMarker;

  late double lat;
  late double long;

  bool isLoading = true;

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
                  'Custom Marker',
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
  void initState() {
    super.initState();
    getLatLongFromPincode('700042');
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
              ...markersCoordinates.map((latLng) {
                return Marker(
                  width: 40,
                  height: 40,
                  point: latLng,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }).toList(),
              if (customMarker != null) customMarker!, // Add custom marker conditionally
            ],
          ),
        ],
      ),
    );
  }
}
