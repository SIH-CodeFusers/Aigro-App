import 'package:aigro/secret.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = WEATHER_FORECAST_KEY;
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/forecast/daily';


  Future<List<WeatherData>> fetchWeather(double lat, double lon) async {
    final response = await http.get(Uri.parse(
        '$baseUrl?lat=$lat&lon=$lon&cnt=7&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<WeatherData> weatherList = [];
      
      for (var day in data['list']) {
        weatherList.add(WeatherData.fromJson(day, data['city']['name']));
      }

      return weatherList;
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

class WeatherData {
  final String cityName;
  final double tempDay;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final String description;
  final String icon;

  WeatherData({
    required this.cityName,
    required this.tempDay,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.description,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String cityName) {
    return WeatherData(
      cityName: cityName,
      tempDay: json['temp']['day'],
      tempMin: json['temp']['min'],
      tempMax: json['temp']['max'],
      humidity: json['humidity'],
      description: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
    );
  }
}
