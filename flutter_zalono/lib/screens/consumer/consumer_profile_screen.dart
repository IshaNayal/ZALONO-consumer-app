import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/zalono_provider.dart';
import 'edit_profile_screen.dart';
import 'saved_locations_screen.dart';
import 'payment_methods_screen.dart';
import 'help_support_screen.dart';
import 'terms_screen.dart';
import 'signed_out_screen.dart';

/// Account settings. Deliberately a plain settings list — no stats, no
/// promotions, no duplicated appointment history (that lives in Bookings).
class ConsumerProfileScreen extends StatelessWidget {
  const ConsumerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Read identity from the provider so Edit Profile updates are reflected
    // here immediately.
    final zalono = Provider.of<ZalonoProvider>(context);
    final name = zalono.userName;
    final phone = zalono.formattedPhone;

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Identity
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: ZalonoTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(name),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ZalonoTheme.primaryBurgundy,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ZalonoTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: ZalonoTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        zalono.userEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ZalonoTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _SettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile',
              onTap: () => _push(context, const EditProfileScreen()),
            ),
            _SettingsTile(
              icon: Icons.location_on_outlined,
              title: 'Saved Locations',
              onTap: () => _push(context, const SavedLocationsScreen()),
            ),
            _SettingsTile(
              icon: Icons.credit_card_rounded,
              title: 'Payment Methods',
              onTap: () => _push(context, const PaymentMethodsScreen()),
            ),
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () => _push(context, const HelpSupportScreen()),
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms & Agreement',
              onTap: () => _push(context, const TermsScreen()),
            ),

            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Log Out',
              isDestructive: true,
              onTap: () => _confirmSignOut(context),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  /// First letter of the first and last name, matching the avatar on the
  /// Edit Profile screen.
  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final zalono = context.read<ZalonoProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        content: const Text(
          'You will need to sign in again to see your bookings.',
          style: TextStyle(fontSize: 14, color: ZalonoTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ZalonoTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Log out',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    zalono.signOut();
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignedOutScreen()),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade700 : ZalonoTheme.textDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZalonoTheme.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: ZalonoTheme.primaryBurgundy),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: ZalonoTheme.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
