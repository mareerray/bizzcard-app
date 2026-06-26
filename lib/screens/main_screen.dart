import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/qr_items.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: buildAppPages(_currentIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF0b0a10),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Card',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.linkedin),
            label: 'LinkedIn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'CV',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.web_outlined),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.whatsapp),
            label: 'WhatsApp',
          ),
        ],
      ),
    );
  }
}