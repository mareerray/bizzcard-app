import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';
import '../constants.dart'; // for kWebImagePrefix

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  String? _backgroundPath;
  bool _pickingBackground = false;

  @override
  void initState() {
    super.initState();
    _loadBackground();
  }

  Future<void> _loadBackground() async {
    final path = await ProfileService.loadCustomBackground();
    if (mounted) setState(() => _backgroundPath = path);
  }

  Future<void> _pickBackground() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _pickingBackground = true);

    try {
      String saved;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        if (bytes.length > 900 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please choose an image smaller than ~900 KB.'),
              ),
            );
          }
          return;
        }
        saved = kWebImagePrefix + base64Encode(bytes);
      } else {
        saved = picked.path;
      }
      await ProfileService.saveCustomBackground(saved);
      if (mounted) setState(() => _backgroundPath = saved);
    } finally {
      if (mounted) setState(() => _pickingBackground = false);
    }
  }

  Future<void> _resetBackground() async {
    await ProfileService.saveCustomBackground(null);
    setState(() => _backgroundPath = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
            title: Text(
              'Dark Mode',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            subtitle: Text(
              'Light theme coming soon',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
            ),
            activeColor: const Color.fromARGB(255, 32, 133, 206),
          ),
          // ── Custom Background Picker ─────────────────────────────────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.image_outlined, color: Colors.white70),
            title: Text(
              'Pick Custom Background',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            subtitle: Text(
              _backgroundPath != null
                  ? 'Custom background set'
                  : 'Using default background',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
            ),
            onTap: _pickingBackground ? null : _pickBackground,
            trailing: _pickingBackground
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                )
                : (_backgroundPath != null
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white70),
                      onPressed: _resetBackground,
                    )
                  : null),
          ),

          // subtitle: Text(
          //   'Coming soon',
          //   style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
          // ),
          // enabled: false,
        ],
      ),
    );
  }
}
