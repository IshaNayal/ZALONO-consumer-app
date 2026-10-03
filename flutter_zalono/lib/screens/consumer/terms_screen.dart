import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Terms & Agreement.
///
/// Content lives in [terms] rather than being inlined in the widget tree, so
/// the document can grow or be re-versioned without touching the layout.
class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: ZalonoTheme.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Terms & Agreement',
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ZalonoTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Zalono is currently running as a pilot in select areas of '
                'Bhubaneswar. These terms cover how the pilot service works.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: ZalonoTheme.primaryBurgundy,
                ),
              ),
            ),
            const SizedBox(height: 18),
            for (var i = 0; i < terms.length; i++) ...[
              Text(
                '${i + 1}. ${terms[i].title}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ZalonoTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                terms[i].body,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: ZalonoTheme.textMuted,
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 4),
            const Text(
              'By using Zalono you agree to these terms.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: ZalonoTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Term {
  const Term(this.title, this.body);

  final String title;
  final String body;
}

const List<Term> terms = [
  Term(
    'About this service',
    'Zalono helps you find salons near you and book an available time. Salon '
        'listings, prices and availability are provided by the salons '
        'themselves and may change during the pilot.',
  ),
  Term(
    'Bookings',
    'A booking is confirmed once you complete the OTP verification and the '
        'payment step, or choose to pay at the salon. Please arrive within the '
        'gap you were given, as the slot may be released if you are late.',
  ),
  Term(
    'Payments',
    'You can pay by UPI or card, or pay at the salon. Payments made in the '
        'app are processed by the payment provider; card details entered here '
        'are not stored on your device.',
  ),
  Term(
    'Cancellations and refunds',
    'If you cancel before your appointment time, any amount paid in the app is '
        'refunded to the original payment method. Refunds for services already '
        'started depend on the salon, so please contact support first.',
  ),
  Term(
    'Personal information',
    'We use your name, mobile number and saved addresses to manage your '
        'bookings and reminders. Your mobile number is verified by OTP before '
        'a booking is confirmed.',
  ),
  Term(
    'Notifications',
    'Zalono sends at most one reminder before an appointment and one rating '
        'request after the service is completed. It does not send repeated '
        'promotional notifications.',
  ),
  Term(
    'Ratings',
    'Ratings you submit are linked to your completed appointment. You can skip '
        'the rating request, and it will not be shown again for that visit.',
  ),
  Term(
    'Changes to these terms',
    'These terms may change as the pilot progresses. The version shown in the '
        'app is the version that applies to your use of the service.',
  ),
];
