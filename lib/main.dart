import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget{
  const WeatherHomePage({super.key});

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();

}

class _WeatherHomePageState extends State<WeatherHomePage>{
  late Future<Weather> futureWeather;

   @override
  void initState() {
    super.initState();
    
    futureWeather=fetchWeather();
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Weather"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FutureBuilder<Weather>(
            future: futureWeather,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 5,
                    color: Colors.white.withOpacity(0.9), // Card color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            snapshot.data!.place,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${snapshot.data!.temperature}°C',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            snapshot.data!.weatherSummary,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _buildDetailColumn('Min Temp', '${snapshot.data!.minTemperature}°C'),
                              _buildDetailColumn('Max Temp', '${snapshot.data!.maxTemperature}°C'),
                              _buildDetailColumn('Air Quality', '${snapshot.data!.airQuality}'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Air Quality Summary: ${snapshot.data!.airQualitySummary}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const Text('No data available');
              }
            },
          ),
        ),
      ),
    );
  }
 
  Widget _buildDetailColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}

// Model for weather data
class Weather {
  final String place;
  final String temperature;
  final String weatherSummary;
  final String minTemperature;
  final String maxTemperature;
  final String airQuality;
  final String airQualitySummary;

  Weather({
    required this.place,
    required this.temperature,
    required this.weatherSummary,
    required this.minTemperature,
    required this.maxTemperature,
    required this.airQuality,
    required this.airQualitySummary,
  });
}

// Fetch weather data from API
Future<Weather> fetchWeather() async {
  final response = await http.get(Uri.parse('https://raw.githubusercontent.com/Surya-Digital-Interviews/weather-api-public/main/get-current-weather.txt'));

  if (response.statusCode == 200) {
    return parseWeather(response.body);
  } else {
    throw Exception('Failed to load weather data');
  }
}

// Function to parse plain text weather data
Weather parseWeather(String responseBody) {
  final lines = responseBody.split('\n');
  final Map<String, String> weatherData = {};

  for (var line in lines) {
    final keyValue = line.split(': ');
    if (keyValue.length == 2) {
      weatherData[keyValue[0]] = keyValue[1].trim();
    }
  }

  return Weather(
    place: weatherData['place'] ?? '',
    temperature: weatherData['temperature'] ?? '',
    weatherSummary: weatherData['weather_summary'] ?? '',
    minTemperature: weatherData['minimum_temperature'] ?? '',
    maxTemperature: weatherData['maximum_temperature'] ?? '',
    airQuality: weatherData['air_quality'] ?? '',
    airQualitySummary: weatherData['air_quality_summary'] ?? '',
  );
}