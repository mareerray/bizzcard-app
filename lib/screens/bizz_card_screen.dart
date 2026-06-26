import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../services/profile_service.dart';
import 'edit_profile_screen.dart';

class BizzCardScreen extends StatefulWidget {
  const BizzCardScreen({super.key});

  @override
  State<BizzCardScreen> createState() => _BizzCardScreenState();
}

class _BizzCardScreenState extends State<BizzCardScreen> {
  bool _isReady = false;

  // Profile data
  String _name = '';
  String _jobTitle = '';
  String _company = '';
  String _email = '';
  String _phone = '';
  String _location = '';
  String _githubUrl = '';
  String _profileImage = '';
  String _logoImage = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Load profile from ProfileService
  Future<void> _loadProfile() async {
    final data = await ProfileService.loadProfile();
    setState(() {
      _name = data['name'] ?? '';
      _jobTitle = data['jobTitle'] ?? '';
      _company = data['company'] ?? '';
      _email = data['email'] ?? '';
      _phone = data['phone'] ?? '';
      _location = data['location'] ?? '';
      _githubUrl = data['github'] ?? AppConfig.githubUrl;
      _profileImage = data['profileImage'] ?? AppConfig.profileImage;
      _logoImage = data['logoImage'] ?? AppConfig.logoImage;
    });
    await _precacheImages();
  }

  // Precache images for smooth loading
  Future<void> _precacheImages() async {
    final isProfileFile = !_profileImage.startsWith('assets/');
    final isLogoFile = !_logoImage.startsWith('assets/');

    await Future.wait([
      precacheImage(const AssetImage('assets/images/bgimg.jpg'), context),
      if (isProfileFile)
        precacheImage(FileImage(File(_profileImage)), context)
      else
        precacheImage(AssetImage(_profileImage), context),
      if (isLogoFile)
        precacheImage(FileImage(File(_logoImage)), context)
      else
        precacheImage(AssetImage(_logoImage), context),
    ]);

    if (mounted) {
      setState(() => _isReady = true);
    }
  }

  // Helper to build profile or logo image
  ImageProvider _imageProvider(String path) {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0b0a10),
        centerTitle: true,
        toolbarHeight: 60,
        title: Text(
          'BizzCard',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white54),
            tooltip: 'Edit Profile',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EditProfileScreen()),
              );
              if (updated == true) {
                setState(() => _isReady = false);
                _loadProfile();
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '© 2026 Mayuree Reunsati',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () async {
                    final Uri uri = Uri.parse(_githubUrl);
                    if (!await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    )) {
                      throw Exception('Could not launch $uri');
                    }
                  },
                  child: const FaIcon(
                    FontAwesomeIcons.github,
                    color: Colors.white70,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isReady
          ? Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bgimg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF111010).withValues(alpha: 0.8),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // ── Profile + logo images ──────────────
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 220,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: _imageProvider(_profileImage),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: -5,
                                      bottom: -5,
                                      child: Container(
                                        width: 65,
                                        height: 65,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              254, 49, 49, 52),
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: _imageProvider(_logoImage),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // ── Name ──────────────────────────────
                                Text(
                                  _name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 30.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 26.0),

                                // ── Job title ─────────────────────────
                                Text(
                                  _jobTitle,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 18.0),

                                // ── Company ───────────────────────────
                                _InfoRow(
                                    icon: Icons.business_center,
                                    text: _company),
                                const SizedBox(height: 16.0),

                                // ── Email ─────────────────────────────
                                _InfoRow(
                                    icon: Icons.email_outlined,
                                    text: _email),
                                const SizedBox(height: 16.0),

                                // ── Phone ─────────────────────────────
                                _InfoRow(
                                    icon: Icons.phone_outlined,
                                    text: _phone),
                                const SizedBox(height: 16.0),

                                // ── Location ──────────────────────────
                                _InfoRow(
                                    icon: Icons.location_on_outlined,
                                    text: _location),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}

// ── Reusable info row ─────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 20.0),
        const SizedBox(width: 8.0),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 14.0, color: Colors.white),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../config.dart';
// import 'edit_profile_screen.dart';

// class BizzCardScreen extends StatefulWidget {
//   const BizzCardScreen({super.key});

//   @override
//   State<BizzCardScreen> createState() => _BizzCardScreenState();
// }

