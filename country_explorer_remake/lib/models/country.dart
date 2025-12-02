import 'dart:convert';
import 'package:country_utils/country_utils.dart' as cu; // Alias for country_utils Country class

class AppCountry {
  final String name;
  final String capital;
  final String flagUrl;
  final String isoCodeAlpha2; // Added for flags
  final int population;
  final String region;
  final String subregion;
  final List<String> languages;
  final List<String> currencies;
  final double area;
  final String googleMapsUrl;
  final double? capitalLat;
  final double? capitalLng;

  const AppCountry({
    required this.name,
    required this.capital,
    required this.flagUrl,
    required this.isoCodeAlpha2,
    required this.population,
    required this.region,
    required this.subregion,
    required this.languages,
    required this.currencies,
    required this.area,
    required this.googleMapsUrl,
    required this.capitalLat,
    required this.capitalLng,
  });

  static AppCountry fromJson(Map<String, dynamic> json) {
    String name = _readName(json);
    String capital = _readCapital(json);
    final flags = json['flags'] ?? {};
    final png = flags is Map<String, dynamic> ? (flags['png'] as String?) : null;
    final svg = flags is Map<String, dynamic> ? (flags['svg'] as String?) : null;
    final flagUrl = png ?? svg ?? (json['flag'] as String? ?? '');

    final population = (json['population'] is num) ? (json['population'] as num).toInt() : 0;
    final region = (json['region'] as String?) ?? '';
    final subregion = (json['subregion'] as String?) ?? '';

    final languagesList = _readLanguages(json);
    final currenciesList = _readCurrencies(json);

    final area = (json['area'] is num) ? (json['area'] as num).toDouble() : 0.0;
    final maps = json['maps'] ?? {};
    final googleMaps = maps is Map<String, dynamic>
        ? (maps['googleMaps'] as String? ?? '')
        : (json['googleMaps'] as String? ?? '');

    final capitalInfo = json['capitalInfo'];
    double? lat;
    double? lng;
    if (capitalInfo is Map && capitalInfo['latlng'] is List && (capitalInfo['latlng'] as List).length >= 2) {
      final list = capitalInfo['latlng'] as List;
      lat = (list[0] as num?)?.toDouble();
      lng = (list[1] as num?)?.toDouble();
    } else if (json['latlng'] is List && (json['latlng'] as List).length >= 2) {
      final list = json['latlng'] as List;
      lat = (list[0] as num?)?.toDouble();
      lng = (list[1] as num?)?.toDouble();
    }

    return AppCountry(
      name: name,
      capital: capital,
      flagUrl: flagUrl,
      isoCodeAlpha2: json['isoCodeAlpha2'] as String? ?? '',
      population: population,
      region: region,
      subregion: subregion,
      languages: languagesList,
      currencies: currenciesList,
      area: area,
      googleMapsUrl: googleMaps,
      capitalLat: lat,
      capitalLng: lng,
    );
  }

  // Factory constructor to create a AppCountry from country_utils's Country object
  factory AppCountry.fromCountryUtils(cu.Country cuCountry) {
    final String iso2 = cuCountry.isoCodeAlpha2.toLowerCase();
    final String flagUrl = 'https://flagcdn.com/w160/' + iso2 + '.png';

    return AppCountry(
      name: cuCountry.name ?? 'Unknown',
      capital: 'N/A', // Not available in country_utils 0.5.0
      flagUrl: flagUrl, // Now dynamically generated
      isoCodeAlpha2: cuCountry.isoCodeAlpha2, // Mapped from country_utils
      population: 0, // Not available in country_utils 0.5.0
      region: 'Unknown', // Not available in country_utils 0.5.0
      subregion: 'Unknown', // Not available in country_utils 0.5.0
      languages: [], // Not available in country_utils 0.5.0
      currencies: [], // Not available in country_utils 0.5.0
      area: 0.0, // Not available in country_utils 0.5.0
      googleMapsUrl: '', // Not available in country_utils 0.5.0
      capitalLat: null, // Not available in country_utils 0.5.0
      capitalLng: null, // Not available in country_utils 0.5.0
    );
  }

  static String _readName(Map<String, dynamic> json) {
    if (json['name'] is Map<String, dynamic>) {
      final map = json['name'] as Map<String, dynamic>;
      return (map['common'] as String?) ?? (map['official'] as String?) ?? 'Unknown';
    }
    return (json['name'] as String?) ?? 'Unknown';
  }

  static String _readCapital(Map<String, dynamic> json) {
    final capital = json['capital'];
    if (capital is List && capital.isNotEmpty) return capital.first.toString();
    if (capital is String) return capital;
    return 'N/A';
  }

  static List<String> _readLanguages(Map<String, dynamic> json) {
    final langs = json['languages'];
    if (langs is Map<String, dynamic>) {
      return langs.values.map((e) => e.toString()).toList();
    }
    if (langs is List) {
      return langs.map((e) => e.toString()).toList();
    }
    return const [];
  }

  static List<String> _readCurrencies(Map<String, dynamic> json) {
    final curr = json['currencies'];
    if (curr is Map<String, dynamic>) {
      return curr.values.map((e) {
        if (e is Map<String, dynamic>) {
          final name = e['name']?.toString() ?? '';
          final symbol = e['symbol']?.toString() ?? '';
          return symbol.isNotEmpty ? '$name ($symbol)' : name;
        }
        return e.toString();
      }).toList();
    }
    if (curr is List) {
      return curr.map((e) => e.toString()).toList();
    }
    return const [];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'capital': capital,
      'flagUrl': flagUrl,
      'isoCodeAlpha2': isoCodeAlpha2, // Added to toJson
      'population': population,
      'region': region,
      'subregion': subregion,
      'languages': languages,
      'currencies': currencies,
      'area': area,
      'googleMapsUrl': googleMapsUrl,
      'capitalLat': capitalLat,
      'capitalLng': capitalLng,
    };
  }

  static String encodeList(List<AppCountry> list) => jsonEncode(list.map((c) => c.toJson()).toList());
  static List<AppCountry> decodeList(String s) =>
      (jsonDecode(s) as List<dynamic>).map((e) => AppCountry.fromJson(e as Map<String, dynamic>)).toList();
}
