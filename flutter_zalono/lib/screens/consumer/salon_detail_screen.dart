import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';
import '../../components/consumer/salon_gender_tag.dart';
import '../../components/consumer/explore_more_services_bar.dart';
import 'payment_verification_screen.dart';

/// Salon services page — the step right after the user picks a salon.
///
/// Reached directly from the salon results, so it leads with the service
/// catalogue rather than another summary screen. Keeps the original Zalono
/// service card design, adds a "More Services" way into the full list, and
/// ends in a single sticky **Book Now** action.
class SalonDetailScreen extends StatefulWidget {
  final Salon salon;

  const SalonDetailScreen({super.key, required this.salon});

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  /// Selection is a set: the user may pick none, one, or several services.
  final Set<String> _selectedServiceIds = {};
  bool _showAllServices = false;

  static const List<ServiceItem> _dummyExploreServices = [
    ServiceItem(
      id: 'd_spa',
      name: 'Nourishing Hair Spa',
      price: 899,
      durationMinutes: 60,
      category: 'Hair Spa',
      description: 'Intense hydration, scalp massage & shine treatment',
    ),
    ServiceItem(
      id: 'd_detan',
      name: 'De-Tan Facial Scrub & Glow',
      price: 699,
      durationMinutes: 45,
      category: 'Facial',
      description: 'Tan removal, steam cleanse & instant glow pack',
    ),
    ServiceItem(
      id: 'd_beard',
      name: 'Beard Sculpt & Hot Towel Shape',
      price: 349,
      durationMinutes: 30,
      category: 'Beard',
      description: 'Razor edge detailing, hot towel & beard oil',
    ),
    ServiceItem(
      id: 'd_massage',
      name: 'Head & Shoulder Stress-Relief Massage',
      price: 449,
      durationMinutes: 35,
      category: 'Head Massage',
      description: 'Warm herbal oil pressure-point relaxation',
    ),
    ServiceItem(
      id: 'd_color',
      name: 'Hair Color & Highlights',
      price: 1299,
      durationMinutes: 90,
      category: 'Haircut',
      description: 'Ammonia-free global color & radiance gloss',
    ),
    ServiceItem(
      id: 'd_pedicure',
      name: 'Deluxe Pedicure & Foot Reflexology',
      price: 799,
      durationMinutes: 50,
      category: 'Pedicure',
      description: 'Soak, exfoliation, cuticle care & mint foot massage',
    ),
    ServiceItem(
      id: 'd_manicure',
      name: 'Classic Hand Spa & Manicure',
      price: 549,
      durationMinutes: 40,
      category: 'Manicure',
      description: 'Dead skin removal, nail shaping & hand massage',
    ),
  ];

  List<ServiceItem> get _effectiveServices {
    final base = widget.salon.services;
    final existingNames = base.map((s) => s.name.toLowerCase().trim()).toSet();
    final dummyToAdd = _dummyExploreServices
        .where((d) => !existingNames.contains(d.name.toLowerCase().trim()))
        .toList();
    return [...base, ...dummyToAdd];
  }

  List<ServiceItem> get _selectedServices {
    return _effectiveServices
        .where((s) => _selectedServiceIds.contains(s.id))
        .toList(growable: false);
  }

  double get _totalPrice =>
      _selectedServices.fold<double>(0, (sum, s) => sum + s.price);

  int get _totalDuration =>
      _selectedServices.fold<int>(0, (sum, s) => sum + s.durationMinutes);

  void _toggleService(String id) {
    setState(() {
      if (!_selectedServiceIds.remove(id)) _selectedServiceIds.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final salon = widget.salon;
    final services = _effectiveServices;
    final selectedCount = _selectedServices.length;

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: ZalonoTheme.backgroundLight,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    salon.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey.shade200),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Salon identity
          SliverToBoxAdapter(
            child: Container(
              color: ZalonoTheme.backgroundLight,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          salon.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: ZalonoTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Who this salon serves for.
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: SalonGenderTag(gender: salon.gender),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Rating and location are separate items in a Wrap.
                  //
                  // Bundled into one Text with maxLines: 2 they needed three
                  // lines on a 320px phone, which cut the review count off the
                  // end. As separate items the rating is never truncated and
                  // the location simply drops below it when space runs out.
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Wrap(
                        spacing: 3,
                        runSpacing: 0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          Text(
                            '${salon.rating}',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          Text(
                            '(${salon.reviewsCount})',
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 12,
                              color: ZalonoTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${salon.area} · ${salon.distanceKm} km',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ZalonoTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Services
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Select services',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ZalonoTheme.textDark,
                          ),
                        ),
                      ),
                      Text(
                        selectedCount == 0
                            ? 'Optional'
                            : '$selectedCount selected',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ZalonoTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pick one, several, or none and browse the full list.',
                    style: TextStyle(
                      fontSize: 12,
                      color: ZalonoTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final service in (_showAllServices
                      ? services
                      : services.take(3))) ...[
                    _ServiceTile(
                      service: service,
                      isSelected: _selectedServiceIds.contains(service.id),
                      onTap: () => _toggleService(service.id),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ExploreMoreServicesBar(
                    remainingCount:
                        services.length > 3 ? services.length - 3 : 0,
                    isExpanded: _showAllServices,
                    onTap: () {
                      setState(() {
                        _showAllServices = !_showAllServices;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),

      // Sticky Book Now CTA
      bottomNavigationBar: _BookNowBar(
        selectedServices: _selectedServices,
        totalPrice: _totalPrice,
        totalDuration: _totalDuration,
        slot: _targetSlot(salon),
        onBook: selectedCount == 0
            ? null
            : () {
                zalono.setSelectedSalon(salon);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentVerificationScreen(
                      salon: salon,
                      services: _selectedServices,
                      slot: _targetSlot(salon),
                    ),
                  ),
                );
              },
      ),
    );
  }

  /// Uses the salon's recommended time, falling back to the earliest opening.
  LiveSlot _targetSlot(Salon salon) {
    return salon.slots.firstWhere(
      (s) => s.isRecommended && s.status == SlotStatus.available,
      orElse: () => salon.slots.firstWhere(
        (s) => s.status == SlotStatus.available,
        orElse: () => salon.slots.first,
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  final ServiceItem service;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? ZalonoTheme.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? ZalonoTheme.primaryBurgundy
                  : ZalonoTheme.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: ZalonoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${service.durationMinutes} min · ${service.description}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ZalonoTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '₹${service.price.toInt()}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ZalonoTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookNowBar extends StatelessWidget {
  const _BookNowBar({
    required this.selectedServices,
    required this.totalPrice,
    required this.totalDuration,
    required this.slot,
    required this.onBook,
  });

  final List<ServiceItem> selectedServices;
  final double totalPrice;
  final int totalDuration;
  final LiveSlot slot;

  /// Null when nothing is selected, which disables the CTA.
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    final count = selectedServices.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ZalonoTheme.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    count == 0
                        ? 'No services selected'
                        : '$count service${count == 1 ? '' : 's'} · ₹${totalPrice.toInt()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: count == 0
                          ? ZalonoTheme.textMuted
                          : ZalonoTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count == 0
                        ? 'Pick one or more to continue'
                        : '${slot.time} · $totalDuration min',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: ZalonoTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: ZalonoTheme.primaryBurgundy,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    ZalonoTheme.primaryBurgundy.withValues(alpha: 0.35),
                disabledForegroundColor: Colors.white70,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
