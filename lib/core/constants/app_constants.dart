class AppConstants {
  static const String appName = 'Пласт';
  static const String supabaseUrl = 'https://fmdnrxvylmbirkzrmvhz.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZtZG5yeHZ5bG1iaXJrenJtdmh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQwMDYyODMsImV4cCI6MjA4OTU4MjI4M30.gDg-MergM8zKY3bmk7wmEVbN1B4VxrDvxakUpCyNaw0';

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
