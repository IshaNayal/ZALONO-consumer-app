import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';

/// Support content: the questions customers actually ask, plus real ways to
/// reach the team (the call and email actions open the device dialler/mail app).
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: ZalonoTheme.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _SectionLabel('Contact us'),
            _ContactTile(
              icon: Icons.call_rounded,
              title: 'Call support',
              subtitle: AppConfig.supportPhone,
              onTap: () => _launch(AppConfig.supportCallUri),
            ),
            _ContactTile(
              icon: Icons.mail_outline_rounded,
              title: 'Email us',
              subtitle: AppConfig.supportEmail,
              onTap: () => _launch(AppConfig.supportEmailUri),
            ),

            const SizedBox(height: 18),
            const _SectionLabel('Frequently asked'),
            for (final faq in _faqs) _FaqTile(faq: faq),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(String uri) async {
    final parsed = Uri.parse(uri);
    if (await canLaunchUrl(parsed)) {
      await launchUrl(parsed, mode: LaunchMode.externalApplication);
    }
  }

  static const List<_Faq> _faqs = [
    _Faq(
      'How do I book an appointment?',
      'Pick a service, choose when you would like to go, then choose a salon '
          'from the list. Zalono shows salons that are available around your '
          'chosen time.',
    ),
    _Faq(
      'Do I have to pay upfront?',
      'You can pay by UPI or card at the payment step, or choose to pay at '
          'the salon in cash, UPI or card.',
    ),
    _Faq(
      'What if my number is wrong?',
      'Open Profile → Edit Profile to change it. You will be asked to verify '
          'the new number by OTP the next time you book.',
    ),
    _Faq(
      'Can I cancel or reschedule?',
      'Open My Bookings and open the appointment you want to change. Contact '
          'support if you need to reschedule close to your appointment time.',
    ),
    _Faq(
      'Will I get reminded before my appointment?',
      'Yes. Zalono sends one reminder before an appointment, timed using the '
          'estimated travel time to the salon.',
    ),
    _Faq(
      'How do I rate my visit?',
      'After your service is completed you will see one rating prompt. You '
          'can rate it or skip it.',
    ),
  ];
}

class _Faq {
  const _Faq(this.question, this.answer);

  final String question;
  final String answer;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: ZalonoTheme.textMuted,
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ZalonoTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
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

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final _Faq faq;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZalonoTheme.borderLight),
      ),
      child: Theme(
        // Removes the divider lines ExpansionTile draws by default.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(
            faq.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ZalonoTheme.textDark,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                faq.answer,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: ZalonoTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
