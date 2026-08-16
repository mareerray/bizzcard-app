import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BizzAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const BizzAppBar({super.key, this.title = 'BizzCard', this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A0A),
      toolbarHeight: 60,
      centerTitle: false,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
    );
  }
}