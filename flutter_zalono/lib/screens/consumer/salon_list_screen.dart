import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';
import 'salon_detail_screen.dart';

class SalonListScreen extends StatefulWidget {
  final String categoryName;
  final String timeOption;

  const SalonListScreen({
    super.key,
    this.categoryName = 'Haircut',
    this.timeOption = 'now',
  });

  @override
  State<SalonListScreen> createState() => _SalonListScreenState();
}

class _SalonListScreenState extends State<SalonListScreen> {
  String _activeSort = 'Fastest';
  bool _filterAvailableNow = true;
  bool _filterTopRated = false;
  double _maxDistance = 5.0;

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final salons = zalono.salons;

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: ZalonoTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              '${widget.categoryName} · ${widget.timeOption == 'now' ? 'Now' : 'Upcoming'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ZalonoTheme.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Bhubaneswar · ${salons.length} live salons',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Ribbon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: '⚡ Available now',
                      isSelected: _filterAvailableNow,
                      onTap: () => setState(() => _filterAvailableNow = !_filterAvailableNow),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: '⭐ Top rated',
                      isSelected: _filterTopRated,
                      onTap: () => setState(() => _filterTopRated = !_filterTopRated),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: '📍 < 2 km',
                      isSelected: _maxDistance <= 2.0,
                      onTap: () => setState(() => _maxDistance = _maxDistance <= 2.0 ? 5.0 : 2.0),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Sort: $_activeSort',
                      isSelected: false,
                      hasDropdown: true,
                      onTap: () {
                        setState(() {
                          _activeSort = _activeSort == 'Fastest' ? 'Rating' : 'Fastest';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Notice Banner: Real-Time Availability Guarantee
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.emerald.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.emerald.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Colors.emerald.shade800, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Zero waiting guaranteed: All shown slots are held exclusively for your booking.',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.emerald.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Salons List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                itemCount: salons.length,
                itemBuilder: (context, index) {
                  final salon = salons[index];
                  return _buildSalonCard(context, salon, zalono);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool hasDropdown = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : ZalonoTheme.textDark,
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSalonCard(BuildContext context, Salon salon, ZalonoProvider zalono) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            zalono.setSelectedSalon(salon);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SalonDetailScreen(salon: salon),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            children: [
              // Top row: Salon Name, Verified, Rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: ZalonoTheme.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: ZalonoTheme.primaryBurgundy, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              salon.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: ZalonoTheme.textDark,
                              ),
                            ),
                            if (salon.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, size: 16, color: Colors.blue),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${salon.area} · ${salon.distanceKm} km · ~${salon.travelTimeMin} min travel',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  // Rating Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          '${salon.rating}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        Text(
                          ' (${salon.reviewsCount})',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF1F1F1)),
              const SizedBox(height: 12),

              // Live Slot Status & Wait Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: ZalonoTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 14, color: ZalonoTheme.primaryBurgundy),
                        const SizedBox(width: 4),
                        Text(
                          'Next slot: ${salon.nextSlotTime}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ZalonoTheme.primaryBurgundy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: Colors.emerald.shade700),
                      const SizedBox(width: 4),
                      Text(
                        '${salon.expectedWaitMin} wait',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.emerald.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Pricing and Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Haircut starting from',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        '₹${salon.priceStart.toInt()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ZalonoTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      zalono.setSelectedSalon(salon);
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      children: const [
                        Text(
                          'Select Slot',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
