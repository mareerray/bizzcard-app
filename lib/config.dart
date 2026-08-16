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
  static const String websiteUrl = "";
  static const String githubUrl = "";
  static const String whatsappNumber = "";

  // Keep these pointed at real bundled defaults — never empty.
  static const String profileImage = "assets/images/brand_img.png";
  static const String logoImage = "assets/images/logo_image.png";
  static const String qrImage = "assets/images/qr_image.png";
}
