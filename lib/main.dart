import 'package:flutter/material.dart';
import 'app_gate.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: ColorScheme.dark(
          surface: const Color(0xFF0A0A0A),
        ),
      ),
      navigatorObservers: [routeObserver],
      home: const AppGate(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'screens/main_screen.dart';

// void main() {
//   runApp( MyApp());
// }

// class MyApp extends StatelessWidget {
//   MyApp({super.key});

//   final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(                        
//         brightness: Brightness.dark,
//         scaffoldBackgroundColor:  Color(0xFF0A0A0A),
//         colorScheme: ColorScheme.dark(
//           surface:  Color(0xFF0A0A0A),
//         ),
//       ),
//       navigatorObservers: [routeObserver],
//       home: MainScreen(),
//     );
//   }
// }