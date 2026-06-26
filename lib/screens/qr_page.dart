import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../services/profile_service.dart';

class QrPage extends StatefulWidget {
  final String title;
  final String description;
  final Widget icon;
  final String profileKey;
  final String? message;
  final bool showSendCV;
  final bool showShareLink;
  final bool isVisible;

  const QrPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.profileKey,
    this.message,
    this.showSendCV = false,
    this.showShareLink = false,
    this.isVisible = false,
  });

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  String _value = '';
  bool _loading = true;
  Map<String, String> _profile = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(QrPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final data = await ProfileService.loadProfile();
    if (!mounted) return;
    setState(() {
      _profile = data;
      _value = data[widget.profileKey] ?? '';
      _loading = false;
    });
  }

  String get _qrData {
    if (widget.profileKey == 'whatsapp') {
      final phone = _value.replaceAll('+', '').replaceAll(' ', '');
      return 'https://wa.me/$phone';
    }
    return _value;
  }

  Future<void> _openLink() async {
    if (_value.isEmpty) return;
    final uri = Uri.parse(_value);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _shareLink() async {
    if (_value.isEmpty) return;
    await SharePlus.instance.share(
      ShareParams(
        text: _value,
        subject: widget.title,
      ),
    );
  }

  Future<void> _sendCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(result.files.single.path!)],
        subject: 'CV - ${_profile['name'] ?? ''}',
        text: 'Please find my CV attached.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCvPage = widget.showSendCV;

    return Scaffold(
      backgroundColor: const Color(0xFF0b0a10),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0b0a10),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFF0b0a10),
        child: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconTheme(
                        data: const IconThemeData(
                          color: Colors.white54,
                          size: 40,
                        ),
                        child: widget.icon,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      if (isCvPage) ...[
                        Text(
                          'Attach your CV to share \n by email or messaging apps.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PDF format recommended.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: _sendCV,
                          icon: const Icon(Icons.send),
                          label: const Text('Send CV'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ] else ...[
                      if (_value.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.white,
                          child: QrImageView(
                            data: _qrData,
                            version: QrVersions.auto,
                            size: 260,
                          ),
                        )
                      else
                        Text(
                          'No ${widget.title} link set.\nGo to Edit Profile to add one.',
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (_value.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Text(
                          _value,
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
                            if (widget.showShareLink) ...[
                              const SizedBox(width: 12),
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
                      if (widget.message != null) ...[
                        const SizedBox(height: 15),
                        Text(
                          widget.message!,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (widget.showSendCV) ...[
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: _sendCV,
                          icon: const Icon(Icons.send),
                          label: const Text('Send CV'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}


