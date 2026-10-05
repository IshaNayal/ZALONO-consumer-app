import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';

class ManageSlotsScreen extends StatelessWidget {
  const ManageSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final salon = zalono.salons.first;

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        title: const Text("Today's Availability", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add Manual Seat modal opened')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: salon.slots.length,
        itemBuilder: (context, index) {
          final seat = salon.slots[index];
          final isBooked = seat.status == SlotStatus.booked;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      seat.time,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(width: 14),
                    if (isBooked)
                      Text(
                        'Booked (${seat.stylistName ?? 'Stylist'})',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      )
                    else
                      const Text(
                        'Open for Booking',
                        style: TextStyle(fontSize: 13, color: ZalonoTheme.accentGreen, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
                Switch.adaptive(
                  value: !isBooked,
                  activeTrackColor: ZalonoTheme.accentGreen,
                  onChanged: (val) {
                    zalono.toggleSlotStatus(salon.id, seat.id);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
