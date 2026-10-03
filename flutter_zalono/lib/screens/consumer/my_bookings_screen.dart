import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';

/// Booking history: what is coming up, and what already happened.
///
/// Two simple sections rather than a filter UI â€” the page is history first,
/// with live tracking kept one tap away for anything still upcoming.
class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final upcoming = zalono.upcomingBookings;
    final past = zalono.pastBookings;

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: ZalonoTheme.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: upcoming.isEmpty && past.isEmpty
            ? const _EmptyBookings()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (upcoming.isNotEmpty) ...[
                    const _SectionLabel('Upcoming'),
                    for (final booking in upcoming) ...[
                      _BookingCard(booking: booking),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 14),
                  ],
                  if (past.isNotEmpty) ...[
                    const _SectionLabel('Past'),
                    for (final booking in past) ...[
                      _BookingCard(booking: booking),
                      const SizedBox(height: 10),
                    ],
                  ],
                ],
              ),
      ),
    );
  }
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

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZalonoTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  booking.salonName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ZalonoTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 4),
          // Service, date and time share one line. The service name flexes so a
          // long name ellipsizes while the appointment time stays readable.
          Row(
            children: [
              Flexible(
                child: Text(
                  booking.serviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ZalonoTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${booking.date} · ${booking.slotTime}',
                style: const TextStyle(
                  fontSize: 12,
                  color: ZalonoTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Contact actions, replacing the separate date/time row.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ContactAction(
                icon: Icons.support_agent_rounded,
                label: 'Customer Support',
                onTap: () => _launchUri(context, AppConfig.supportCallUri),
              ),
              _ContactAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Message Salon',
                onTap: () => _launchUri(context, _salonMessageUri(context)),
              ),
              _ContactAction(
                icon: Icons.call_rounded,
                label: 'Call Salon',
                onTap: () => _launchUri(context, _salonCallUri(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Dials the salon's own number, looked up from the selected/live booking.
  ///
  /// Returns null when the salon has no number on record, in which case the
  /// action shows why instead of silently doing nothing.
  String? _salonCallUri(BuildContext context) {
    final phone = _salonPhone(context);
    if (phone == null) return null;
    return 'tel:$phone';
  }

  /// Opens a chat with the salon on WhatsApp, the usual channel for salons.
  String? _salonMessageUri(BuildContext context) {
    final phone = _salonPhone(context);
    if (phone == null) return null;
    return 'https://wa.me/91$phone';
  }

  String? _salonPhone(BuildContext context) {
    final zalono = context.read<ZalonoProvider>();
    final digitOnly = RegExp(r'\D');

    // Prefer the salon attached to this booking; fall back to the active one.
    for (final salon in [
      if (zalono.selectedSalon != null) zalono.selectedSalon!,
      ...zalono.salons.where((s) => s.name == booking.salonName),
    ]) {
      final digits = salon.phone.replaceAll(digitOnly, '');
      if (digits.length >= 10) return digits;
    }
    return null;
  }

  Future<void> _launchUri(BuildContext context, String? uri) async {
    if (uri == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('This salon has no contact number yet.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final parsed = Uri.parse(uri);
    if (await canLaunchUrl(parsed)) {
      await launchUrl(parsed, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Could not open $uri'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}

/// Compact outlined pill for a booking contact action.
class _ContactAction extends StatelessWidget {
  const _ContactAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ZalonoTheme.borderLight),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: ZalonoTheme.primaryBurgundy),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: ZalonoTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case AppointmentStatus.booked:
        bg = ZalonoTheme.primaryLight;
        fg = ZalonoTheme.primaryBurgundy;
        label = 'Confirmed';
        break;
      case AppointmentStatus.checkedIn:
        bg = Colors.amber.shade50;
        fg = Colors.amber.shade800;
        label = 'Checked In';
        break;
      case AppointmentStatus.youAreNext:
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade700;
        label = "You're Next";
        break;
      case AppointmentStatus.inService:
        bg = ZalonoTheme.accentGreenLight;
        fg = ZalonoTheme.accentGreen;
        label = 'In Chair';
        break;
      case AppointmentStatus.completed:
        bg = Colors.grey.shade100;
        fg = ZalonoTheme.textMuted;
        label = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ZalonoTheme.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 26,
                color: ZalonoTheme.primaryBurgundy,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'No bookings yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ZalonoTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your upcoming and past appointments will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: ZalonoTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
