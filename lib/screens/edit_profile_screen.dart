import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';

/// Prefix used to mark a stored value as base64-encoded image bytes
/// (only ever produced/consumed on web, where there is no real filesystem).
const String kWebImagePrefix = 'webimg:';

/// Validates that a phone number matches +358 xx xxx xxxx (with or
/// without the spaces) so saved numbers stay consistent regardless
/// of how the user types them.
String? _validatePhone(String? value, String fieldLabel) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return '$fieldLabel is required';
  final digitsOnly = trimmed.replaceAll(RegExp(r'[\s\-]'), '');
  final pattern = RegExp(r'^\+358\d{9}$');
  if (!pattern.hasMatch(digitsOnly)) {
    return 'Use format: +358 44 555 8888';
  }
  return null;
}

/// Normalizes a Finnish phone number to a consistent "+358 xx xxx xxxx"
/// format before saving, regardless of how the user typed it (with or
/// without spaces/dashes).
String _normalizePhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'[\s\-]'), '');
  if (!digits.startsWith('+358') || digits.length != 13) return raw.trim();
  final national = digits.substring(4);
  return '+358 ${national.substring(0, 2)} '
      '${national.substring(2, 5)} ${national.substring(5)}';
}

/// Requires "City, Country" format — a non-empty part before the
/// comma, a non-empty part after it.
String? _validateLocation(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return 'Location is required';
  if (!trimmed.contains(',')) {
    return 'Use format: City, Country';
  }
  final parts = trimmed.split(',');
  final city = parts[0].trim();
  final country = parts.sublist(1).join(',').trim();
  if (city.isEmpty || country.isEmpty) {
    return 'Use format: City, Country';
  }
  return null;
}

String _normalizeLocation(String raw) {
  final trimmed = raw.trim();
  if (!trimmed.contains(',')) return trimmed;
  final parts = trimmed.split(',');
  final city = parts[0].trim();
  final country = parts.sublist(1).join(',').trim();
  return '$city, $country';
}

/// Validates a prefilled URL field (LinkedIn, Website) so the user
/// can't save just the bare prefix (e.g. "https://linkedin.com/in/")
/// with nothing actually added after it.
String? _validateUrlBeyondPrefix(
    String? value, String prefix, String fieldLabel) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return '$fieldLabel is required';
  if (trimmed == prefix || trimmed.length <= prefix.length) {
    return 'Please complete your $fieldLabel';
  }
  return null;
}

/// Basic email format check for the required Email field.
String? _validateEmail(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return 'Email is required';
  final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!pattern.hasMatch(trimmed)) return 'Enter a valid email';
  return null;
}

class EditProfileScreen extends StatefulWidget {
  /// True when shown as the forced first-run setup screen (via AppGate),
  /// rather than opened from the card screen's edit icon. Hides the
  /// back button and calls [onComplete] instead of popping the route.
  final bool isOnboarding;
  final VoidCallback? onComplete;

