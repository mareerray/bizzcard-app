import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/bizz_card_screen.dart';
import '../screens/qr_page.dart';

List<Widget> buildAppPages(int currentIndex) => [
  const BizzCardScreen(),
  QrPage(
    title: 'LinkedIn',
    description: 'Scan to view my LinkedIn profile',
    icon: const FaIcon(FontAwesomeIcons.linkedin),
    profileKey: 'linkedIn',
    isVisible: currentIndex == 1,
  ),
  QrPage(
    title: 'My CV',
    description: 'My CV is shared privately.',
    icon: const Icon(Icons.description_outlined),
    message: 'CV available on request.',
    profileKey: 'cv',
    showSendCV: true,
    isVisible: currentIndex == 2,
  ),
  QrPage(
    title: 'Portfolio',
    description: 'Scan to visit my portfolio',
    icon: const Icon(Icons.web_outlined),
    profileKey: 'portfolio',
    showShareLink: true,
    isVisible: currentIndex == 3,
  ),
  QrPage(
    title: 'WhatsApp',
    description: 'Scan to add me on WhatsApp',
    icon: const FaIcon(FontAwesomeIcons.whatsapp),
    profileKey: 'whatsapp',
    isVisible: currentIndex == 4,
  ),
];
