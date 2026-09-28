import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
//import '../../models/models.dart';
import '../../providers/zalono_provider.dart';

class IncomingBookingsScreen extends StatefulWidget {
  const IncomingBookingsScreen({super.key});

  @override
  State<IncomingBookingsScreen> createState() => _IncomingBookingsScreenState();
}

class _IncomingBookingsScreenState extends State<IncomingBookingsScreen> {
  int _selectedTab = 0; // 0: Pending, 1: Today's Schedule

  // Mock incoming bookings
  final List<Map<String, dynamic>> _pendingBookings = [
    {
      'id': 'ib_1',
      'customerName': 'Rohit Singh',
      'phone': '+91 00000 00000',
      'service': 'Premium Haircut',
      'price': 799,
      'duration': 60,
      'requestedTime': '12:00 PM',
      'stylist': 'Amit',
      'status': 'pending',
      'isWalkIn': false,
    },
    {
      'id': 'ib_2',
      'customerName': 'Walk-in Customer',
      'phone': '+91 99999 88888',
      'service': 'Haircut',
      'price': 399,
      'duration': 45,
      'requestedTime': 'Now',
      'stylist': 'Rahul',
      'status': 'pending',
      'isWalkIn': true,
    },
  ];

  final List<Map<String, dynamic>> _todaysSchedule = [
    {
      'id': 'bk_1',
      'customerName': 'Jay Sharma',
      'phone': '+91 00000 00000',
      'service': 'Haircut',
      'price': 399,
      'duration': 45,
      'time': '11:40 AM',
      'stylist': 'Rahul',
      'status': 'you_are_next',
    },
    {
      'id': 'bk_2',
      'customerName': 'Amit Patel',
      'phone': '+91 00000 000009',
      'service': 'Haircut + Beard',
      'price': 599,
      'duration': 60,
      'time': '12:30 PM',
      'stylist': 'Priya',
      'status': 'booked',
    },
    {
      'id': 'bk_3',
      'customerName': 'Vikram Reddy',
      'phone': '+91 00000 00000',
      'service': 'Hair Color',
      'price': 1299,
      'duration': 90,
      'time': '2:00 PM',
      'stylist': 'Neha',
      'status': 'booked',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: ZalonoTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Incoming Bookings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tabs
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _buildTab('Pending (${_pendingBookings.length})', 0),
                  const SizedBox(width: 24),
                  _buildTab("Today's Schedule", 1),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _selectedTab == 0
                  ? _buildPendingList(zalono)
                  : _buildScheduleList(zalono),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: isSelected ? 80 : 0,
            color: ZalonoTheme.primaryBurgundy,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingList(ZalonoProvider zalono) {
    if (_pendingBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No pending bookings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'New booking requests will appear here',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingBookings.length,
      itemBuilder: (context, index) {
        final booking = _pendingBookings[index];
        return _buildPendingCard(context, booking, zalono);
      },
    );
  }

  Widget _buildPendingCard(BuildContext context, Map<String, dynamic> booking, ZalonoProvider zalono) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: booking['isWalkIn'] ? Colors.blue.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking['isWalkIn'] ? 'WALK-IN' : 'ONLINE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: booking['isWalkIn'] ? Colors.blue.shade700 : Colors.amber.shade800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                booking['requestedTime'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ZalonoTheme.primaryBurgundy,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Customer Info
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: ZalonoTheme.primaryLight,
                child: Text(
                  (booking['customerName'] as String)[0],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ZalonoTheme.primaryBurgundy),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['customerName'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      booking['phone'],
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${booking['price']}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ZalonoTheme.textDark),
                  ),
                  Text(
                    '${booking['duration']} min',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Service & Stylist
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Service', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    Text(
                      booking['service'],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Requested Stylist', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    Text(
                      booking['stylist'],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rescheduleDialog(context, booking),
                  icon: const Icon(Icons.schedule_rounded, size: 16),
                  label: const Text('Reschedule'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _declineBooking(booking),
                  icon: const Icon(Icons.close_rounded, size: 16),
                  label: const Text('Decline'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _acceptBooking(booking, zalono),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Accept'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZalonoTheme.accentGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(ZalonoProvider zalono) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _todaysSchedule.length,
      itemBuilder: (context, index) {
        final booking = _todaysSchedule[index];
        return _buildScheduleCard(context, booking);
      },
    );
  }

  Widget _buildScheduleCard(BuildContext context, Map<String, dynamic> booking) {
    Color statusColor;
    String statusLabel;

    switch (booking['status']) {
      case 'you_are_next':
        statusColor = Colors.purple;
        statusLabel = "You're Next";
        break;
      case 'in_service':
        statusColor = ZalonoTheme.accentGreen;
        statusLabel = 'In Service';
        break;
      default:
        statusColor = Colors.blue;
        statusLabel = 'Booked';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.access_time_rounded, color: statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      booking['time'],
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  booking['customerName'],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${booking['service']} · ₹${booking['price']} · ${booking['duration']} min',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                booking['stylist'],
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              IconButton(
                icon: Icon(Icons.more_horiz_rounded, color: Colors.grey.shade500),
                onPressed: () => _showBookingOptions(context, booking),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _acceptBooking(Map<String, dynamic> booking, ZalonoProvider zalono) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${booking['customerName']} accepted for ${booking['requestedTime']}'),
        backgroundColor: ZalonoTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Add to today's schedule
    setState(() {
      _todaysSchedule.add({
        'id': booking['id'],
        'customerName': booking['customerName'],
        'phone': booking['phone'],
        'service': booking['service'],
        'price': booking['price'],
        'duration': booking['duration'],
        'time': booking['requestedTime'],
        'stylist': booking['stylist'],
        'status': 'booked',
      });
      _pendingBookings.remove(booking);
    });
  }

  void _declineBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Booking'),
        content: Text('Are you sure you want to decline ${booking['customerName']}\'s ${booking['service']} request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _pendingBookings.remove(booking);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${booking['customerName']}\'s booking declined'),
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  void _rescheduleDialog(BuildContext context, Map<String, dynamic> booking) {
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${booking['customerName']} - ${booking['service']}'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time_rounded),
              title: const Text('Select New Time'),
              subtitle: Text(selectedTime.format(context)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) {
                  setState(() => selectedTime = picked);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Rescheduled to ${selectedTime.format(context)}'),
                  backgroundColor: ZalonoTheme.primaryBurgundy,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: ZalonoTheme.primaryBurgundy),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showBookingOptions(BuildContext context, Map<String, dynamic> booking) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.message_outlined),
              title: const Text('Message Customer'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Call Customer'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Reschedule'),
              onTap: () {
                Navigator.pop(context);
                _rescheduleDialog(context, booking);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded, color: Colors.red),
              title: const Text('Cancel Booking', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}