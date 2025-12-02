import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/country_provider.dart';
import 'services/api.dart';
import 'screens/home.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Added import
import 'package:country_utils/country_utils.dart'; // Added import

const bool enableSearch = true;
const bool enableFavorites = true;
const bool enableThemeSwitch = true;
const bool enableSort = true;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<CountryProvider>(
          create: (ctx) {
            final provider = CountryProvider();
            Future.microtask(provider.init); // Initialize once after provider is created
            return provider;
          },
        ),
      ],
      child: Consumer<CountryProvider>(
        builder: (context, provider, _) {
          // No need for Builder here, CountryService does not need context for init
          return MaterialApp(
            title: 'Country Explorer',
            debugShowCheckedModeBanner: false,
            themeMode: provider.themeMode,
            theme: ThemeData(
              colorSchemeSeed: Colors.teal,
              brightness: Brightness.light,
              useMaterial3: true,
              fontFamily: 'Poppins',
              cardTheme: const CardThemeData(elevation: 6, shadowColor: Colors.tealAccent),
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: Colors.blueGrey,
              brightness: Brightness.dark,
              useMaterial3: true,
              fontFamily: 'Poppins',
              cardTheme: const CardThemeData(elevation: 8, shadowColor: Colors.blueGrey),
            ),
            // Corrected localization delegates for country_utils
            localizationsDelegates: const [
              CountryLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Explicitly define supported locales based on country_utils source
            supportedLocales: const [
              Locale('en'), Locale('af'), Locale('am'), Locale('ar'), Locale('az'),
              Locale('be'), Locale('bg'), Locale('bn'), Locale('bs'), Locale('ca'),
              Locale('cs'), Locale('da'), Locale('de'), Locale('el'), Locale('es'),
              Locale('et'), Locale('fa'), Locale('fi'), Locale('fr'), Locale('gl'),
              Locale('ha'), Locale('he'), Locale('hi'), Locale('hr'), Locale('hu'),
              Locale('hy'), Locale('id'), Locale('is'), Locale('it'), Locale('ja'),
              Locale('ka'), Locale('kk'), Locale('km'), Locale('ko'), Locale('ku'),
              Locale('ky'), Locale('lt'), Locale('lv'), Locale('mk'), Locale('ml'),
              Locale('mn'), Locale('ms'), Locale('nb'), Locale('nl'), Locale('nn'),
              Locale('no'), Locale('pl'), Locale('ps'), Locale('pt'), Locale('ro'),
              Locale('ru'), Locale('sd'), Locale('sk'), Locale('sl'), Locale('so'),
              Locale('sq'), Locale('sr'), Locale('sv'), Locale('ta'), Locale('tg'),
              Locale('th'), Locale('tr'), Locale('tt'), Locale('ug'), Locale('uk'),
              Locale('ur'), Locale('uz'), Locale('vi'), Locale('zh'),
            ],
            home: const HomeScreen(
              enableSearch: enableSearch,
              enableFavorites: enableFavorites,
              enableSort: enableSort,
              enableThemeSwitch: enableThemeSwitch,
            ),
          );
        },
      ),
    );
  }
}
