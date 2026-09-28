import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/zalono_provider.dart';
import 'salon_detail_screen.dart';
import 'live_appointment_screen.dart';
import 'service_time_screen.dart';
import 'salon_list_screen.dart';
import 'location_picker_screen.dart';
import 'last_minute_slots_screen.dart';
import 'book_by_time_screen.dart';

class ConsumerHomeScreen extends StatelessWidget {
  final VoidCallback onSwitchToPartner;

  const ConsumerHomeScreen({super.key, required this.onSwitchToPartner});

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar with Location & Brand
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Zalono',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: ZalonoTheme.primaryBurgundy,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LocationPickerScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: ZalonoTheme.primaryBurgundy),
                                const SizedBox(width: 4),
                                Text(
                                  zalono.currentLocation,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                const Icon(Icons.keyboard_arrow_down, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.swap_horiz_rounded),
                          tooltip: 'Switch to Partner App',
                          onPressed: onSwitchToPartner,
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_none_rounded),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Greeting & Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, Jay 👋',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'What do you need today?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ZalonoTheme.textDark),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Service Categories Grid
            SliverToBoxAdapter(
              child: SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildCategoryItem(context, Icons.content_cut_rounded, 'Haircut', isSelected: true),
                    _buildCategoryItem(context, Icons.color_lens_outlined, 'Hair Color'),
                    _buildCategoryItem(context, Icons.face_retouching_natural, 'Facial'),
                    _buildCategoryItem(context, Icons.face_unlock_outlined, 'Beard'),
                    _buildCategoryItem(context, Icons.spa_outlined, 'Hair Spa'),
                    _buildCategoryItem(context, Icons.pan_tool_outlined, 'Manicure'),
                    _buildCategoryItem(context, Icons.more_horiz, 'More'),
                  ],
                ),
              ),
            ),

            // "When do you want to go?" Filter Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'When do you want to go?',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BookByTimeScreen(),
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Reverse Search',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: ZalonoTheme.primaryBurgundy,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios, size: 12, color: ZalonoTheme.primaryBurgundy),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTimeChip(context, '⚡ Now', isSelected: true),
                        const SizedBox(width: 8),
                        _buildTimeChip(context, '30 min'),
                        const SizedBox(width: 8),
                        _buildTimeChip(context, 'Today'),
                        const SizedBox(width: 8),
                        _buildTimeChip(context, 'Tomorrow'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // AI Natural Language Slot Finder
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ZalonoTheme.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ZalonoTheme.primaryBurgundy.withValues()),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'AI Slot Finder: "Haircut tomorrow after 6 near Patia"...',
                            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: ZalonoTheme.primaryBurgundy),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send_rounded, color: ZalonoTheme.primaryBurgundy, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('AI Search: Finding matches...'),
                                    backgroundColor: ZalonoTheme.primaryBurgundy,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // "Your usual salon" Rebook banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(14),
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
                          color: ZalonoTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.storefront_rounded, color: ZalonoTheme.primaryBurgundy),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Your usual salon', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const Text('Looks Salon', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            Text('⭐ 4.7 (328) · 0.8 km · Next: 11:30 AM', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SalonDetailScreen(salon: zalono.salons.first),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ZalonoTheme.primaryBurgundy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Book Again', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Active Appointment Banner (if present)
            if (zalono.activeBooking != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveAppointmentScreen(booking: zalono.activeBooking!),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ZalonoTheme.accentGreenLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ZalonoTheme.accentGreen.withValues()),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: ZalonoTheme.accentGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.access_time_filled, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text('LIVE APPOINTMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ZalonoTheme.accentGreen)),
                                    SizedBox(width: 6),
                                    Text('· Position 1 in Queue', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Text('Looks Salon · Haircut (${zalono.activeBooking!.slotTime})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: ZalonoTheme.accentGreen),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Last-Minute Slots Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LastMinuteSlotsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.amber.shade500,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last-Minute Openings',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                              Text(
                                'Slots opening in next 90 min near ${zalono.currentLocation}',
                                style: TextStyle(fontSize: 11, color: Colors.amber.shade800),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.amber.shade700),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Available Salons Near You List
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Available near you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Fastest slots', style: TextStyle(fontSize: 12, color: ZalonoTheme.primaryBurgundy, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            // Salons
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final salon = zalono.salons[index % zalono.salons.length];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: _buildSalonCard(context, salon),
                  );
                },
                childCount: zalono.salons.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, IconData icon, String title, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceTimeScreen(categoryName: title),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isSelected ? ZalonoTheme.primaryLight : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade200,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Icon(icon, color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade700, size: 24),
            ),
            const SizedBox(height: 6),
            Text(title, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(BuildContext context, String text, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SalonListScreen(
              categoryName: 'Haircut',
              timeOption: text.contains('Now') ? 'now' : text,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade300),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildSalonCard(BuildContext context, dynamic salon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ZalonoTheme.accentGreenLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: ZalonoTheme.accentGreen),
                    SizedBox(width: 4),
                    Text('Available now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: ZalonoTheme.accentGreen)),
                  ],
                ),
              ),
              const Spacer(),
              Text('Expected wait: ${salon.expectedWaitMin}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  salon.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 72, height: 72, color: Colors.grey.shade200, child: const Icon(Icons.store)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(salon.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('⭐ ${salon.rating} (${salon.reviewsCount}) · ${salon.distanceKm} km · ${salon.travelTimeMin} min away', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    const SizedBox(height: 4),
                    Text('Haircut · ₹${salon.priceStart.toInt()} · 45 min', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Next slot available', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(salon.nextSlotTime, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: ZalonoTheme.textDark)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SalonDetailScreen(salon: salon),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZalonoTheme.primaryBurgundy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Book ${salon.nextSlotTime}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
