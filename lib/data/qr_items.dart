import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/bizz_card_screen.dart';
import '../screens/qr_page.dart';
import '../config.dart';

final List<Widget> appPages = [
  const BizzCardScreen(),
  const QrPage(
    title: 'LinkedIn',
    description: 'Scan to view my LinkedIn profile',
    imagePath: AppConfig.qrImage,
    icon: FaIcon(FontAwesomeIcons.linkedin),
    showSendCV: false,       
    showShareLink: false, 
  ),
  const QrPage(
    title: 'My CV',
    description: 'My CV is shared privately.',
    imagePath: AppConfig.logoImage,
    icon: Icon(Icons.description_outlined),
    message: 'CV available on request.',
    showSendCV: true,
    showShareLink: false,
  ),  
  const QrPage(
    title: 'Portfolio',
    description: 'Scan to visit my portfolio',
    imagePath: AppConfig.qrImage,
    icon: Icon(Icons.web_outlined),
    url: AppConfig.portfolioUrl,
    showSendCV: false,
    showShareLink: true,
  ),
  const QrPage(
    title: 'WhatsApp',
    description: 'Scan to add me on WhatsApp',
    imagePath: AppConfig.qrImage,
    icon: FaIcon(FontAwesomeIcons.whatsapp),
    showSendCV: false,
    showShareLink: false,
  ),
];