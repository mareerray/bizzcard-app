class AppConfig {
  // Personal details — this file is your actual live/deployed config.
  //
  // Text and link fields are intentionally EMPTY by default. This makes
  // the app's "no link set" empty-state messages (see qr_page.dart)
  // actually reachable: a fresh setup with nothing filled in will show
  // "Go to Edit Profile to add one" instead of a fake placeholder URL.
  //
  // Fill in only the fields you actually want live on your card. Leave
  // the rest empty until you're ready to add them — that's the whole
  // point of this design.
  //
  // Image paths are the exception: they stay pointed at bundled assets,
  // since Image.asset('') would break with a truly empty string. Swap
  // these to your real image files once you have them ready.

  static const String name = "";
  static const String jobTitle = "";
  static const String company = "";
  static const String email = "";
  static const String phone = "";
  static const String location = "";
  static const String linkedInUrl = "";
  static const String portfolioUrl = "";
  static const String githubUrl = "";
  static const String whatsappNumber = "";

  // Keep these pointed at real bundled defaults — never empty.
  static const String profileImage = "assets/images/profile_image.jpg";
  static const String logoImage = "assets/images/logo_image.png";
  static const String qrImage = "assets/images/qr_image.png";
}

// class AppConfig {
//   // Personal details — edit these to your real values locally
//   // This file is listed in .gitignore so it never goes to GitHub
//   static const String name = "Firstname Lastname";
//   static const String jobTitle = "Your Job Title";
//   static const String company = "Your Company";
//   static const String email = "your@email.com";
//   static const String phone = "+xxx xx xxx xxxx";
//   static const String location = "Your location"; 
//   static const String linkedInUrl = "https://linkedin.com/in/yourprofile";
//   static const String portfolioUrl = "https://yourportfolio.com";
//   static const String githubUrl = "https://github.com/yourgithubprofile";
//   static const String whatsappNumber = "+xxx xx xxx xxxx"; // Include country code
//   static const String profileImage = "assets/images/profile_image.jpg"; 
//   static const String logoImage = "assets/images/logo_image.png";
//   static const String qrImage = "assets/images/qr_image.png";
// }