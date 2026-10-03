/// App-level feature flags.
///
/// The consumer bottom navigation is derived from these values, so switching
/// between the 3-tab and 4-tab layouts is a one-line change rather than a
/// navigation rewrite.
class AppConfig {
  const AppConfig._();

  /// Controls the optional Search tab in the consumer bottom navigation.
  ///
  /// `false` -> Home, Bookings, Profile
  /// `true`  -> Home, Search, Bookings, Profile
  ///
  /// When enabled, the Search tab opens the existing salon browse/filter
  /// screen. No text-search backend exists yet, so the tab is off by default
  /// and nothing advertises search that is not implemented.
  ///
  /// Mutable (rather than `const`) so it can be flipped at runtime later —
  /// e.g. from a remote config or debug menu — without the navigation code
  /// changing. The bottom navigation is derived from this single flag.
  static bool searchEnabled = false;

  // ---------------------------------------------------------------------------
  // Support contact, shared by the Help page and the booking actions so the
  // pilot has a single number to change.
  // ---------------------------------------------------------------------------

  static const String supportPhone = '+91 1800 123 4567';
  static const String supportEmail = 'support@zalono.app';

  /// Dialler URI for [supportPhone].
  static String get supportCallUri =>
      'tel:${supportPhone.replaceAll(RegExp(r'[^0-9+]'), '')}';

  static String get supportEmailUri => 'mailto:$supportEmail';
}
