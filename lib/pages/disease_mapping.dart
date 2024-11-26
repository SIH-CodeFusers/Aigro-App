import 'dart:convert';
import 'package:aigro/local_db/db.dart';
import 'package:aigro/secret.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class DiseaseMapping extends StatefulWidget {
  const DiseaseMapping({super.key});

  @override
  State<DiseaseMapping> createState() => _DiseaseMappingState();
}

class _DiseaseMappingState extends State<DiseaseMapping> {

   Map<String, Object> data = {
    "success": true,
    "shops": [
      {
        "name": "S.R.NURSERY (K.C.KHANRA)",
        "address": "Taki Rd, Kholapota, Mathurapur",
        "location": {
          "lat": 22.5929954,
          "lon": 88.51164009999999
        }
      },
      {
        "name": "Biswas Fertilizer",
        "address": "Ghoraras Ghona Road, Zafarpur",
        "location": {
          "lat": 22.605915,
          "lon": 88.48249
        }
      },
      {
        "name": "Kanan Krishi Bhandar",
        "address": "Bongaon - Basirhat Rd, Kholapota, Mathurapur",
        "location": {
          "lat": 22.6235377,
          "lon": 88.31184850000001
        }
      },
      {
        "name": "Kabir Fertilizer",
        "address": "JPJV+3F2, Madar Tala",
        "location": {
          "lat": 22.6301328,
          "lon": 88.2436287
        }
      },
      {
        "name": "Hasan Fertilizer And Pesticide",
        "address": "Gram Panchayat, Haroa Rd, near by Chaita, Chaita, Malotipur",
        "location": {
          "lat": 22.6420903,
          "lon": 88.754969
        }
      },
      {
        "name": "Kabir Fertilizer",
        "address": "JPJV+3F2, Madar Tala",
        "location": {
          "lat": 22.6301328,
          "lon": 88.7436287
        }
      }
    ]
  };
  
  Marker? customMarker;
  List<Marker> nearbyMarkers = []; 
  List<Marker> shopMarkers = [];

  late double lat;
  late double long;
  bool isLoading = true;

 @override
  void initState() {
    super.initState();
    bdb.loadDataInfo(); 
    getLatLongFromPincode(bdb.userPin);
    getNearbyAlerts(bdb.userPin);
    addShopMarkers();
  }

  Future<void> getNearbyAlerts(String pincode) async {
    const String apiUrl = 'https://aigro-backend-alpha.vercel.app/api/futurePred/fetchNearbyAlerts';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "pincode": pincode,
        "lat": lat, 
        "long": long, 
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
          

          String diseaseName = '';
          String diseaseLevel = '';
          if (alert['diseaseDetails'] != null && alert['diseaseDetails'].isNotEmpty) {
            diseaseName = alert['diseaseDetails'][0]['diseaseName'];
            diseaseLevel = alert['diseaseDetails'][0]['alertLevel'];
          }

          fetchedMarkers.add(
            Marker(
              point: LatLng(alertLat, alertLong),
              width: 80,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  color: context.theme.hintColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cropName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    if (diseaseName.isNotEmpty)
                      Text(
                        '$diseaseName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Level: $diseaseLevel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                  ],
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

   Future<void> addShopMarkers() async {
    if (data['shops'] != null) {
      for (var shop in data['shops'] as List) {
        var shopLocation = shop['location'] as Map<String, double>;
        shopMarkers.add(
          Marker(
            height: 100,
            width: 100,
            point: LatLng(shopLocation['lat']!, shopLocation['lon']!),
            child: GestureDetector(
              onTap: () { 
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.theme.highlightColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              child: Divider(
                                thickness: 3,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: context.theme.highlightColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  shop['name'] as String,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image(
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      "https://static.vecteezy.com/system/resources/previews/035/321/928/non_2x/mini-cute-store-shop-merchant-building-3d-rendering-icon-illustration-concept-isolated-png.png",
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  shop['address'] as String,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () async{
                                    final latitude = shop['location']['lat'];
                                    final longitude = shop['location']['lon'];
                                    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
                                    final Uri url = Uri.parse(googleMapsUrl);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },       
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.theme.cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.navigation, size: 16, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text(
                                        'Get Directions',
                                        style: TextStyle(
                                          color: context.theme.highlightColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        "https://static.vecteezy.com/system/resources/previews/035/321/928/non_2x/mini-cute-store-shop-merchant-building-3d-rendering-icon-illustration-concept-isolated-png.png",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
  }



  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();


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
            width: 60,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset(
                      width: 60,
                      height: 60,
                      "assets/images/woman_farmer_logo.png",
                      fit: BoxFit.cover,
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
        body: Center(child: CircularProgressIndicator(
          color: context.theme.primaryColorDark,
        )),
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
              if (customMarker != null) customMarker!, 
              ...shopMarkers, 
            ],
          ),
        ],
      ),
    );
  }
}
