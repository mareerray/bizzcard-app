import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ProfileService {
  // Keys for storing each field
  static const _name = 'profile_name';
  static const _jobTitle = 'profile_job_title';
  static const _company = 'profile_company';
  static const _email = 'profile_email';
  static const _phone = 'profile_phone';
  static const _location = 'profile_location';
  static const _linkedIn = 'profile_linkedin';
  static const _website = 'profile_website';
  static const _github = 'profile_github';
  static const _whatsapp = 'profile_whatsapp';
  static const _profileImage = 'profile_image_path';
  static const _logoImage = 'profile_logo_path';

  // Fields that MUST be filled in before the main card screen is shown.
  // Used by hasCompletedRequiredSetup() to gate first-run access via
  // AppGate. Only GitHub stays optional — everything else is required
  // so the card never looks sparse.
  static const List<String> requiredFields = [
    'name',
    'jobTitle',
    'company',
    'email',
    'phone',
    'location',
    'linkedIn',
    'whatsapp',
    'website',
  ];

  // Save all profile fields at once
  static Future<void> saveProfile({
    required String name,
    required String jobTitle,
    required String company,
    required String email,
    required String phone,
    required String location,
    required String linkedIn,
    required String whatsapp,
    required String website,
    required String github,
    String? profileImagePath,
    String? logoImagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_name, name);
    await prefs.setString(_jobTitle, jobTitle);
    await prefs.setString(_company, company);
    await prefs.setString(_email, email);
    await prefs.setString(_phone, phone);
    await prefs.setString(_location, location);
    await prefs.setString(_linkedIn, linkedIn);
    await prefs.setString(_whatsapp, whatsapp);
    await prefs.setString(_website, website);
    await prefs.setString(_github, github);
    if (profileImagePath != null) {
      await prefs.setString(_profileImage, profileImagePath);
    }
    if (logoImagePath != null) {
      await prefs.setString(_logoImage, logoImagePath);
    }
  }

  // Load all profile fields at once
  static Future<Map<String, String>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_name) ?? AppConfig.name,
      'jobTitle': prefs.getString(_jobTitle) ?? AppConfig.jobTitle,
      'company': prefs.getString(_company) ?? AppConfig.company,
      'email': prefs.getString(_email) ?? AppConfig.email,
      'phone': prefs.getString(_phone) ?? AppConfig.phone,
      'location': prefs.getString(_location) ?? AppConfig.location,
      'linkedIn': prefs.getString(_linkedIn) ?? AppConfig.linkedInUrl,
      'whatsapp': prefs.getString(_whatsapp) ?? AppConfig.whatsappNumber,
      'website': prefs.getString(_website) ?? AppConfig.websiteUrl,
      'github': prefs.getString(_github) ?? AppConfig.githubUrl,
      'profileImage': prefs.getString(_profileImage) ?? AppConfig.profileImage,
      'logoImage': prefs.getString(_logoImage) ?? AppConfig.logoImage,
    };
  }

  // Check if user has saved a profile before (legacy — kept for any
  // existing call sites, but prefer hasCompletedRequiredSetup for the
  // onboarding gate specifically, since a user could have saved once
  // with only some fields filled in).
  static Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_name);
  }

  // Returns true only if every field in requiredFields has a
  // non-empty value — either saved by the user, or already provided
  // via AppConfig. Used by AppGate at app startup to decide whether
  // to show the onboarding/edit-profile gate before the main screen.
  static Future<bool> hasCompletedRequiredSetup() async {
    final data = await loadProfile();
    for (final key in requiredFields) {
      final value = data[key];
      if (value == null || value.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  // Returns the subset of requiredFields that are still empty — useful
  // if you want to show the user exactly what's missing, rather than
  // a generic "please complete your profile" message.
  static Future<List<String>> missingRequiredFields() async {
    final data = await loadProfile();
    return requiredFields.where((key) {
      final value = data[key];
      return value == null || value.trim().isEmpty;
    }).toList();
  }

  // Clear everything (useful for a reset/logout feature later)
  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}