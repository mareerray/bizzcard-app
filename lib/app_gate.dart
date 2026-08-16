import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/main_screen.dart';

/// Decides which screen to show at app startup:
/// - EditProfileScreen, if required fields (name, phone, LinkedIn,
///   WhatsApp, portfolio) are missing — since those are needed to
///   generate the QR codes and populate the card.
/// - MainScreen (the bottom-nav Card/LinkedIn/CV/Portfolio/WhatsApp
///   flow), once setup is complete.
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _checking = true;
  bool _setupComplete = false;

  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    final complete = await ProfileService.hasCompletedRequiredSetup();
    if (!mounted) return;
    setState(() {
      _setupComplete = complete;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (!_setupComplete) {
      return EditProfileScreen(
        isOnboarding: true,
        onComplete: () {
          setState(() => _setupComplete = true);
        },
      );
    }

    return const MainScreen();
  }
}
