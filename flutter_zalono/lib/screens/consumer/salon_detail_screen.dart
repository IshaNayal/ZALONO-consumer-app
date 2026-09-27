import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';
import 'live_appointment_screen.dart';
import 'booking_confirmation_screen.dart';

class SalonDetailScreen extends StatefulWidget {
  final Salon salon;

  const SalonDetailScreen({super.key, required this.salon});

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  int _selectedHourIndex = 1; // 11 AM
  int _selectedSlotIndex = 2; // 11:40 AM (Recommended)
  int _selectedServiceIndex = 0; // Haircut
  int _activeTab = 1; // Services

  final List<String> _hourTabs = ['10 AM', '11 AM', '12 PM', '1 PM', '2 PM'];

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final salon = widget.salon;
    final selectedService = salon.services[_selectedServiceIndex];

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Hero Image Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.black87),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.black87),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    salon.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Salon Title & Verified badges
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(salon.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ZalonoTheme.accentGreenLight,
                          borderRadius: BorderRadius.circular(6),
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
                  const SizedBox(height: 6),
                  Text('⭐ ${salon.rating} (${salon.reviewsCount} reviews) · ${salon.distanceKm} km · ${salon.travelTimeMin} min away', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                        child: const Text('✓ Verified salon', style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Text('• ${salon.happyCustomersCount} happy customers', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Navigation Tabs (Overview, Services, Stylists, Reviews)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTabButton('Overview', 0),
                      _buildTabButton('Services', 1),
                      _buildTabButton('Stylists', 2),
                      _buildTabButton('Reviews', 3),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Services Selection List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...List.generate(salon.services.length, (idx) {
                    final s = salon.services[idx];
                    final isSelected = _selectedServiceIndex == idx;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedServiceIndex = idx),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? ZalonoTheme.primaryLight : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600)),
                                Text('${s.durationMinutes} min · ${s.description}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ],
                            ),
                            Text('₹${s.price.toInt()}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Live Availability Timeline
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Live Availability - Today', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Text('Real-time sync', style: TextStyle(fontSize: 11, color: ZalonoTheme.accentGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Hour Tabs
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _hourTabs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final isSel = _selectedHourIndex == idx;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedHourIndex = idx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? ZalonoTheme.textDark : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _hourTabs[idx],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSel ? Colors.white : Colors.grey.shade800,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Slot chips grid (Available, Limited, Booked)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSlotChip('11:00 AM', 'Booked', isBooked: true),
                      _buildSlotChip('11:15 AM', 'Available', isEarliest: true, isSelected: _selectedSlotIndex == 0, onTap: () => setState(() => _selectedSlotIndex = 0)),
                      _buildSlotChip('11:30 AM', 'Available', isEarliest: true, isSelected: _selectedSlotIndex == 1, onTap: () => setState(() => _selectedSlotIndex = 1)),
                      _buildSlotChip('11:40 AM', 'Recommended', isRecommended: true, isSelected: _selectedSlotIndex == 2, onTap: () => setState(() => _selectedSlotIndex = 2)),
                      _buildSlotChip('12:00 PM', 'Available', isSelected: _selectedSlotIndex == 3, onTap: () => setState(() => _selectedSlotIndex = 3)),
                      _buildSlotChip('12:30 PM', 'Limited', isLimited: true),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Smart Slot recommendation badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ZalonoTheme.accentGreenLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ZalonoTheme.accentGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle_rounded, color: ZalonoTheme.accentGreen, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Recommended for you: 11:40 AM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ZalonoTheme.accentGreen)),
                              Text('8 min travel time + 5 min arrival buffer', style: TextStyle(fontSize: 11, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),

      // Bottom Sticky Booking CTA Bar
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    final targetSlot = salon.slots.firstWhere((s) => s.isEarliest, orElse: () => salon.slots.first);
                    zalono.bookSlot(salon: salon, slot: targetSlot, service: selectedService);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingConfirmationScreen(booking: zalono.activeBooking!),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: ZalonoTheme.primaryBurgundy),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Book 11:15 AM', style: TextStyle(fontWeight: FontWeight.bold, color: ZalonoTheme.primaryBurgundy, fontSize: 13)),
                      Text('(Earliest slot)', style: TextStyle(fontSize: 10, color: ZalonoTheme.primaryBurgundy)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final targetSlot = salon.slots.firstWhere((s) => s.isRecommended, orElse: () => salon.slots.first);
                    zalono.bookSlot(salon: salon, slot: targetSlot, service: selectedService);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingConfirmationScreen(booking: zalono.activeBooking!),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZalonoTheme.primaryBurgundy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Book 11:40 AM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('(Recommended)', style: TextStyle(fontSize: 10, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSel = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
              color: isSel ? ZalonoTheme.primaryBurgundy : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: 36,
            color: isSel ? ZalonoTheme.primaryBurgundy : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildSlotChip(String time, String label, {bool isBooked = false, bool isLimited = false, bool isEarliest = false, bool isRecommended = false, bool isSelected = false, VoidCallback? onTap}) {
    Color bg = Colors.white;
    Color border = Colors.grey.shade300;
    Color textColor = Colors.black87;

    if (isBooked) {
      bg = Colors.grey.shade100;
      border = Colors.grey.shade300;
      textColor = Colors.grey.shade400;
    } else if (isSelected) {
      bg = ZalonoTheme.primaryBurgundy;
      border = ZalonoTheme.primaryBurgundy;
      textColor = Colors.white;
    } else if (isRecommended) {
      bg = ZalonoTheme.accentGreenLight;
      border = ZalonoTheme.accentGreen;
      textColor = ZalonoTheme.accentGreen;
    }

    return GestureDetector(
      onTap: isBooked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
            Text(label, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : textColor)),
          ],
        ),
      ),
    );
  }
}
