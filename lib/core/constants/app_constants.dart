class AppConstants {
  static const String appName = 'Пласт';
  static const String supabaseUrl = 'https://fmdnrxvylmbirkzrmvhz.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZtZG5yeHZ5bG1iaXJrenJtdmh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQwMDYyODMsImV4cCI6MjA4OTU4MjI4M30.gDg-MergM8zKY3bmk7wmEVbN1B4VxrDvxakUpCyNaw0';

  /// hCaptcha site key (public). The corresponding secret key is configured
  /// in Supabase Dashboard → Authentication → Bot Protection. This constant
  /// is consumed by [HCaptchaWidget] in the auth flow.
  ///
  /// When the value is the placeholder (or empty), [hcaptchaEnabled] returns
  /// false and the auth flow skips captcha entirely — useful for local
  /// development and for staging environments where the bot-protection
  /// flag in Supabase is turned off.
  static const String hcaptchaSiteKey = 'a1108af4-d414-4cfc-b8a0-8b4a765ead0c';

  /// `true` only when a real hCaptcha site key has been pasted in. Detects
  /// the placeholder by checking length (real keys are ~36 chars) and that
  /// the value is not the obvious placeholder string.
  static bool get hcaptchaEnabled {
    final key = hcaptchaSiteKey.trim();
    if (key.isEmpty) return false;
    if (key == hcaptchaSiteKey) return false;
    if (key.length < 20) return false; // real keys are 36+ chars
    return true;
  }

  static const String phonePrefix = '+380';

  /// Strip +380 prefix from phone number (for displaying in UI)
  static String stripPhonePrefix(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    return phone.startsWith(phonePrefix)
        ? phone.substring(phonePrefix.length)
        : phone;
  }

  /// Ensure +380 prefix on phone number (for storing in DB)
  static String ensurePhonePrefix(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.startsWith(phonePrefix) ? trimmed : '$phonePrefix$trimmed';
  }

  // Assets
  static const String logoAssetPath = 'assets/images/logo_in_app.png';
  static const String logoAuthAssetPath = 'assets/images/logo.png';
}
