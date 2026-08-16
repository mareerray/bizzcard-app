import 'dart:ui';
import 'package:flutter/material.dart';

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
class AppBackground extends StatelessWidget {
  final Widget child;
  final double overlayOpacity;
  final double blurSigma;

  const AppBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.5,
    this.blurSigma = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blur applied directly to the image widget — not to a
        // composited backdrop layer.
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
              tileMode: TileMode.decal,
            ),
            child: Image.asset(
              'assets/images/bgimg.jpg',
              fit: BoxFit.cover,
            ),
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


// import 'package:flutter/material.dart';

// /// Shared background wrapper — wraps any screen's body content with the
// /// same bgimg.jpg background image and a dark tint overlay used on
// /// BizzCardScreen, so every screen looks visually consistent without
// /// duplicating the code.
// ///
// /// IMPORTANT: this intentionally does NOT use BackdropFilter/blur.
// /// Real mobile GPUs (tested: real Android phone + tablet, both Chrome)
// /// render BackdropFilter as solid black in this app's Flutter-web
// /// CanvasKit build, even though it renders correctly on desktop Chrome
// /// and in Chrome's mobile-viewport emulation (which still uses the
// /// desktop rendering backend, not a real mobile GPU — so it doesn't
// /// catch this class of bug).
// ///
// /// If you want a "frosted glass" look, bake the blur into bgimg.jpg
// /// itself (e.g. in Photoshop/GIMP/an online blur tool) and use the
// /// pre-blurred image here — that's a flat image, so it's immune to
// /// this rendering issue entirely.
// ///
// /// Usage:
// ///   Scaffold(
// ///     appBar: AppBar(...),
// ///     body: AppBackground(
// ///       child: YourScreenContent(),
// ///     ),
// ///   )
// class AppBackground extends StatelessWidget {
//   final Widget child;
//   final double overlayOpacity;

//   const AppBackground({
//     super.key,
//     required this.child,
//     this.overlayOpacity = 0.7,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         Positioned.fill(
//           child: Image.asset(
//             'assets/images/bgimg.jpg',
//             fit: BoxFit.cover,
//           ),
//         ),
//         Positioned.fill(
//           child: Container(
//             color: const Color(0xFF0A0A0A).withValues(alpha: overlayOpacity),
//           ),
//         ),
//         child,
//       ],
//     );
//   }
// }


