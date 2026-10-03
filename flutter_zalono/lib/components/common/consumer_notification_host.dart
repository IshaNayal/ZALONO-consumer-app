import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';

/// Consumer notification surface.
///
/// Enforces the Zalono notification budget: for each booking, at most **one**
/// pre-appointment reminder and **one** post-service rating prompt. Both are
/// consumed through the provider, which persists that fact, so neither comes
/// back on a later app launch or on the next booking.
///
/// Renders nothing at all when there is nothing to say.
class ConsumerNotificationHost extends StatefulWidget {
  const ConsumerNotificationHost({super.key});

  @override
  State<ConsumerNotificationHost> createState() =>
      _ConsumerNotificationHostState();
}

class _ConsumerNotificationHostState extends State<ConsumerNotificationHost> {
  Booking? _activePrompt;

  /// Captured while the element is still active: looking a provider up from
  /// `context` inside dispose() is not allowed.
  ZalonoProvider? _zalono;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _zalono = context.read<ZalonoProvider>();
  }

  @override
  void dispose() {
    // Let the provider re-evaluate if this host goes away mid-prompt.
    final zalono = _zalono;
    if (zalono != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        zalono.releaseNotificationLatch();
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);

    // Already showing a prompt: don't stack another.
    if (_activePrompt != null) return const SizedBox.shrink();

    final reminder = zalono.pendingDepartureReminder;
    if (reminder != null) {
      return _PromptCard(
        booking: reminder,
        icon: Icons.directions_car_rounded,
        title: "It's almost time to leave",
        message:
            "It's almost time to leave for your appointment at ${reminder.salonName}.",
        primaryLabel: 'Got it',
        onPrimary: () {
          zalono.markReminderShown(reminder);
          setState(() => _activePrompt = null);
        },
      );
    }

    final rating = zalono.pendingRatingPrompt;
    if (rating != null) {
      return _PromptCard(
        booking: rating,
        icon: Icons.star_outline_rounded,
        title: 'How was your experience?',
        message: 'Rate your visit to ${rating.salonName}.',
        primaryLabel: 'Rate Now',
        secondaryLabel: 'Skip',
        onPrimary: () {
          zalono.markRated(rating);
          setState(() => _activePrompt = null);
          _showThanks(context);
        },
        // Skipping is recorded too, so the prompt never returns.
        onSecondary: () {
          zalono.skipRating(rating);
          setState(() => _activePrompt = null);
        },
      );
    }

    return const SizedBox.shrink();
  }

  void _showThanks(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Thanks for rating!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.booking,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final Booking booking;
  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZalonoTheme.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ZalonoTheme.primaryBurgundy.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: ZalonoTheme.primaryBurgundy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ZalonoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: ZalonoTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (secondaryLabel != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSecondary,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ZalonoTheme.primaryBurgundy,
                      side: const BorderSide(
                        color: ZalonoTheme.primaryBurgundy,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      secondaryLabel!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrimary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZalonoTheme.primaryBurgundy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    primaryLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
