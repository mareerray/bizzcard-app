import 'package:flutter/material.dart';

/// Shared background wrapper — wraps any screen's body content with the
/// same bgimg.jpg background image and dark overlay used on BizzCardScreen,
/// so every screen looks visually consistent without duplicating the code.
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

  const AppBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.9,
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
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A).withValues(alpha: overlayOpacity),
        ),
        child: child,
      ),
    );
  }
}
