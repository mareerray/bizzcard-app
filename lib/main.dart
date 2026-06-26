import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(                        
        brightness: Brightness.dark,
        scaffoldBackgroundColor:  Color(0xFF0b0a10),
        colorScheme: ColorScheme.dark(
          surface:  Color(0xFF0b0a10),
        ),
      ),
      home: MainScreen(),
    );
  }
}