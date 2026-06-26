import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers — one for each field
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
  // Image paths
  String? _profileImagePath;
  String? _logoImagePath;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  // Pre-fill the form with saved data
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
        _linkedInController.text = data['linkedIn'] ?? '';
        _portfolioController.text = data['portfolio'] ?? '';
        _githubController.text = data['github'] ?? '';
        _whatsappController.text = data['whatsapp'] ?? '';
        _profileImagePath = data['profileImage'];
        _logoImagePath = data['logoImage'];
        _loading = false;
      });
    } catch (e) {
      // If anything fails, stop loading anyway so screen is not stuck
      if (mounted) setState(() => _loading = false);
    }
  }

  // Pick image from gallery
  Future<void> _pickImage({required bool isProfile}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        if (isProfile) {
          _profileImagePath = picked.path;
        } else {
          _logoImagePath = picked.path;
        }
      });
    }
  }

  // Save and go back
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    await ProfileService.saveProfile(
      name: _nameController.text.trim(),
      jobTitle: _jobTitleController.text.trim(),
      company: _companyController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
      linkedIn: _linkedInController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      portfolio: _portfolioController.text.trim(),
      github: _githubController.text.trim(),
      profileImagePath: _profileImagePath,
      logoImagePath: _logoImagePath,
    );

    setState(() => _saving = false);

    if (mounted) {
      // Return true so the card screen knows to refresh
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    // Always dispose controllers to avoid memory leaks
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
        title: Text('Edit Profile',
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text('Save',
                    style: GoogleFonts.inter(
                        color: const Color.fromARGB(255, 13, 157, 176),
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // ── Profile image picker ──────────────────────────────
            _ImagePickerRow(
              label: 'Profile Photo',
              imagePath: _profileImagePath,
              fallbackAsset: 'assets/images/profile_image.jpg',
              onTap: () => _pickImage(isProfile: true),
            ),

            const SizedBox(height: 12),

            // ── Logo image picker ─────────────────────────────────
            _ImagePickerRow(
              label: 'Logo / Brand Image',
              imagePath: _logoImagePath,
              fallbackAsset: 'assets/images/logo_image.png',
              onTap: () => _pickImage(isProfile: false),
            ),

            const SizedBox(height: 28),

            // ── Personal details ──────────────────────────────────
            _SectionLabel(label: 'Personal Details'),
            const SizedBox(height: 12),
            _Field(controller: _nameController,
                label: 'Full Name', icon: Icons.person_outline,
                validator: (v) => v!.isEmpty ? 'Name is required' : null),
            _Field(controller: _jobTitleController,
                label: 'Job Title', icon: Icons.work_outline),
            _Field(controller: _companyController,
                label: 'Company', icon: Icons.business_outlined),
            _Field(controller: _emailController,
                label: 'Email', icon: Icons.email_outlined,
                keyboard: TextInputType.emailAddress),
            _Field(controller: _phoneController,
                label: 'Phone', icon: Icons.phone_outlined,
                keyboard: TextInputType.phone),
            _Field(controller: _locationController,
                label: 'Location', icon: Icons.location_on_outlined),

            const SizedBox(height: 28),

            // ── Social links ──────────────────────────────────────
            _SectionLabel(label: 'Social Links'),
            const SizedBox(height: 12),
            _Field(controller: _linkedInController,
                label: 'LinkedIn URL', icon: Icons.link,
                keyboard: TextInputType.url),
            _Field(controller: _portfolioController,
                label: 'Portfolio URL', icon: Icons.language,
                keyboard: TextInputType.url),
            _Field(controller: _githubController,
                label: 'GitHub URL', icon: Icons.code,
                keyboard: TextInputType.url),
            _Field(controller: _whatsappController,
                label: 'WhatsApp Number', icon: Icons.chat,
                keyboard: TextInputType.phone),

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
    final isFile = imagePath != null && !imagePath!.startsWith('assets/');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isFile
                ? Image.file(File(imagePath!),
                    width: 52, height: 52, fit: BoxFit.cover)
                : Image.asset(fallbackAsset,
                    width: 52, height: 52, fit: BoxFit.cover),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text('Tap to change',
                  style: GoogleFonts.inter(
                      color: Colors.white38, fontSize: 12)),
            ]),
          ),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ]),
      ),
    );
  }
}

// ── Reusable section label ────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: GoogleFonts.inter(
          color: Colors.white54,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: .8));
}

// ── Reusable text field ───────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboard;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: validator,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: Colors.white38),
          prefixIcon: Icon(icon, color: Colors.white24, size: 20),
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