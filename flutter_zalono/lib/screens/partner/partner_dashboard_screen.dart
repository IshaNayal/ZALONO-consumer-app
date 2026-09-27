import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/zalono_provider.dart';
import 'manage_slots_screen.dart';

class PartnerDashboardScreen extends StatelessWidget {
  final VoidCallback onSwitchToConsumer;

  const PartnerDashboardScreen({super.key, required this.onSwitchToConsumer});

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: const [
            Text(
              'Zalono Partner',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: ZalonoTheme.primaryBurgundy),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: onSwitchToConsumer,
            icon: const Icon(Icons.person, size: 16),
            label: const Text('Customer App'),
            style: TextButton.styleFrom(foregroundColor: ZalonoTheme.primaryBurgundy),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salon greeting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Good morning!', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('Looks Salon', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      Icon(Icons.circle, size: 8, color: ZalonoTheme.accentGreen),
                      SizedBox(width: 4),
                      Text('Open · Closes 9:00 PM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ZalonoTheme.accentGreen)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Today's Key Metrics Grid
            Row(
              children: [
                _buildMetricCard('28', 'Appointments', Icons.calendar_today_outlined),
                const SizedBox(width: 8),
                _buildMetricCard('₹18,420', 'Expected revenue', Icons.currency_rupee, isHighlight: true),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildMetricCard('6', 'Walk-ins in queue', Icons.people_outline),
                const SizedBox(width: 8),
                _buildMetricCard('4', 'Available slots', Icons.access_time_outlined),
              ],
            ),

            const SizedBox(height: 20),

            // Quick Actions Hub
            const Text('Salon Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionTile(
                  icon: Icons.access_time,
                  label: 'Manage Slots',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageSlotsScreen()));
                  },
                ),
                _buildActionTile(icon: Icons.badge_outlined, label: 'Staff Status'),
                _buildActionTile(icon: Icons.person_add_alt_1_outlined, label: 'Add Walk-in'),
                _buildActionTile(icon: Icons.insights_rounded, label: 'Analytics'),
              ],
            ),

            const SizedBox(height: 20),

            // Live Stylists Status
            const Text('Live Staff Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            _buildStaffRow('Rahul', 'Senior Stylist', 'Available', ZalonoTheme.accentGreen, ZalonoTheme.accentGreenLight),
            _buildStaffRow('Priya', 'Hair Specialist', 'With Customer', ZalonoTheme.accentAmber, ZalonoTheme.accentAmberLight),
            _buildStaffRow('Amit', 'Stylist', 'Available', ZalonoTheme.accentGreen, ZalonoTheme.accentGreenLight),
            _buildStaffRow('Neha', 'Color Expert', 'Break', Colors.grey.shade600, Colors.grey.shade200),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, IconData icon, {bool isHighlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isHighlight ? ZalonoTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isHighlight ? ZalonoTheme.primaryBurgundy.withOpacity(0.3) : Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: isHighlight ? ZalonoTheme.primaryBurgundy : Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isHighlight ? ZalonoTheme.primaryBurgundy : ZalonoTheme.textDark)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String label, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: ZalonoTheme.primaryBurgundy, size: 24),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffRow(String name, String role, String status, Color color, Color bg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              CircleAvatar(
                backgroundColor: ZalonoTheme.primaryLight,
                child: Text(name[0], style: const TextStyle(color: ZalonoTheme.primaryBurgundy, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(role, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
            child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }
}
