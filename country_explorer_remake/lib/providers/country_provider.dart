import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/country.dart' as app_model; // Alias for our AppCountry model
import 'package:country_utils/country_utils.dart' as cu; // Import country_utils
// Removed: import '../services/api.dart'; // ApiService no longer fetches countries

enum SortOption { nameAZ, populationAsc, populationDesc, areaAsc, areaDesc }

class CountryProvider extends ChangeNotifier {
  // Removed: final ApiService api; // ApiService no longer a dependency for country data
  // Removed: CountryProvider(this.api);
  CountryProvider(); // Updated constructor

  final List<app_model.AppCountry> _countries = []; // Use aliased AppCountry
  bool _isLoading = false;
  String? _errorMessage;

  final Set<String> _favorites = <String>{};
  String _searchQuery = '';
  bool _onlyFavorites = false;
  SortOption _sort = SortOption.nameAZ;

  ThemeMode _themeMode = ThemeMode.system;

  UnmodifiableListView<app_model.AppCountry> get countries => UnmodifiableListView(_countries); // Use aliased AppCountry
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  bool get onlyFavorites => _onlyFavorites;
  SortOption get sort => _sort;
  ThemeMode get themeMode => _themeMode;

  List<app_model.AppCountry> get visibleCountries { // Use aliased AppCountry
    Iterable<app_model.AppCountry> list = _countries; // Use aliased AppCountry
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.capital.toLowerCase().contains(q));
    }
    if (_onlyFavorites) {
      list = list.where((c) => _favorites.contains(c.name));
    }
    final sorted = List<app_model.AppCountry>.from(list); // Use aliased AppCountry
    switch (_sort) {
      case SortOption.nameAZ:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.populationAsc:
        sorted.sort((a, b) => a.population.compareTo(b.population));
        break;
      case SortOption.populationDesc:
        sorted.sort((a, b) => b.population.compareTo(a.population));
        break;
      case SortOption.areaAsc:
        sorted.sort((a, b) => a.area.compareTo(b.area));
        break;
      case SortOption.areaDesc:
        sorted.sort((a, b) => b.area.compareTo(a.area));
        break;
    }
    return sorted;
  }

  Future<void> init() async {
    await _loadPrefs();
    await fetchCountries();
  }

  Future<void> fetchCountries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Fetch countries directly from country_utils
      final cuCountries = cu.CountryService.getCountries();
      final data = cuCountries.map((cuC) => app_model.AppCountry.fromCountryUtils(cuC)).toList(); // Use aliased AppCountry
      _countries
        ..clear()
        ..addAll(data);
    } catch (e) {
      _errorMessage = 'Unable to load countries. Please try again.';
      debugPrint('Error in fetchCountries: $e'); // Added detailed logging
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void toggleOnlyFavorites() {
    _onlyFavorites = !_onlyFavorites;
    notifyListeners();
  }

  void setSort(SortOption option) {
    _sort = option;
    notifyListeners();
  }

  bool isFavorite(app_model.AppCountry c) => _favorites.contains(c.name); // Use aliased AppCountry

  Future<void> toggleFavorite(app_model.AppCountry c) async { // Use aliased AppCountry
    if (isFavorite(c)) {
      _favorites.remove(c.name);
    } else {
      _favorites.add(c.name);
    }
    notifyListeners();
    await _saveFavorites();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? const <String>[];
    _favorites
      ..clear()
      ..addAll(favs);
    final theme = prefs.getString('themeMode');
    if (theme == 'light') _themeMode = ThemeMode.light;
    if (theme == 'dark') _themeMode = ThemeMode.dark;
    // Using system default if no preference or invalid preference is stored
    if (theme == null || (theme != 'light' && theme != 'dark')) {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites.toList());
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    switch (_themeMode) {
      case ThemeMode.system:
      case ThemeMode.dark:
        _themeMode = ThemeMode.light;
        await prefs.setString('themeMode', 'light');
        break;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        await prefs.setString('themeMode', 'dark');
        break;
    }
    notifyListeners();
  }
}
