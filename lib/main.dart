import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/weather_provider.dart';
import 'views/home_screen.dart';
import 'views/search_screen.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: MaterialApp(
        title: 'WeatherNow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A90D9),
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/search': (context) => const SearchScreen(),
        },
      ),
    );
  }
}