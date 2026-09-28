import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/zalono_provider.dart';
import '../../screens/partner/incoming_bookings_screen.dart';

class PushNotificationBanner extends StatefulWidget {
  const PushNotificationBanner({super.key});

  @override
  State<PushNotificationBanner> createState() => _PushNotificationBannerState();
}

class _PushNotificationBannerState extends State<PushNotificationBanner> {
  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final notification = zalono.incomingBookingNotification;

    if (notification == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade500,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'New Booking!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (notification['isWalkIn'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'WALK-IN',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${notification['customerName']} · ${notification['serviceName']} · ${notification['requestedTime']}',
                  style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  zalono.clearIncomingNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${notification['customerName']}\'s booking declined'),
                      backgroundColor: Colors.red.shade600,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IncomingBookingsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZalonoTheme.accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}