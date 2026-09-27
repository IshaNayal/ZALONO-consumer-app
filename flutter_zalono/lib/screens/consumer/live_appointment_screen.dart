import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';

class LiveAppointmentScreen extends StatelessWidget {
  final Booking booking;

  const LiveAppointmentScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Your Appointment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Reassuring zero-wait card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.salonName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('${booking.serviceName} · ₹${booking.servicePrice.toInt()} · ${booking.serviceDuration} min', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ZalonoTheme.accentGreenLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check, size: 14, color: ZalonoTheme.accentGreen),
                            SizedBox(width: 4),
                            Text('On time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ZalonoTheme.accentGreen)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat('Slot Time', booking.slotTime),
                      _buildQuickStat('Expected Wait', '0-5 min'),
                      _buildQuickStat('Stylist', booking.stylistName),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Queue Stepper Tracker
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Live Appointment Tracking', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  _buildTimelineStep(
                    icon: Icons.check,
                    title: 'Booked',
                    subtitle: '11:15 AM · Slot confirmed',
                    isDone: true,
                  ),
                  _buildTimelineStep(
                    icon: Icons.login_rounded,
                    title: 'Checked in',
                    subtitle: '11:28 AM · Arrived at salon',
                    isDone: true,
                  ),
                  _buildTimelineStep(
                    icon: Icons.content_cut,
                    title: "You're next ✂️",
                    subtitle: 'Position: 1 · Estimated start: 11:43 AM',
                    isCurrent: true,
                  ),
                  _buildTimelineStep(
                    icon: Icons.brush_outlined,
                    title: 'In service',
                    subtitle: '45 min estimated styling',
                    isPending: true,
                  ),
                  _buildTimelineStep(
                    icon: Icons.done_all_rounded,
                    title: 'Completed',
                    subtitle: 'Pay at salon or UPI',
                    isPending: true,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Partner Salon Action Bar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                    label: const Text('Message salon'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_outlined, size: 16),
                    label: const Text('Call salon'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZalonoTheme.textDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Advance Demo Stepper Button (For interactive testing)
            TextButton.icon(
              onPressed: () {
                zalono.advanceQueueStatus(booking.id);
              },
              icon: const Icon(Icons.fast_forward_rounded, size: 16),
              label: const Text('Simulate Next Status Step'),
              style: TextButton.styleFrom(foregroundColor: ZalonoTheme.primaryBurgundy),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDone = false,
    bool isCurrent = false,
    bool isPending = false,
    bool isLast = false,
  }) {
    Color nodeColor = Colors.grey.shade300;
    Color iconColor = Colors.grey.shade600;

    if (isDone) {
      nodeColor = ZalonoTheme.accentGreen;
      iconColor = Colors.white;
    } else if (isCurrent) {
      nodeColor = ZalonoTheme.primaryBurgundy;
      iconColor = Colors.white;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: nodeColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone ? ZalonoTheme.accentGreen : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: isCurrent ? ZalonoTheme.primaryBurgundy : (isPending ? Colors.grey : Colors.black87),
                ),
              ),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
