import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/qr_items.dart';
import '../route_observer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    refreshSignal.value++;
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      debugPrint('MainScreen: bumping refreshSignal, value will be ${refreshSignal.value + 1}');
      refreshSignal.value++; // Card tab became active — refresh it
    }
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
    if (index == 0) {
      refreshSignal.value++;
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _pageController.dispose();
    super.dispose();
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
        selectedItemColor: const Color.fromARGB(255, 32, 133, 206),
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