// class _BizzCardScreenState extends State<BizzCardScreen> {
//   bool _isReady = false;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadImages();
//   }

//   Future<void> _loadImages() async {
//     if (_isReady) return;

//     await Future.wait([
//       precacheImage(const AssetImage('assets/images/bgimg.jpg'), context),
//       precacheImage(
//         const AssetImage('assets/images/MayureeReunsati.jpeg'),
//         context,
//       ),
//       precacheImage(const AssetImage('assets/images/DevMayuree.png'), context),
//     ]);

//     if (mounted) {
//       setState(() {
//         _isReady = true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0b0a10),
//         centerTitle: true,
//         toolbarHeight: 60,
//         title: Text(
//           'BizzCard',
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),

//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit_outlined, color: Colors.white54),
//             tooltip: 'Edit Profile',
//             onPressed: () async {
//               final updated = await Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const EditProfileScreen()),
//               );
//               if (updated == true) {
//                 _loadProfile(); // refresh the card after saving
//               }
//             },
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(20),
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   '© 2026 Mayuree Reunsati',
//                   style: GoogleFonts.poppins(
//                     color: Colors.white70,
//                     fontSize: 11,
//                     height: 1.0,
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 GestureDetector(
//                   onTap: () async {
//                     final Uri uri = Uri.parse(AppConfig.githubUrl);

//                     if (!await launchUrl(
//                       uri,
//                       mode: LaunchMode.externalApplication,
//                     )) {
//                       throw Exception('Could not launch $uri');
//                     }
//                   },
//                   child: const FaIcon(
//                     FontAwesomeIcons.github,
//                     color: Colors.white70,
//                     size: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),

//       body: _isReady
//           ? Container(
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/images/bgimg.jpg'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               child: Container(
//                 width: double.infinity,
//                 height: double.infinity,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF111010).withValues(alpha: 0.8),
//                 ),
//                 child: LayoutBuilder(
//                   builder: (context, constraints) {
//                     return SingleChildScrollView(
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(
//                           minHeight: constraints.maxHeight,
//                         ),
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(20.0),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Stack(
//                                   alignment: Alignment.bottomRight,
//                                   clipBehavior: Clip.none,
//                                   children: [
//                                     Container(
//                                       width: 220,
//                                       height: 220,
//                                       decoration: const BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         image: DecorationImage(
//                                           image: AssetImage(
//                                             AppConfig.profileImage,
//                                           ),
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     ),
//                                     Positioned(
//                                       right: -5,
//                                       bottom: -5,
//                                       child: Container(
//                                         width: 65,
//                                         height: 65,
//                                         decoration: const BoxDecoration(
//                                           color: Color.fromARGB(
//                                             254,
//                                             49,
//                                             49,
//                                             52,
//                                           ),
//                                           shape: BoxShape.circle,
//                                           image: DecorationImage(
//                                             image: AssetImage(
//                                               AppConfig.logoImage,
//                                             ),
//                                             fit: BoxFit.cover,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 20),
//                                 Text(
//                                   AppConfig.name,
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 30.0,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 const SizedBox(height: 26.0),
//                                 Text(
//                                   '"${AppConfig.jobTitle}"',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 18.0,
//                                     color: Colors.white,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 const SizedBox(height: 18.0),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Icon(
//                                       Icons.business_center,
//                                       color: Colors.white,
//                                       size: 20.0,
//                                     ),
//                                     const SizedBox(width: 8.0),
//                                     Text(
//                                       AppConfig.company,
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14.0,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16.0),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Icon(
//                                       Icons.email_outlined,
//                                       color: Colors.white,
//                                       size: 20.0,
//                                     ),
//                                     const SizedBox(width: 8.0),
//                                     Text(
//                                       AppConfig.email,
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14.0,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16.0),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Icon(
//                                       Icons.phone_outlined,
//                                       color: Colors.white,
//                                       size: 20.0,
//                                     ),
//                                     const SizedBox(width: 8.0),
//                                     Text(
//                                       AppConfig.phone,
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14.0,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16.0),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Icon(
//                                       Icons.location_on_outlined,
//                                       color: Colors.white,
//                                       size: 20.0,
//                                     ),
//                                     const SizedBox(width: 8.0),
//                                     Text(
//                                       AppConfig.location,
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14.0,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 20),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             )
//           : const Center(child: CircularProgressIndicator(color: Colors.white)),
//     );
//   }
// }
