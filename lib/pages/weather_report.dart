import 'package:aigro/local_db/db.dart';
import 'package:aigro/utils/get_lat_long.dart';
import 'package:aigro/utils/weather_helper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class WeatherReport extends StatefulWidget {
  const WeatherReport({super.key});

  @override
  State<WeatherReport> createState() => _WeatherReportState();
}

class _WeatherReportState extends State<WeatherReport> {
  final WeatherService weatherService = WeatherService();
  List<String> daysOfWeek = [];

  double lat = 51.50; 
  double lon = 0.12;

  void getDaysList() {
    DateTime now = DateTime.now();
    List<String> daysOfWeekNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    for (int i = 0; i < 7; i++) {
      daysOfWeek.add(daysOfWeekNames[(now.weekday + i - 1) % 7]);
    }
  }

  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();
  String userDist = "abc";
  String userPin = "700042";

  @override
  void initState() {
    super.initState();
    if (infobox.get("NAMEDB") == null) {
      bdb.createInitialInfo();
      userPin = bdb.userPin;
      userDist = bdb.userDistrict;
    } else {
      bdb.loadDataInfo();
      userPin = bdb.userPin;
      userDist = bdb.userDistrict;
    }

    getLatLongFromPincode(bdb.userPin).then((latLon) {
      setState(() {
        lat = latLon['lat']!;
        lon = latLon['lon']!;
      });
    });
    getDaysList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: FutureBuilder<List<WeatherData>>(
        future: weatherService.fetchWeather(lat, lon),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D32), 
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No weather data available'));
          } else {
            final weatherList = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: const Color(0xFF66BB6A),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Location: ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  userDist,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Pincode: ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  userPin,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: weatherList.length,
                    itemBuilder: (context, index) {
                      final weather = weatherList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: const Color(0xFFA5D6A7), 
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.cloud,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          daysOfWeek[index],
                                          style: const TextStyle(
                                            color: Color(0xFF2E7D32),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      weather.description,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildWeatherDetail("Max Temp",
                                        "${weather.tempMax}°C", Icons.thermostat),
                                    _buildWeatherDetail("Min Temp",
                                        "${weather.tempMin}°C", Icons.thermostat),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildWeatherDetail("Avg Temp",
                                        "${weather.tempDay}°C", Icons.wb_sunny),
                                    _buildWeatherDetail("Humidity",
                                        "${weather.humidity}%", Icons.water_drop),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildWeatherDetail(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon, 
              color: Color(0xFF2E7D32), 
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2E7D32), 
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
