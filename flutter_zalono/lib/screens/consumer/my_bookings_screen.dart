import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';
import 'live_appointment_screen.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final bookings = zalono.bookings;

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
        child: bookings.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'No appointments yet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Book a live slot without waiting!',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  final isLive = booking.status != AppointmentStatus.completed &&
                      booking.status != AppointmentStatus.cancelled;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isLive ? ZalonoTheme.primaryBurgundy.withValues() : Colors.grey.shade200,
                        width: isLive ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                booking.salonName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: ZalonoTheme.textDark,
                                ),
                              ),
                              _buildStatusBadge(booking.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${booking.serviceName} · ₹${booking.servicePrice.toInt()}',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${booking.slotTime}, ${booking.date}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              if (booking.stylistName.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  booking.stylistName,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isLive
                                    ? 'Queue Position: #${booking.queuePosition}'
                                    : 'Completed on time',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isLive ? ZalonoTheme.primaryBurgundy : Colors.grey,
                                ),
                              ),
                              if (isLive)
                                ElevatedButton(
                                  onPressed: () {
                                    zalono.setActiveBooking(booking);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LiveAppointmentScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ZalonoTheme.primaryBurgundy,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text('Live Tracker', style: TextStyle(fontSize: 12)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStatusBadge(AppointmentStatus status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case AppointmentStatus.booked:
        bg = Colors.blue.shade50;
        text = Colors.blue.shade700;
        label = 'Booked';
        break;
      case AppointmentStatus.checkedIn:
        bg = Colors.amber.shade50;
        text = Colors.amber.shade800;
        label = 'Checked In';
        break;
      case AppointmentStatus.youAreNext:
        bg = Colors.purple.shade50;
        text = Colors.purple.shade700;
        label = 'You\'re Next!';
        break;
      case AppointmentStatus.inService:
        bg = ZalonoTheme.accentGreenLight;
        text = ZalonoTheme.accentGreen;
        label = 'In Chair';
        break;
      case AppointmentStatus.completed:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade600;
        label = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        bg = Colors.red.shade50;
        text = Colors.red.shade700;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }
}
