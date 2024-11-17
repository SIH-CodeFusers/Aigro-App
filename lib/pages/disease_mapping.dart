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

  Marker customMarker = Marker(
    point: LatLng(22.57, 88.36),
    width: 60,
    height: 60,

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disease Mapping')),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter : LatLng(22.57, 88.36),
          initialZoom : 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: markersCoordinates.map((latLng) {
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
            }).toList()
            ..add(customMarker),
          ),
        ],
       
      ),
    );
  }
}
