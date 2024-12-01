import 'package:aigro/local_db/db.dart';
import 'package:aigro/utils/get_lat_long.dart';
import 'package:aigro/utils/weather_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hive/hive.dart';
import 'package:velocity_x/velocity_x.dart';

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

  final languageBox = Hive.box("Language_db");
  LanguageDB ldb = LanguageDB();
  FlutterTts flutterTts = FlutterTts();
  _speak(String text) async {
    await flutterTts.setLanguage(ldb.language); 
    await flutterTts.setPitch(0.7); 
    await flutterTts.speak(text); 
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
    if(languageBox.get("LANG") == null){
      ldb.createLang();
    }
    else{
      ldb.loadLang();
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
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(
        title: const Text('Weather Forecast'),
      ),
      body: FutureBuilder<List<WeatherData>>(
        future: weatherService.fetchWeather(lat, lon),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return  Center(
              child: CircularProgressIndicator(
                color: context.theme.primaryColorDark, 
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
            final todayweather=weatherList[0];
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      color: context.theme.highlightColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.nights_stay, 
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${todayweather.tempDay.round()}°C',
                              style: TextStyle(
                                fontSize: 40,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${daysOfWeek[1]}, ${TimeOfDay.now().format(context)}', 
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.cloud, size: 24, color: Colors.grey[400]),
                                const SizedBox(width: 8),
                                Text(
                                  todayweather.description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on, size: 24, color: context.theme.cardColor),
                                const SizedBox(width: 8),
                                Text(
                                  userDist,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
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
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: const Color.fromARGB(255, 205, 233, 206), 
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
                                          color: context.theme.highlightColor,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          daysOfWeek[index],
                                          style:  TextStyle(
                                            color: context.theme.primaryColorDark,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      weather.description,
                                      style:  TextStyle(
                                        color: context.theme.highlightColor,
                                        fontSize: 16,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(1.0, 1.0),
                                            blurRadius: 3.0,          
                                            color: const Color.fromARGB(255, 211, 199, 199), 
                                          ),
                                        ],
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
              color: context.theme.primaryColorDark, 
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: context.theme.primaryColorDark, 
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
