import 'package:aigro/utils/weather_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class WeatherReport extends StatefulWidget {
  const WeatherReport({super.key});

  @override
  State<WeatherReport> createState() => _WeatherReportState();
}

class _WeatherReportState extends State<WeatherReport> {
  final WeatherService weatherService = WeatherService();
  List<String> daysOfWeek = [];

  void getDaysList() {
    DateTime now = DateTime.now();

    List<String> daysOfWeekNames = [
      'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
    ];

    // Generate a list of day names for the next 7 days
    for (int i = 0; i < 7; i++) {
      daysOfWeek.add(daysOfWeekNames[(now.weekday + i) % 7]);
    }
  }

  @override
  void initState() {
    getDaysList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.canvasColor,
      appBar: AppBar(title: Text('Weather Forecast')),
      body: FutureBuilder<List<WeatherData>>(
        future: weatherService.fetchWeather(22.67,88.36),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No weather data available'));
          } else {
            final weatherList = snapshot.data!; 
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child:Column(
                  children: [
                    Row(
                      children: [
                        Text("Weather at:"),
                        Text(" Kolkata"),
                      ],
                    ),
                     Row(
                      children: [
                        Text("Pincode:"),
                        Text(" Kolkata"),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: context.theme.highlightColor,
                        borderRadius: BorderRadius.circular(10)
                      ),       
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Table(
                          border: TableBorder(
                            horizontalInside: BorderSide.none, 
                            verticalInside: BorderSide.none,     
                          ),
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: context.theme.cardColor, 
                              ),
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Max Temp (°C)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Min Temp (°C)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Temp (°C)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Humidity', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
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
                                        child: Text('${daysOfWeek[i]}', style: TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${weatherList[i].tempMax}°C', style: TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${weatherList[i].tempMin}°C', style: TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${weatherList[i].tempDay}°C', style: TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${weatherList[i].humidity}%', style: TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('${weatherList[i].description}', style: TextStyle(fontSize: 14)),
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
