import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// import '../models/country.dart'; // Country model no longer needed here for getCountries

class ApiService {
  // Removed countriesEndpoint and restCountriesEndpoint
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Removed getCountries method and _tryFetch method

  Future<Map<String, dynamic>> getWeather({
    required double lat,
    required double lng,
  }) async {
    String url = ''; // Declare url in an accessible scope
    try {
      url = kIsWeb // Assign value to the declared url
          ? 'http://localhost:8081/weather?latitude=$lat&longitude=$lng'
          : 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current_weather=true';
      final uri = Uri.parse(url);
      final res = await _client.get(uri);
      if (res.statusCode != 200) {
        debugPrint('Failed to load weather from $url: ${res.statusCode} - ${res.body}');
        throw Exception('Failed to load weather (${res.statusCode})');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e, stack) {
      debugPrint('Error fetching weather from ' + url + ': $e\n$stack');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
