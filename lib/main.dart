import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/routes.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

const endpointBase = String.fromEnvironment('ENDPOINT_BASE');
const endpointDataPond = String.fromEnvironment('ENDPOINT_DATA_POND');

Future<void> main() async {
  if (endpointBase.isEmpty || endpointDataPond.isEmpty) {
    throw Exception(
        'Faltan las variables ENDPOINT_BASE o ENDPOINT_DATA_POND. '
        'Debes definirlas con --dart-define al construir o ejecutar.');
  }
  
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  setPathUrlStrategy();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es'), Locale('ca')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EDC Studio',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF003366),     
          onPrimary: Colors.white,
          secondary: Color(0xFF666666), 
          onSecondary: Colors.white,
          tertiary: Color(0xFFF5F5F5),  
          onTertiary: Colors.black,
          surface: Color(0xFFFFFFFF),
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: Color(0xFFFFFFFF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003366),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003366),
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF003366),
        ),
      ),
    );
  }
}


