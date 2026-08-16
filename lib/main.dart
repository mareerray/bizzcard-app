import 'package:flutter/material.dart';
import 'app_gate.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: ColorScheme.dark(
          surface: const Color(0xFF0A0A0A),
        ),
      ),
      home: FutureBuilder<bool>(
        future: WelcomeScreen.hasSeenWelcome(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              backgroundColor: Color(0xFF0A0A0A),
              body: Center(child: CircularProgressIndicator(color: Colors.white)),
            );
          }
          return snapshot.data! ? const AppGate() : const WelcomeScreen();
        },
      ),
    );
  }
}
