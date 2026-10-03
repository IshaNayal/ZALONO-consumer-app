import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Reserved area on the Home page for a future promotional banner
/// (offers, featured salons, seasonal campaigns, Zalono announcements).
///
/// Shaped like the reference carousel — a wide rounded panel with page dots
/// beneath it — but deliberately empty: the promo content is not finalised, so
/// there is no invented offer or placeholder copy. Drop a PageView of real
/// banners in and the layout below already accounts for the dots.
class PromoBannerSection extends StatelessWidget {
  const PromoBannerSection({super.key, this.height = 150});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Column(
          children: [
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ZalonoTheme.primaryLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: ZalonoTheme.primaryBurgundy.withValues(alpha: 0.12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Page indicators for the future carousel.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 4; i++) ...[
                  Container(
                    width: i == 0 ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == 0
                          ? ZalonoTheme.primaryBurgundy
                          : ZalonoTheme.borderLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  if (i < 3) const SizedBox(width: 4),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
