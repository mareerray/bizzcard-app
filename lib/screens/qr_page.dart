import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../services/profile_service.dart';
import '../widgets/app_background.dart';
import '../widgets/bizz_app_bar.dart';
import '../widgets/bizz_drawer.dart';
import '../widgets/skills_editor_dialog.dart';
import '../models/skill.dart';
import '../constants.dart'; // for kWebImagePrefix

// Shared palette for QR screens — UI layer only.
const _kAccent = Color.fromARGB(255, 32, 133, 206);
const _kQrModule = Color(0xFF1E293B);
const _kSurface = Color(0xFF0A0A0A);
const _kSnackBg = Color(0xFF1E1E1E);

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

/// Shows a themed snackbar consistent with BizzCard's dark UI —
/// dark surface, accent-colored leading icon, rounded floating shape.
void _showThemedSnackBar(
  BuildContext context,
  String message, {
  IconData icon = Icons.info_outline,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: _kSnackBg,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Colors.white12),
        ),
        duration: const Duration(seconds: 12),
        content: Row(
          children: [
            Icon(icon, color: _kAccent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}

class QrPage extends StatefulWidget {
  final String title;
  final String description;
  final Widget icon;
  final String profileKey;
  final String? message;
  final List<Skill>? skills;
  final bool showPortfolio;
  final bool showShareLink;
  final bool isVisible;

  const QrPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.profileKey,
    this.message,
    this.skills,
    this.showPortfolio = false,
    this.showShareLink = false,
    this.isVisible = false,
  });

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  String _value = '';
  bool _loading = true;
  bool _sendingCv = false;
  Map<String, String> _profile = {};
  List<Skill> _skills = [];
  String? _backgroundPath;

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
    final skills = await ProfileService.loadSkills();
    final background = await ProfileService.loadCustomBackground();
    if (!mounted) return;
    setState(() {
      _profile = data;
      _value = data[widget.profileKey] ?? '';
      _skills = skills;
      _backgroundPath = background;
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

  Future<void> _openSkillsEditor() async {
    final result = await showDialog<List<Skill>>(
      context: context,
      builder: (_) => SkillsEditorDialog(initialSkills: _skills),
    );
    if (result == null) return;
    setState(() => _skills = result);
    await ProfileService.saveSkills(result);
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

  // Send CV — branches by platform. On web, file_picker never returns a
  // real path, so an XFile must be built from bytes; and since browsers
  // cannot attach local files to an email programmatically (no mailto
  // attachment support), the flow downloads the PDF then opens a
  // pre-filled email draft so the user only needs to attach it manually.
  Future<void> _sendCV() async {
    if (_sendingCv) return;
    setState(() => _sendingCv = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb,
      );
      if (result == null) return;
      final picked = result.files.single;

      if (kIsWeb) {
        // Browsers cannot attach a local file to mailto: links (RFC 6068) —
        // skip the share/download fallback and just open a pre-filled draft.
        final subject = Uri.encodeComponent('CV - ${_profile['name'] ?? ''}');
        final body = Uri.encodeComponent(
          'Hi,\n\nPlease find my CV attached.\n\nBest regards,\n${_profile['name'] ?? ''}',
        );
        final mailto = Uri.parse('mailto:?subject=$subject&body=$body');

        if (mounted) {
          _showThemedSnackBar(
            context,
            'Email draft opened. Please attach "${picked.name}" from your files manually.',
            icon: Icons.attach_email_outlined,
          );
        }
        await launchUrl(mailto);
      } else {
        final path = picked.path;
        if (path == null) return;
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(path)],
            subject: 'CV - ${_profile['name'] ?? ''}',
            text: 'Please find my CV attached.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingCv = false);
    }
  }

  Widget _buildStyledQrCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(width: 1.5),
        boxShadow: [BoxShadow(blurRadius: 28, offset: const Offset(0, 10))],
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
        embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(44, 44)),
      ),
    );
  }

  ButtonStyle get _actionButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: _kAccent,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static const _categoryOrder = [
    'Frontend',
    'Backend',
    'Database',
    'Platform',
    'Mobile',
    'Other',
  ];

  Map<String, List<Skill>> _groupByCategory(List<Skill> skills) {
    final grouped = <String, List<Skill>>{};
    for (final skill in skills) {
      grouped.putIfAbsent(skill.category, () => []).add(skill);
    }
    return grouped;
  }

  Widget _buildSkillsSection(List<Skill> skills) {
    final grouped = _groupByCategory(skills);
    final orderedCategories = _categoryOrder.where(grouped.containsKey).toList()
      ..addAll(grouped.keys.where((c) => !_categoryOrder.contains(c)));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: orderedCategories.map((category) {
          final items = grouped[category]!;
          final isLast = category == orderedCategories.last;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _kAccent,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        skill.name,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sendCvButton() {
    return ElevatedButton.icon(
      onPressed: _sendingCv ? null : _sendCV,
      icon: _sendingCv
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.send),
      label: Text(_sendingCv ? 'Preparing...' : 'Send CV'),
      style: _actionButtonStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortfolioPage = widget.showPortfolio;

    return Scaffold(
      drawer: const BizzDrawer(),
      // ── AppBar ─────────────────────────────────────────────────────────────────────
      appBar: BizzAppBar(
        actions: [
          if (isPortfolioPage)
            TextButton.icon(
              onPressed: _openSkillsEditor,
              icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.white54),
              label: Text(
                'Skills',
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      // ── Body ───────────────────────────────────────────────────────────────────────
      body: AppBackground(
        customImagePath: _backgroundPath,
        child: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconTheme(
                        data: const IconThemeData(color: _kAccent, size: 40),
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

                      if (isPortfolioPage) ...[
                        if (_skills.isNotEmpty) ...[
                          _buildSkillsSection(_skills),
                          const SizedBox(height: 24),
                        ],
                        Text(
                          'Share CV by email or messaging apps.',
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
                        _sendCvButton(),
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
                        if (widget.showPortfolio) ...[
                          const SizedBox(height: 15),
                          _sendCvButton(),
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
