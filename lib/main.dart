import 'dart:js' as js;
import 'package:easy_localization/easy_localization.dart';
import 'package:edc_studio/routes.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

String getEnvVar(String key) {
  final env = js.context['env'];
  if (env == null) return '';
  return env[key] ?? '';
}

Future<void> main() async {
  final endpointBase = getEnvVar('ENDPOINT_BASE');
  final endpointDataPond = getEnvVar('ENDPOINT_DATA_POND');

  print('Base endpoint: $endpointBase');
  print('Data pond: $endpointDataPond');

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


