import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/bizz_card_screen.dart';
import '../screens/qr_page.dart';
import '../models/skill.dart';

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
    title: 'Portfolio',
    description: 'My skills and tech stack.',
    icon: const Icon(Icons.description_outlined),
    // message: 'CV available on request.',
    profileKey: 'CV',
    showSendCV: true,
    skills: const [
      Skill(name: 'Flutter', category: 'Frontend'),
      Skill(name: 'Dart', category: 'Frontend'),
      Skill(name: 'React', category: 'Frontend'),
      Skill(name: 'TypeScript', category: 'Frontend'),
      Skill(name: 'Angular', category: 'Frontend'),
      Skill(name: 'Java', category: 'Backend'),
      Skill(name: 'Go', category: 'Backend'),
      Skill(name: 'REST APIs', category: 'Backend'),
      Skill(name: 'Supabase', category: 'Database'),
      Skill(name: 'MongoDB', category: 'Database'),
      Skill(name: 'Firebase', category: 'Database'),
      Skill(name: 'Vercel', category: 'Platform'),
      Skill(name: 'Git', category: 'Platform'),
    ],
    isVisible: currentIndex == 2,
  ),
  QrPage(
    title: 'Website',
    description: 'Scan to visit my website',
    icon: const Icon(Icons.web_outlined),
    profileKey: 'website',
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
