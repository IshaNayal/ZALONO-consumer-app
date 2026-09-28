import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';
import 'live_appointment_screen.dart';

class ConsumerProfileScreen extends StatelessWidget {
  const ConsumerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final bookings = zalono.bookings;

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 44,
                      backgroundColor: ZalonoTheme.primaryLight,
                      child: Text(
                        'J',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: ZalonoTheme.primaryBurgundy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Jay Sharma',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ZalonoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+91 00000 00000',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: ZalonoTheme.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 16, color: ZalonoTheme.primaryBurgundy),
                          SizedBox(width: 6),
                          Text(
                            'Verified Customer',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ZalonoTheme.primaryBurgundy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Quick Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildStatCard('Total Visits', bookings.length.toString(), Icons.calendar_today_rounded),
                    const SizedBox(width: 8),
                    _buildStatCard('Loyalty Points', '1,240', Icons.star_rounded, isHighlight: true),
                    const SizedBox(width: 8),
                    _buildStatCard('Favorite Salon', 'Looks Salon', Icons.storefront_rounded),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Menu Sections
            SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('My Appointments'),
                ...bookings.map((booking) => _buildBookingTile(context, booking, zalono)),
                if (bookings.isEmpty)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No appointments yet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Book your first slot and skip the wait!',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
                _buildSectionHeader('Settings & Preferences'),

                _buildSettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Name, phone, preferences',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.location_on_outlined,
                  title: 'Saved Locations',
                  subtitle: 'Home, Work, Favorites',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Booking updates, reminders, offers',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.payment_outlined,
                  title: 'Payment Methods',
                  subtitle: 'UPI, Cards, Saved wallets',
                  onTap: () {},
                ),

                const SizedBox(height: 20),
                _buildSectionHeader('Support & More'),

                _buildSettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'FAQs, chat with us',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About Zalono',
                  subtitle: 'Version 1.0.0 · Pilot Beta',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Sign Out',
                  subtitle: 'Switch account or logout',
                  onTap: () {},
                  isDestructive: true,
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {bool isHighlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isHighlight ? ZalonoTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlight ? ZalonoTheme.primaryBurgundy.withValues() : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: isHighlight ? ZalonoTheme.primaryBurgundy : Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isHighlight ? ZalonoTheme.primaryBurgundy : ZalonoTheme.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBookingTile(BuildContext context, Booking booking, ZalonoProvider zalono) {
    final isLive = booking.status != AppointmentStatus.completed &&
        booking.status != AppointmentStatus.cancelled;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLive ? ZalonoTheme.primaryBurgundy.withValues() : Colors.grey.shade200,
          width: isLive ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isLive
              ? () {
                  zalono.setActiveBooking(booking);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LiveAppointmentScreen(),
                    ),
                  );
                }
              : null,
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
                        fontSize: 15,
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
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 13, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.slotTime}, ${booking.date}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    if (booking.stylistName.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.person, size: 13, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        booking.stylistName,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ],
                ),
                if (isLive) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Queue Position: #${booking.queuePosition}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ZalonoTheme.primaryBurgundy,
                        ),
                      ),
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
                        child: const Text('Live Track', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.shade50
                        : ZalonoTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? Colors.red.shade600 : ZalonoTheme.primaryBurgundy,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDestructive ? Colors.red.shade700 : ZalonoTheme.textDark,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }
}