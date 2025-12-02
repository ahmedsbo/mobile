import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Re-added flutter_svg
import '../models/country.dart' as app_model; // Alias for our AppCountry model
import '../services/api.dart';
import 'package:provider/provider.dart';
import '../utils/color_extensions.dart'; // Import the new extension
// Removed: import 'package:world_countries/world_countries.dart' as wc; // Removed world_countries import

class DetailScreen extends StatefulWidget {
  final app_model.AppCountry country; // Use aliased AppCountry
  const DetailScreen({super.key, required this.country});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = false;
  String? _weatherError;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    if (widget.country.capitalLat == null || widget.country.capitalLng == null) {
      setState(() {
        _weatherError = 'Weather data unavailable for this country (no capital coordinates).';
      });
      return;
    }

    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });
    try {
      final apiService = context.read<ApiService>();
      final data = await apiService.getWeather(
        lat: widget.country.capitalLat!,
        lng: widget.country.capitalLng!,
      );
      setState(() {
        _weatherData = data;
      });
    } catch (e) {
      setState(() {
        _weatherError = 'Failed to load weather data. Please try again.';
        debugPrint('Error fetching weather in DetailScreen: $e');
      });
    } finally {
      setState(() {
        _isLoadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.country;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(c.name, style: textTheme.titleLarge!.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Hero(
            tag: 'flag:${c.flagUrl}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _FlagImageDetail(url: c.flagUrl), // Using custom _FlagImageDetail
            ),
          ),
          const SizedBox(height: 24),
          _InfoRow(label: 'Capital', value: c.capital, textTheme: textTheme),
          _InfoRow(label: 'Population', value: '${c.population}', textTheme: textTheme),
          _InfoRow(label: 'Region', value: c.region, textTheme: textTheme),
          _InfoRow(label: 'Subregion', value: c.subregion, textTheme: textTheme),
          _InfoRow(label: 'Area', value: '${c.area} km²', textTheme: textTheme),
          _InfoRow(label: 'Languages', value: c.languages.join(', '), textTheme: textTheme),
          _InfoRow(label: 'Currencies', value: c.currencies.join(', '), textTheme: textTheme),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openMaps(c.googleMapsUrl),
            icon: const Icon(Icons.map, size: 20),
            label: Text('Open in Maps', style: textTheme.labelLarge!.copyWith(fontFamily: 'Poppins')), 
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 32),
          Text('Weather in ${c.capital}', style: textTheme.headlineSmall!.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildWeatherSection(context, textTheme),
        ],
      ),
    );
  }

  Widget _buildWeatherSection(BuildContext context, TextTheme textTheme) {
    if (_isLoadingWeather) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_weatherError != null) {
      return _ErrorWidget(message: _weatherError!, textTheme: textTheme);
    }
    if (_weatherData == null || _weatherData!['current_weather'] == null) {
      return _ErrorWidget(message: 'No weather data available.', textTheme: textTheme);
    }

    final currentWeather = _weatherData!['current_weather'] as Map<String, dynamic>;
    final temperature = currentWeather['temperature']?.toString() ?? 'N/A';
    final windSpeed = currentWeather['windspeed']?.toString() ?? 'N/A';
    final windDirection = currentWeather['winddirection']?.toString() ?? 'N/A';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WeatherInfoRow(label: 'Temperature', value: '$temperature °C', textTheme: textTheme),
            _WeatherInfoRow(label: 'Wind Speed', value: '$windSpeed m/s', textTheme: textTheme),
            _WeatherInfoRow(label: 'Wind Direction', value: '$windDirection°', textTheme: textTheme),
          ],
        ),
      ),
    );
  }

  Future<void> _openMaps(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;
  const _InfoRow({required this.label, required this.value, required this.textTheme});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: textTheme.bodyMedium!.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, style: textTheme.bodyMedium!.copyWith(fontFamily: 'Poppins'))),
        ],
      ),
    );
  }
}

class _WeatherInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;
  const _WeatherInfoRow({required this.label, required this.value, required this.textTheme});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: textTheme.bodySmall!.copyWith(fontFamily: 'Poppins'))),
          Expanded(child: Text(value, style: textTheme.bodyMedium!.copyWith(fontFamily: 'Poppins', fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final TextTheme textTheme;
  const _ErrorWidget({required this.message, required this.textTheme});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(message, textAlign: TextAlign.center, style: textTheme.bodyMedium!.copyWith(fontFamily: 'Poppins', color: textTheme.bodyMedium!.color!.withAlphaFactor(0.7))),
      ),
    );
  }
}

class _FlagImageDetail extends StatelessWidget {
  final String url;
  const _FlagImageDetail({required this.url});
  @override
  Widget build(BuildContext context) {
    if (url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(url, height: 180, fit: BoxFit.contain);
    }
    return Image.network(
      url,
      height: 180,
      fit: BoxFit.contain,
      loadingBuilder: (ctx, child, progress) => progress == null ? child : const _LoadingFlag(),
      errorBuilder: (ctx, err, stack) => DetailErrorIllustration(message: 'Flag unavailable', textTheme: Theme.of(context).textTheme),
    );
  }
}

class _LoadingFlag extends StatelessWidget {
  const _LoadingFlag();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class DetailErrorIllustration extends StatelessWidget {
  final String message;
  final TextTheme textTheme;
  const DetailErrorIllustration({super.key, required this.message, required this.textTheme});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(message, style: textTheme.bodyMedium!.copyWith(fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }
}
