import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';
import '../../components/common/promo_banner_section.dart';
import '../../components/consumer/location_header.dart';
import '../../components/consumer/salon_search_bar.dart';
import '../../components/consumer/category_section.dart';
import '../../components/consumer/salon_card.dart';
import '../../screens/consumer/salon_list_screen.dart';

/// Consumer Home.
///
/// Information hierarchy is deliberately shallow:
///   location -> search -> promo banner (reserved) -> top categories ->
///   salons nearby -> filters -> salon list.
///
/// The heavier features that used to live here (AI seat finder, live
/// appointment, last-minute openings, usual-salon rebook, time chips) are not
/// deleted — their screens and logic remain in the project and stay reachable
/// from Bookings, Profile and the showcase router.
class ConsumerHomeScreen extends StatefulWidget {
  const ConsumerHomeScreen({super.key});

  @override
  State<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends State<ConsumerHomeScreen> {
  String _query = '';

  /// Salons in the selected area, narrowed by the search box.
  ///
  /// Matching covers the salon name, its area and the services it offers, so
  /// "hair spa" finds a salon that offers one.
  List<Salon> _filterSalons(List<Salon> salons) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return salons;

    return salons.where((salon) {
      final haystack = [
        salon.name,
        salon.area,
        for (final service in salon.services) '${service.name} ${service.category}',
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final nearbySalons = zalono.salonsForCurrentLocation;
    final visibleSalons = _filterSalons(nearbySalons);

    final isAreaUnavailable = nearbySalons.isEmpty;
    final isSearchEmpty = !isAreaUnavailable && visibleSalons.isEmpty;

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: LocationHeader()),
            SliverToBoxAdapter(
              child: SalonSearchBar(
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const PromoBannerSection(),
            const CategorySection(),

            // Section heading, in the reference's uppercase tracked style
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'SALONS NEAR YOU',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: ZalonoTheme.textMuted,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SalonListScreen(
                              categoryName: 'All Salons',
                              timeOption: 'now',
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ZalonoTheme.primaryBurgundy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Two empty states: the area has no coverage yet, or the typed
            // search matched nothing in an area that does.
            if (isAreaUnavailable)
              SliverToBoxAdapter(
                child: _ComingSoonState(location: zalono.currentLocation),
              )
            else if (isSearchEmpty)
              SliverToBoxAdapter(
                child: _NoSearchResultsState(query: _query.trim()),
              )
            else
              SliverList.separated(
                itemCount: visibleSalons.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SalonCard(salon: visibleSalons[index]),
                  );
                },
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

/// Shared card shell for the Home list's empty states.
class _StateCard extends StatelessWidget {
  const _StateCard({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZalonoTheme.borderLight),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ZalonoTheme.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: ZalonoTheme.primaryBurgundy, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: ZalonoTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: ZalonoTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the selected pilot area has no salon coverage yet.
///
/// Intentionally does not fall back to salons from other areas — surfacing
/// unrelated salons would misrepresent availability.
class _ComingSoonState extends StatelessWidget {
  const _ComingSoonState({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      icon: Icons.storefront_rounded,
      title: 'Coming soon in $location',
      body: 'Salons in $location are not live yet. Try another area for now.',
    );
  }
}

/// Shown when the area has salons but the typed search matched no salon.
class _NoSearchResultsState extends StatelessWidget {
  const _NoSearchResultsState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      icon: Icons.search_off_rounded,
      title: 'No match for "$query"',
      body: 'Try a salon name or a service like haircut or facial.',
    );
  }
}
