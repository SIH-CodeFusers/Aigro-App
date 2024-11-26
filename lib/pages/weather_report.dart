import 'package:aigro/local_db/db.dart';
import 'package:aigro/utils/get_lat_long.dart';
import 'package:aigro/utils/weather_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  //default: lat lon of london
  double lat = 51.50;
  double lon = 0.12;

  void getDaysList() {
    DateTime now = DateTime.now();

    List<String> daysOfWeekNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    for (int i = 0; i < 7; i++) {
      daysOfWeek.add(daysOfWeekNames[(now.weekday + i) % 7]);
    }
  }

  final infobox = Hive.box("BasicInfo-db");
  BasicDB bdb = BasicDB();
  String userDist = "abc";
  //default pin
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
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(title: const Text('Weather Forecast')),
      body: FutureBuilder<List<WeatherData>>(
        future: weatherService.fetchWeather(lat, lon),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(
              color: context.theme.primaryColorDark,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No weather data available'));
          } else {
            final weatherList = snapshot.data!; 
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child:Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Weather at: ",style: TextStyle(color: context.theme.primaryColorDark,fontSize: 20),),
                        Text(userDist,style: TextStyle(color: context.theme.cardColor,fontSize: 20),),
                      ],
                    ),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Pincode: ",style: TextStyle(color: context.theme.primaryColorDark,fontSize: 20),),
                        Text(userPin,style: TextStyle(color: context.theme.cardColor,fontSize: 20),),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Container(
                      decoration: BoxDecoration(
                        color: context.theme.highlightColor,
                        borderRadius: BorderRadius.circular(10)
                      ),       
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Table(
                          border: const TableBorder(
                            horizontalInside: BorderSide.none, 
                            verticalInside: BorderSide.none,     
                          ),
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: context.theme.cardColor, 
                              ),
                              children: const [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Max Temp (°C)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Min Temp (°C)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Temp (°C)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Humidity', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Weather', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                            for (int i = 0; i < weatherList.length; i++)
                              TableRow(
                                children: [
                                  TableCell(
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(daysOfWeek[i], style: const TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${weatherList[i].tempMax}°C', style: const TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${weatherList[i].tempMin}°C', style: const TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${weatherList[i].tempDay}°C', style: const TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${weatherList[i].humidity}%', style: const TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(weatherList[i].description, style: const TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),


              ),
            );
          }
        },
      ),
    );
  }
}
