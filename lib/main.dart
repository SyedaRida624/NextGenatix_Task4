import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

// -----------------------------------------------------------------------------
// 1. Weather Data Model (JSON Parsing)
// -----------------------------------------------------------------------------
class Weather {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final String mainCondition;
  final String description;
  final int humidity;
  final double windSpeed;
  final String iconCode;

  Weather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.mainCondition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.iconCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      mainCondition: json['weather'][0]['main'] ?? '',
      description: json['weather'][0]['description'] ?? '',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      iconCode: json['weather'][0]['icon'] ?? '01d',
    );
  }
}

// -----------------------------------------------------------------------------
// 2. API Integration & Error Handling Service
// -----------------------------------------------------------------------------
class WeatherService {
  static const String apiKey = '36f6a1f508ea3fac29d0af1a23d16923';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  static Future<Weather> getWeather(String cityName) async {
    final url = '$baseUrl?q=$cityName&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('City not found. Please check spelling.');
      } else if (response.statusCode == 401) {
        throw Exception('API Key is activating. Please wait 10-15 mins or re-run.');
      } else {
        throw Exception('Server error (${response.statusCode}).');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error. Check connection.');
    }
  }
}

// -----------------------------------------------------------------------------
// 3. UI App Shell & Main Screen
// -----------------------------------------------------------------------------
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyPulse Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const WeatherHomeScreen(),
    );
  }
}

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<Weather> _weatherFuture;
  String _currentCity = 'Islamabad';

  @override
  void initState() {
    super.initState();
    _weatherFuture = WeatherService.getWeather(_currentCity);
  }

  void _searchWeather() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        _currentCity = query;
        _weatherFuture = WeatherService.getWeather(_currentCity);
      });
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0F52BA); // Sapphire/Sky Blue
    const warmYellow = Color(0xFFFFC107);  // Warm Sun Yellow

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D47A1), // Deep Sky Blue
              Color(0xFF1976D2), // Bright Sky Blue
              Color(0xFF42A5F5), // Light Accent Blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                // Search Input Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.18 * 255).round()),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withAlpha((0.3 * 255).round()),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchWeather(),
                    decoration: InputDecoration(
                      hintText: 'Search city...',
                      hintStyle: TextStyle(
                        color: Colors.white.withAlpha((0.7 * 255).round()),
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, color: warmYellow),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded, color: warmYellow),
                        onPressed: _searchWeather,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Async Data Renderer
                Expanded(
                  child: FutureBuilder<Weather>(
                    future: _weatherFuture,
                    builder: (context, snapshot) {
                      // 1. Loading State
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: warmYellow,
                          ),
                        );
                      }

                      // 2. Error State
                      if (snapshot.hasError) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha((0.15 * 255).round()),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withAlpha((0.2 * 255).round()),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: warmYellow,
                                  size: 60,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  snapshot.error.toString().replaceAll('Exception: ', ''),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: warmYellow,
                                    foregroundColor: primaryBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _weatherFuture = WeatherService.getWeather(_currentCity);
                                    });
                                  },
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text(
                                    'Try Again',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // 3. Success State
                      if (snapshot.hasData) {
                        final weather = snapshot.data!;
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              // City Name
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: warmYellow,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${weather.cityName}, ${weather.country}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Weather Icon with Sun-Yellow Backdrop Glow
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: warmYellow.withAlpha((0.2 * 255).round()),
                                ),
                                child: Image.network(
                                  'https://openweathermap.org/img/wn/${weather.iconCode}@4x.png',
                                  width: 130,
                                  height: 130,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.wb_sunny_rounded,
                                    size: 100,
                                    color: warmYellow,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Temperature
                              Text(
                                '${weather.temperature.round()}°C',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 76,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              // Condition Tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: warmYellow,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  weather.description.toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF0D47A1),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),

                              // Key Metrics Container
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha((0.15 * 255).round()),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: Colors.white.withAlpha((0.25 * 255).round()),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildMetricTile(
                                      icon: Icons.thermostat_rounded,
                                      label: 'Feels Like',
                                      value: '${weather.feelsLike.round()}°C',
                                      accentColor: warmYellow,
                                    ),
                                    _buildMetricTile(
                                      icon: Icons.water_drop_rounded,
                                      label: 'Humidity',
                                      value: '${weather.humidity}%',
                                      accentColor: warmYellow,
                                    ),
                                    _buildMetricTile(
                                      icon: Icons.air_rounded,
                                      label: 'Wind',
                                      value: '${weather.windSpeed} m/s',
                                      accentColor: warmYellow,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: accentColor, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha((0.8 * 255).round()),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}