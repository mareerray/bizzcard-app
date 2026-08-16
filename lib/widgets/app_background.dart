import 'dart:ui';
import 'package:flutter/material.dart';

/// Shared background wrapper — wraps any screen's body content with the
/// same bgimg.jpg background image and a frosted dark overlay used on
/// BizzCardScreen, so every screen looks visually consistent without
/// duplicating the code.
///
/// Unlike a flat high-opacity color layer (which can render as
/// near-solid black on some displays), this uses a real blur
/// (BackdropFilter) plus a lighter tint — the image stays visibly
/// present while text on top stays readable.
///
/// Usage:
///   Scaffold(
///     appBar: AppBar(...),
///     body: AppBackground(
///       child: YourScreenContent(),
///     ),
///   )
class AppBackground extends StatelessWidget {
  final Widget child;
  final double overlayOpacity;
  final double blurSigma;

  const AppBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.55,
    this.blurSigma = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bgimg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A).withValues(alpha: overlayOpacity),
          ),
          child: child,
        ),
      ),
    );
  }
}