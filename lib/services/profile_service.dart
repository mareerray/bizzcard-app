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
  static const _portfolio = 'profile_portfolio';
  static const _github = 'profile_github';
  static const _profileImage = 'profile_image_path';
  static const _logoImage = 'profile_logo_path';

  // Save all profile fields at once
  static Future<void> saveProfile({
    required String name,
    required String jobTitle,
    required String company,
    required String email,
    required String phone,
    required String location,
    required String linkedIn,
    required String portfolio,
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
    await prefs.setString(_portfolio, portfolio);
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
      'portfolio': prefs.getString(_portfolio) ?? AppConfig.portfolioUrl,
      'github': prefs.getString(_github) ?? AppConfig.githubUrl,
      'profileImage': prefs.getString(_profileImage) ?? AppConfig.profileImage,
      'logoImage': prefs.getString(_logoImage) ?? AppConfig.logoImage,
    };
  }

  // Check if user has saved a profile before
  static Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_name);
  }

  // Clear everything (useful for a reset/logout feature later)
  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}