import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../constants.dart'; // for kWebImagePrefix

class AppBackground extends StatelessWidget {
  final Widget child;
  final double overlayOpacity;
  final double blurSigma;
  final String? customImagePath;

  const AppBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.5,
    this.blurSigma = 7.0,
    this.customImagePath,
  });

  Widget _buildBackgroundImage() {
    const fallback = 'assets/images/bgimg.jpg';

    if (customImagePath == null || customImagePath!.isEmpty) {
      return Image.asset(fallback, fit: BoxFit.cover);
    }

    if (customImagePath!.startsWith(kWebImagePrefix)) {
      try {
        final bytes = base64Decode(customImagePath!.substring(kWebImagePrefix.length));
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return Image.asset(fallback, fit: BoxFit.cover);
      }
    }

    if (!kIsWeb) {
      return Image.file(File(customImagePath!), fit: BoxFit.cover);
    }

    return Image.asset(fallback, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
              tileMode: TileMode.decal,
            ),
            child: _buildBackgroundImage(),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: const Color(0xFF0A0A0A).withValues(alpha: overlayOpacity),
          ),
        ),
        child,
      ],
    );
  }
}


/// Shared background wrapper — wraps any screen's body content with the
/// same bgimg.jpg background image and a frosted dark overlay used on
/// BizzCardScreen, so every screen looks visually consistent without
/// duplicating the code.
///
/// Uses ImageFiltered (blurs its own child directly) instead of
/// BackdropFilter (which samples an existing rendered layer beneath
/// it). BackdropFilter reliably rendered as solid black on real mobile
/// GPUs in this app's Flutter-web CanvasKit build, even though it
/// worked fine on desktop Chrome and in Chrome's mobile-viewport
/// emulation. ImageFiltered blurs the image widget itself rather than
/// sampling a composited layer, which avoids that backend-specific
/// compositing path entirely.
///
/// Usage:
///   Scaffold(
///     appBar: AppBar(...),
///     body: AppBackground(
///       child: YourScreenContent(),
///     ),
///   )