import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';
import 'live_appointment_screen.dart';

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
                  color: Colors.emerald.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.emerald.shade200, width: 2),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.emerald,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.salonName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ZalonoTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${booking.distanceKm} km away · ~${booking.travelTimeMin} min walk',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.emerald.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'CONFIRMED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.emerald,
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

              // Primary CTA: Track in real time
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LiveAppointmentScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZalonoTheme.primaryBurgundy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.radar_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Track Appointment Live',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Secondary CTA: Back to Home
              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ZalonoTheme.textDark,
                  ),
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
      children: [
        Icon(icon, size: 18, color: ZalonoTheme.primaryBurgundy),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: ZalonoTheme.textDark,
          ),
        ),
      ],
    );
  }
}
