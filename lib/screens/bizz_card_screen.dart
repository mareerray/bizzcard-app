import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config.dart';
import '../services/profile_service.dart';
import '../widgets/app_background.dart';
import '../widgets/bizz_app_bar.dart';
import '../widgets/bizz_drawer.dart';
import '../constants.dart'; // for kWebImagePrefix
import 'edit_profile_screen.dart' show EditProfileScreen;

// Route observer for detecting when this screen becomes visible again
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class BizzCardScreen extends StatefulWidget {
  const BizzCardScreen({super.key});

  @override
  State<BizzCardScreen> createState() => _BizzCardScreenState();
}

class _BizzCardScreenState extends State<BizzCardScreen> with RouteAware {
  bool _isReady = false;

  // Profile data
  String _name = '';
  String _jobTitle = '';
  String _company = '';
  String _email = '';
  String _phone = '';
  String _location = '';
  String _profileImage = '';
  String _logoImage = '';
  String? _backgroundPath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Load profile from ProfileService
  Future<void> _loadProfile() async {
    final data = await ProfileService.loadProfile();
    final background = await ProfileService.loadCustomBackground();
    if (!mounted) return;

    setState(() {
      _isReady = false;
      _name = data['name'] ?? '';
      _jobTitle = data['jobTitle'] ?? '';
      _company = data['company'] ?? '';
      _email = data['email'] ?? '';
      _phone = data['phone'] ?? '';
      _location = data['location'] ?? '';
      _profileImage = data['profileImage'] ?? AppConfig.profileImage;
      _logoImage = data['logoImage'] ?? AppConfig.logoImage;
      _backgroundPath = background;
    });
    await _precacheImages();
  }

  // Returns true only for a real native file path that precacheImage
  // can safely open via File(). Web-encoded and asset paths are excluded.
  bool _isNativeFilePath(String path) {
    if (kIsWeb) return false;
    if (path.startsWith('assets/')) return false;
    if (path.startsWith(kWebImagePrefix)) return false;
    return true;
  }

  // Precache images for smooth loading
  Future<void> _precacheImages() async {
    final futures = <Future<void>>[];

    if (_backgroundPath != null && _isNativeFilePath(_backgroundPath!)) {
      futures.add(precacheImage(FileImage(File(_backgroundPath!)), context));
    } else if (_backgroundPath == null) {
      futures.add(precacheImage(const AssetImage('assets/images/bgimg.jpg'), context));
    }
    // webimg: custom backgrounds are already in memory — no precache needed.

    if (_isNativeFilePath(_profileImage)) {
      futures.add(precacheImage(FileImage(File(_profileImage)), context));
    } else if (_profileImage.startsWith('assets/')) {
      futures.add(precacheImage(AssetImage(_profileImage), context));
    }

    if (_isNativeFilePath(_logoImage)) {
      futures.add(precacheImage(FileImage(File(_logoImage)), context));
    } else if (_logoImage.startsWith('assets/')) {
      futures.add(precacheImage(AssetImage(_logoImage), context));
    }

    try {
      await Future.wait(futures);
    } catch (_) {}

    if (mounted) setState(() => _isReady = true);
  }

  // Helper to build profile or logo image — handles asset paths, native
  // file paths, and web base64-encoded ("webimg:") strings.
  ImageProvider _imageProvider(String path) {
    if (path.isEmpty) {
      return const AssetImage('assets/images/profile_image.jpg');
    }

    if (path.startsWith(kWebImagePrefix)) {
      try {
        final bytes = base64Decode(path.substring(kWebImagePrefix.length));
        return MemoryImage(bytes);
      } catch (_) {
        return const AssetImage('assets/images/profile_image.jpg');
      }
    }

    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }

    if (!kIsWeb) {
      return FileImage(File(path));
    }

    // Web fallback safety net — should not normally be reached.
    return const AssetImage('assets/images/profile_image.jpg');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    _loadProfile();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const BizzDrawer(),
      // ── AppBar ─────────────────────────────────────────────────────────────────────
      appBar: BizzAppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white54),
              tooltip: 'Edit Profile',
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
                if (updated == true) {
                  await _loadProfile();
                }
              },
            ),
          ],
        ),      
      // ── Body ──────────────────────────────────────────────────────────────────────
      body: _isReady
          ? AppBackground(
            customImagePath: _backgroundPath,
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
                                          254,
                                          49,
                                          49,
                                          52,
                                        ),
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
                                '"$_jobTitle"',
                                style: GoogleFonts.poppins(
                                  fontSize: 18.0,
                                  color: Colors.white70,
                                  // color: const Color.fromARGB(255, 32, 75, 206),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18.0),

                              // ── Company ───────────────────────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.business_center,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _company,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18.0),
                              // _InfoRow(
                              //     icon: Icons.business_center,
                              //     text: _company),
                              // const SizedBox(height: 16.0),

                              // ── Email ─────────────────────────────
                              _InfoRow(
                                icon: Icons.email_outlined,
                                text: _email,
                              ),
                              const SizedBox(height: 16.0),

                              // ── Phone ─────────────────────────────
                              _InfoRow(
                                icon: Icons.phone_outlined,
                                text: _phone,
                              ),
                              const SizedBox(height: 16.0),

                              // ── Location ──────────────────────────
                              _InfoRow(
                                icon: Icons.location_on_outlined,
                                text: _location,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
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
