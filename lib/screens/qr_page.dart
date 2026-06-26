import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../services/profile_service.dart';

// Shared palette for QR screens — UI layer only.
const _kAccent = Color(0xFF077281);
const _kQrModule = Color(0xFF1E293B);
const _kSurface = Color(0xFF16151C);

/// Formats a phone number for display.
/// Finland (+358): +358 44 555 8888  (+xxx xx xxx xxxx)
String _formatPhoneDisplay(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return raw.trim();

  if (digits.startsWith('358')) {
    final national = digits.substring(3);
    if (national.length >= 9) {
      return '+358 ${national.substring(0, 2)} '
          '${national.substring(2, 5)} ${national.substring(5, 9)}';
    }
    return national.isEmpty ? '+358' : '+358 $national';
  }

  if (digits.startsWith('1') && digits.length >= 11) {
    final national = digits.substring(1);
    return '+1 ${national.substring(0, 3)} '
        '${national.substring(3, 6)} ${national.substring(6)}';
  }

  final ccLength = digits.length > 10 ? digits.length - 10 : 2;
  final country = digits.substring(0, ccLength);
  final national = digits.substring(ccLength);
  if (national.isEmpty) return '+$country';

  final buffer = StringBuffer('+$country ');
  for (var i = 0; i < national.length; i += 3) {
    if (i > 0) buffer.write(' ');
    buffer.write(national.substring(i, (i + 3).clamp(0, national.length)));
  }
  return buffer.toString().trim();
}

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
      final phone = _value.replaceAll(RegExp(r'\D'), '');
      return 'https://wa.me/$phone';
    }
    return _value;
  }

  String get _displayValue {
    if (widget.profileKey == 'whatsapp') {
      return _formatPhoneDisplay(_value);
    }
    return _value;
  }

  Future<void> _openLink() async {
    if (_value.isEmpty) return;
    final uri = widget.profileKey == 'whatsapp'
        ? Uri.parse(_qrData)
        : Uri.parse(_value);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _shareLink() async {
    if (_value.isEmpty) return;
    await SharePlus.instance.share(
      ShareParams(
        text: widget.profileKey == 'whatsapp' ? _displayValue : _value,
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


  Widget _buildStyledQrCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          // color: _kAccent.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            // color: _kAccent.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: QrImageView(
        data: _qrData,
        version: QrVersions.auto,
        size: 232,
        padding: const EdgeInsets.all(4),
        backgroundColor: Colors.white,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.circle,
          color: _kQrModule,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.circle,
          color: _kQrModule,
        ),
        embeddedImageStyle: const QrEmbeddedImageStyle(
          size: Size(44, 44),
        ),
      ),
    );
  }

  ButtonStyle get _actionButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: _kAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

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
                          color: _kAccent,
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
                          style: _actionButtonStyle,
                        ),
                      ] else ...[
                      if (_value.isNotEmpty)
                        _buildStyledQrCard()
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
                        const SizedBox(height: 20),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _kSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            _displayValue,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _openLink,
                              style: _actionButtonStyle,
                              child: const Text('Open Link'),
                            ),
                            if (widget.showShareLink) ...[
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _shareLink,
                                icon: const Icon(Icons.share),
                                label: const Text('Share Link'),
                                style: _actionButtonStyle,
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
                          style: _actionButtonStyle,
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


