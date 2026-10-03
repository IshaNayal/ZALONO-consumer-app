import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: ZalonoTheme.textDark),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: const Text(
          'Booking Confirmed',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Animation Circle
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: ZalonoTheme.accentGreenLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: ZalonoTheme.accentGreen.withValues(), width: 2),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: ZalonoTheme.accentGreen,
                  size: 48,
                ),
              ),
              const SizedBox(height: 18),

              // Title
              const Text(
                'You\'re booked! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ZalonoTheme.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your slot is reserved. Zero waiting required.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 28),

              // Booking Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ZalonoTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Salon Name & Area
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Flexible: a rigid name column previously pushed the
                        // status badge off the card on narrow phones.
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.salonName,
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
                                '${booking.distanceKm} km away · ~${booking.travelTimeMin} min walk',
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
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: ZalonoTheme.accentGreenLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'CONFIRMED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: ZalonoTheme.accentGreen,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Key Details
                    _buildDetailRow(
                      Icons.schedule_rounded,
                      'Slot Time',
                      '${booking.slotTime} (${booking.date})',
                      isBold: true,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.content_cut_rounded,
                      'Service',
                      '${booking.serviceName} (${booking.serviceDuration} min)',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.person_rounded,
                      'Stylist',
                      booking.stylistName.isEmpty ? 'Next Available Expert' : booking.stylistName,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.confirmation_number_outlined,
                      'Booking Code',
                      '#ZAL-${booking.id.substring(booking.id.length > 4 ? booking.id.length - 4 : 0).toUpperCase()}',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.currency_rupee_rounded,
                      'Pay at salon',
                      '₹${booking.servicePrice.toInt()} (UPI / Cash / Card)',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Zero-wait assurance tip
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 18, color: Colors.amber.shade900),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Live queue tracking starts now. When you arrive, tap "Checked in" to take your seat instantly!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Primary CTA: navigate to the salon
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _openDirections(context, booking),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZalonoTheme.primaryBurgundy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Get Directions',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ZalonoTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens the installed maps app at the salon.
  ///
  /// The booking only stores the salon name, so the destination is looked up by
  /// name; the address is shown in the fallback sheet when no maps app can
  /// handle the link.
  Future<void> _openDirections(
    BuildContext context,
    Booking booking,
  ) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query='
      '${Uri.encodeComponent(booking.salonName)}',
    );

    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }

    if (launched || !context.mounted) return;

    final salon = context.read<ZalonoProvider>().selectedSalon;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Salon address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ZalonoTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                salon?.address ?? booking.salonName,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: ZalonoTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${booking.distanceKm} km away · about ${booking.travelTimeMin} min travel',
                style: const TextStyle(
                  fontSize: 12,
                  color: ZalonoTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: ZalonoTheme.primaryBurgundy),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: ZalonoTheme.textMuted),
        ),
        const SizedBox(width: 12),
        // Flexible (not Spacer): a rigid trailing Text previously overflowed
        // the row on narrow phones and at large text scales.
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: ZalonoTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
