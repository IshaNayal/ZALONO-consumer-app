import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';
import '../../components/consumer/salon_gender_tag.dart';
import '../../components/consumer/salon_filter_panel.dart';
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
  SalonFilterState _filters = const SalonFilterState();

  /// "Now" and "Within 30 min" are the immediate pages: they get the
  /// Available now tag and drop the next-slot pill.
  bool get _isImmediateTime =>
      widget.timeOption == 'now' || widget.timeOption == 'within_30_min';

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final salons = _applyFilters(zalono.salons);

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: ZalonoTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.categoryName} · '
          '${widget.timeOption == 'now' ? 'Now' : 'Upcoming'}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      // One scroll view for the filter column and the results: nesting a
      // fixed panel above an Expanded list overflowed vertically once the
      // panel grew at large text scales.
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Immediate pages only: a plain informational tag, not a filter.
            if (_isImmediateTime)
              const SliverToBoxAdapter(child: _AvailableNowTag()),

            // Filter dropdowns: price, rating, salon type, distance.
            SliverToBoxAdapter(
              child: SalonFilterPanel(
                state: _filters,
                onChanged: (value) => setState(() => _filters = value),
                resultCount: salons.length,
                totalCount: zalono.salons.length,
              ),
            ),

            // Notice Banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                
              
              ),
            ),

            // Salons List
            if (salons.isEmpty)
              SliverToBoxAdapter(child: _NoResults(filters: _filters))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                sliver: SliverList.separated(
                  itemCount: salons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _buildSalonCard(
                        context,
                        salons[index],
                        zalono,
                        showNextSlot: !_isImmediateTime,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Opens the salon page, where any number of services can be chosen.
  void _openSalon(BuildContext context, Salon salon, ZalonoProvider zalono) {
    zalono.setSelectedSalon(salon);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SalonDetailScreen(salon: salon)),
    );
  }

  /// Applies the filter dropdowns: distance, salon type, price and rating.
  ///
  /// Each step narrows the previous one, so all chosen filters combine.
  List<Salon> _applyFilters(List<Salon> all) {
    var result = all;

    if (_filters.distance == SalonDistance.under2Km) {
      result = result.where((salon) => salon.distanceKm <= 2.0).toList();
    }
    if (_filters.genders.isNotEmpty) {
      result = result
          .where((salon) => _filters.genders.contains(salon.gender))
          .toList();
    }

    // Price and rating each narrow on their budget band, or just reorder when
    // the user asked for an ordering.
    switch (_filters.price) {
      case SalonPriceFilter.any:
        break;
      case SalonPriceFilter.under400:
        result = result.where((salon) => salon.priceStart < 400).toList();
      case SalonPriceFilter.above400:
        result = result.where((salon) => salon.priceStart >= 400).toList();
      case SalonPriceFilter.lowToHigh:
        break;
    }
    switch (_filters.rating) {
      case SalonRatingFilter.any:
        break;
      case SalonRatingFilter.above45:
        result = result.where((salon) => salon.rating >= 4.5).toList();
      case SalonRatingFilter.above40:
        result = result.where((salon) => salon.rating >= 4.0).toList();
      case SalonRatingFilter.highToLow:
        break;
    }

    result = List<Salon>.of(result);
    if (_filters.price == SalonPriceFilter.lowToHigh) {
      result.sort((a, b) => a.priceStart.compareTo(b.priceStart));
    } else if (_filters.rating == SalonRatingFilter.highToLow) {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      result.sort((a, b) => a.travelTimeMin.compareTo(b.travelTimeMin));
    }
    return result;
  }

  Widget _buildSalonCard(
    BuildContext context,
    Salon salon,
    ZalonoProvider zalono, {
    bool showNextSlot = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                builder: (_) => SalonDetailScreen(
                  salon: salon,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Salon Icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: ZalonoTheme.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: ZalonoTheme.primaryBurgundy,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Salon Information
                    Expanded(
                      child: Column(
                        // stretch, not start: with start alignment this column
                        // shrank to its widest non-flex child, which left the
                        // gender tag row too narrow and overflowing.
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            salon.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: ZalonoTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Gender tag and rating get a row of their own.
                          //
                          // They used to share the name's row as flex siblings,
                          // which left each of them roughly 40px and clipped
                          // "Unisex" and "4.8 (204)" mid-word. Neither is a flex
                          // child here and the pair sits in a Wrap, so both are
                          // measured at full size and simply reflow to a second
                          // line when the column is narrow or the text scale is
                          // large — never truncated.
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SalonGenderTag(gender: salon.gender),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.amber.shade200,
                                  ),
                                ),
                                // Wrap, not Row: at 2x text scale on a 320px
                                // phone the pill needs more width than the
                                // column has, and a Row would either clip the
                                // count or overflow. This drops the count to
                                // its own line instead.
                                child: Wrap(
                                  spacing: 3,
                                  runSpacing: 0,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 15,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${salon.rating}',
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '(${salon.reviewsCount})',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          // Service-agnostic detail line.
                          Text(
                            salon.services.isEmpty
                                ? 'Salon services'
                                : salon.services.first.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: ZalonoTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Where the salon is. The gender tag has a row of its own
                // above the name, so it is not repeated here.
                Text(
                  '${salon.area} · '
                  '${salon.distanceKm} km · '
                  '~${salon.travelTimeMin} min travel',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 14),

                const Divider(
                  height: 1,
                  color: Color(0xFFF1F1F1),
                ),

                const SizedBox(height: 12),

                // Live Slot Status
                // Next slot only matters when the customer is booking ahead. On "Now" and
                // "Within 30 min" the page already carries an Available now
                // tag, so the pill is hidden.
                if (showNextSlot)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Flexible so a long time string shrinks instead of
                      // overflowing the row.
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: ZalonoTheme.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                size: 14,
                                color: ZalonoTheme.primaryBurgundy,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Next slot: ${salon.nextSlotTime}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: ZalonoTheme.primaryBurgundy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 14),

                // Pricing and Action
                //
                // Wrap (not Row) so the CTA drops to its own line instead of
                // overflowing when there is not enough width for both, e.g. on
                // small phones at large system text scales. At normal widths
                // both still sit on one line exactly as before.
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Haircut starting from',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
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

                    // Caps the CTA to a share of the viewport so the label
                    // scales down (see FittedBox below) rather than pushing
                    // past the card edge on very small phones.
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.55,
                      ),
                      child: ElevatedButton(
                      onPressed: () => _openSalon(context, salon, zalono),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            ZalonoTheme.primaryBurgundy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Scales the label down instead of overflowing the
                          // card when the system font size is very large.
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Select Seat',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                          ),
                        ],
                      ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown when the active filters exclude every salon.
class _NoResults extends StatelessWidget {
  const _NoResults({required this.filters});

  final SalonFilterState filters;

  @override
  Widget build(BuildContext context) {
    final active = filters.activeFilters;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZalonoTheme.borderLight),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.filter_alt_off_rounded,
            color: ZalonoTheme.textMuted,
            size: 26,
          ),
          const SizedBox(height: 10),
          const Text(
            'No salons match these filters',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ZalonoTheme.textDark,
            ),
          ),
          if (active.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Filtered by ${active.join(', ')}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: ZalonoTheme.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Informational tag shown only on the "Now" and "Within 30 min" results.
///
/// Not a filter: it states that these are the salons you can walk into now.
class _AvailableNowTag extends StatelessWidget {
  const _AvailableNowTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ZalonoTheme.primaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ZalonoTheme.primaryBurgundy.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bolt_rounded,
            size: 15,
            color: ZalonoTheme.primaryBurgundy,
          ),
          const SizedBox(width: 5),
          // Flexible so the label ellipsizes rather than overflowing the tag
          // at large system text scales.
          Flexible(
            child: Text(
              'Available now',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ZalonoTheme.primaryBurgundy.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

