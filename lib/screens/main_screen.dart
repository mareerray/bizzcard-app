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
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: buildAppPages(_currentIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        backgroundColor: const Color(0xFF0A0A0A),
        selectedItemColor: const Color.fromARGB(255, 32, 75, 206),
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Card'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.linkedin), label: 'LinkedIn'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(Icons.web_outlined), label: 'Website'),
          BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.whatsapp), label: 'WhatsApp'),
        ],
      ),
    );
  }
}