  const EditProfileScreen({
    super.key,
    this.isOnboarding = false,
    this.onComplete,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _linkedInController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _githubController = TextEditingController();
  final _whatsappController = TextEditingController();

  String? _profileImagePath;
  String? _logoImagePath;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final data = await ProfileService.loadProfile();
      setState(() {
        _nameController.text = data['name'] ?? '';
        _jobTitleController.text = data['jobTitle'] ?? '';
        _companyController.text = data['company'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _locationController.text = data['location'] ?? '';
        _linkedInController.text =
            (data['linkedIn'] == null || data['linkedIn']!.isEmpty)
            ? 'https://linkedin.com/in/'
            : data['linkedIn']!;
        _portfolioController.text =
            (data['portfolio'] == null || data['portfolio']!.isEmpty)
            ? 'https://'
            : data['portfolio']!;
        _githubController.text =
            (data['github'] == null || data['github']!.isEmpty)
            ? 'https://github.com/'
            : data['github']!;
        _whatsappController.text = data['whatsapp'] ?? '';
        _profileImagePath = data['profileImage'];
        _logoImagePath = data['logoImage'];
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage({required bool isProfile}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      if (bytes.length > 900 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please choose an image smaller than ~900 KB.'),
            ),
          );
        }
        return;
      }
      final encoded = kWebImagePrefix + base64Encode(bytes);
      setState(() {
        if (isProfile) {
          _profileImagePath = encoded;
        } else {
          _logoImagePath = encoded;
        }
      });
    } else {
      setState(() {
        if (isProfile) {
          _profileImagePath = picked.path;
        } else {
          _logoImagePath = picked.path;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    await ProfileService.saveProfile(
      name: _nameController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      company: _companyController.text.trim(),
      email: _emailController.text.trim(),
      phone: _normalizePhone(_phoneController.text),
      location: _normalizeLocation(_locationController.text),
      linkedIn: _linkedInController.text.trim(),
      whatsapp: _normalizePhone(_whatsappController.text),
      portfolio: _portfolioController.text.trim(),
      github: _githubController.text.trim(),
      profileImagePath: _profileImagePath,
      logoImagePath: _logoImagePath,
    );

    setState(() => _saving = false);

    if (!mounted) return;

    if (widget.isOnboarding) {
      widget.onComplete?.call();
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedInController.dispose();
    _portfolioController.dispose();
    _githubController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        automaticallyImplyLeading: !widget.isOnboarding,
        title: Text(
          widget.isOnboarding ? 'Complete Your Profile' : 'Edit Profile',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.isOnboarding ? 'Continue' : 'Save',
                    style: GoogleFonts.inter(
                      color: const Color.fromARGB(255, 13, 157, 176),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (widget.isOnboarding) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF62A8B1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF62A8B1),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.qr_code_2,
                      color: Color(0xFF62A8B1),
                      size: 26,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Fill in the required fields below to complete '
                        'your card and generate your QR codes.',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            _ImagePickerRow(
              label: 'Profile Photo',
              imagePath: _profileImagePath,
              fallbackAsset: 'assets/images/profile_image.jpg',
              onTap: () => _pickImage(isProfile: true),
            ),

            const SizedBox(height: 12),

            _ImagePickerRow(
              label: 'Logo / Brand Image',
              imagePath: _logoImagePath,
              fallbackAsset: 'assets/images/logo_image.png',
              onTap: () => _pickImage(isProfile: false),
            ),

            const SizedBox(height: 28),

            _SectionLabel(label: 'Personal Details'),
            const SizedBox(height: 12),
            _Field(
              controller: _nameController,
              label: 'Full Name *',
              icon: Icons.person_outline,
              hintText: 'Firstname Lastname',
              validator: (v) {
                final trimmed = v!.trim();
                if (trimmed.isEmpty) return 'Name is required';
                final nameParts = trimmed
                    .split(' ')
                    .where((s) => s.isNotEmpty)
                    .toList();
                if (nameParts.length < 2) {
                  return 'Please enter first and last name';
                }
                return null;
              },
            ),
            _Field(
              controller: _jobTitleController,
              label: 'Job Title *',
              icon: Icons.work_outline,
              validator: (v) =>
                  v!.trim().isEmpty ? 'Job title is required' : null,
            ),
            _Field(
              controller: _companyController,
              label: 'Company *',
              icon: Icons.business_outlined,
              validator: (v) =>
                  v!.trim().isEmpty ? 'Company is required' : null,
            ),
            _Field(
              controller: _emailController,
              label: 'Email *',
              icon: Icons.email_outlined,
              keyboard: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            _Field(
              controller: _phoneController,
              label: 'Phone *',
              icon: Icons.phone_outlined,
              keyboard: TextInputType.phone,
              hintText: '+358 44 555 8888',
              validator: (v) => _validatePhone(v, 'Phone number'),
            ),
            _Field(
              controller: _locationController,
              label: 'Location *',
              icon: Icons.location_on_outlined,
              hintText: 'City, Country',
              validator: _validateLocation,
            ),

            const SizedBox(height: 28),

            _SectionLabel(label: 'Social Links'),
            const SizedBox(height: 12),
            _Field(
              controller: _linkedInController,
              label: 'LinkedIn URL *',
              icon: Icons.link,
              keyboard: TextInputType.url,
              validator: (v) => _validateUrlBeyondPrefix(
                  v, 'https://linkedin.com/in/', 'LinkedIn URL'),
            ),
            _Field(
              controller: _portfolioController,
              label: 'Your Website *',
              icon: Icons.language,
              keyboard: TextInputType.url,
              validator: (v) =>
                  _validateUrlBeyondPrefix(v, 'https://', 'website URL'),
            ),
            _Field(
              controller: _githubController,
              label: 'GitHub URL',
              icon: Icons.code,
              keyboard: TextInputType.url,
            ),
            _Field(
              controller: _whatsappController,
              label: 'WhatsApp Number *',
              icon: Icons.chat,
              keyboard: TextInputType.phone,
              hintText: '+358 44 555 8888',
              validator: (v) => _validatePhone(v, 'WhatsApp number'),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Reusable image picker row ─────────────────────────────────────────────────

class _ImagePickerRow extends StatelessWidget {
  final String label;
  final String? imagePath;
  final String fallbackAsset;
  final VoidCallback onTap;

  const _ImagePickerRow({
    required this.label,
    required this.imagePath,
    required this.fallbackAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImage(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to change',
                    style: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    const size = 52.0;

    if (imagePath == null || imagePath!.isEmpty) {
      return Image.asset(
        fallbackAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    if (imagePath!.startsWith(kWebImagePrefix)) {
      try {
        final bytes = base64Decode(
          imagePath!.substring(kWebImagePrefix.length),
        );
        return Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      } catch (_) {
        return Image.asset(
          fallbackAsset,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }
    }

    if (imagePath!.startsWith('assets/')) {
      return Image.asset(
        imagePath!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    if (!kIsWeb) {
      return Image.file(
        File(imagePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      fallbackAsset,
      width: size,
      height: size,
      fit: BoxFit.cover,
    );
  }
}

// ── Reusable section label ────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: GoogleFonts.inter(
      color: Colors.white54,
      fontWeight: FontWeight.w600,
      fontSize: 12,
      letterSpacing: .8,
    ),
  );
}

// ── Reusable text field ───────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboard;
  final String? Function(String?)? validator;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.validator,
    this.hintText,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: validator,
        inputFormatters: inputFormatters,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.white24, size: 20),
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF62A8B1), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
      ),
    );
  }
}