import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../config.dart';

class QrPage extends StatelessWidget {
  final String title;
  final String description;
  final String? imagePath;
  final Widget icon;
  final String? url;
  final String? message;
  final bool showSendCV;
  final bool showShareLink;

  const QrPage({
    super.key,
    required this.title,
    required this.description,
    this.imagePath,
    required this.icon,
    this.url,
    this.message,
    this.showSendCV = false,
    this.showShareLink = false,
  });

  Future<void> _openLink() async {
    if (url == null) return;

    final Uri uri = Uri.parse(url!);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _shareLink() async {
    if (url == null) return;
    await SharePlus.instance.share(
      ShareParams(
        text: url!,
        subject: title,
      ),
    );
  }

  Future<void> _sendCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return; // user cancelled

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(result.files.single.path!)],
        subject: 'CV - ${AppConfig.name}',
        text: 'Please find my CV attached.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0b0a10),
      ),

      body: Container(
        decoration: const BoxDecoration(
          color:Color(0xFF0b0a10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTheme(
                data: const IconThemeData(
                  color: Colors.white54,
                  size: 40,
                ),
                child: icon,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                child: Image.asset(
                  imagePath ?? 'assets/images/logo_image.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
                if (url != null) ...[
                  const SizedBox(height: 15),
                  Text(
                    url!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _openLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Open Link'),
                      ),
                      if (showShareLink) ...[
                        const SizedBox(width: 12),   // 👈 gap between buttons
                        ElevatedButton.icon(
                          onPressed: _shareLink,
                          icon: const Icon(Icons.share),
                          label: const Text('Share Link'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],              
                if (message != null) ...[
                const SizedBox(height: 15),
                Text(
                  message!,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (showSendCV) ...[
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () => _sendCV(),
                  icon: const Icon(Icons.send),
                  label: const Text('Send CV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}