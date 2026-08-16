import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Settings', style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
            title: Text('Dark Mode', style: GoogleFonts.inter(color: Colors.white)),
            subtitle: Text(
              'Light theme coming soon',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
            ),
            activeColor: const Color.fromARGB(255, 32, 75, 206),
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined, color: Colors.white70),
            title: Text('Custom Background', style: GoogleFonts.inter(color: Colors.white)),
            subtitle: Text(
              'Coming soon',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
            ),
            enabled: false,
          ),
        ],
      ),
    );
  }
}