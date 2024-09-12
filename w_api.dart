import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services.dart';
import 'weather_class.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();

  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  void _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weather = await _weatherService.fetchWeather(31.5204, 74.3587); // London's coordinates
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch weather data. Please try again later.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final int hour = now.hour;

    // Assuming daylight starts at 6 AM and ends at 6 PM
    bool isDayTime = hour >= 5 && hour < 19;

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App' , style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDayTime
                ? [
              Colors.blue.shade200,
              Colors.blue.shade700,
            ]
                : [
              Colors.black,
              Colors.grey.shade900,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
          child: Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        )
            : _weather != null
            ? WeatherInfo(weather: _weather!)
            : Center(child: Text('No data available')),
      ),
    );
  }
}

class WeatherInfo extends StatelessWidget {
  final Weather weather;

  const WeatherInfo({required this.weather});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeString = DateFormat('hh:mm a').format(now);
    final dayString = DateFormat('EEEE').format(now);
    final dateString = DateFormat('dd MMM yyyy').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${weather.cityName}, ${weather.country}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Text(
          timeString,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        Text(
          dayString,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        Text(
          dateString,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Image.asset(
          _getWeatherImage(weather.description).assetName,
          width: 100,
          height: 100,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/thunder.jpg'); // Replace with your default image asset
          },
        ),
        SizedBox(height: 10),
        Text(
          "${weather.temperature.toStringAsFixed(0)}\u00B0 C",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          children: [
            _buildWeatherDetail('Description', weather.description),
            _buildWeatherDetail('Feels Like', '${weather.feelsLike}°C'),
            _buildWeatherDetail('Humidity', '${weather.humidity}%'),
            _buildWeatherDetail('Wind Speed', '${weather.windSpeed} m/s'),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  AssetImage _getWeatherImage(String description) {
    switch (description.toLowerCase()) {
      case 'clear sky':
        return AssetImage('assets/sun.png');
      case 'few clouds':
      case 'scattered clouds':
      case 'broken clouds':
        return AssetImage('assets/cloudy.jpg');
      case 'shower rain':
      case 'rain':
        return AssetImage('assets/rainy.jpg');
      case 'thunderstorm':
        return AssetImage('assets/thunder.jpg');
      case 'snow':
        return AssetImage('assets/snow.png');
      case 'mist':
        return AssetImage('assets/mist.jpg');
      default:
        return AssetImage('assets/mist.jpg'); // Default image for unknown conditions
    }
  }
}
