import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:aigro/secret.dart';


Future<Map<String, double>> getLatLongFromPincode(String pincode) async {
  final String apiUrl =
      'http://api.openweathermap.org/geo/1.0/zip?zip=$pincode,IN&appid=$OPEN_WEATHER_API_KEY';
  
  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        double lat = data['lat'];
        double lon = data['lon'];
        return {'lat': lat, 'lon': lon}; 
      } else {
        print('No data found for this pincode.');
      }
    } else {
      print('Failed to fetch data.');
    }
  } catch (e) {
    print('Error occurred: $e');
  }

  return {'lat': 51.50, 'lon': 0.12};
}