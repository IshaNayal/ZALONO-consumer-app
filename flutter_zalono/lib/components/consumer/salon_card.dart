import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import 'salon_gender_tag.dart';
import '../../screens/consumer/salon_detail_screen.dart';

/// Salon card for the Home list.
///
/// Laid out like the reference design: image on the left with an overlay
/// status badge and a rating pill, name and meta underneath on the right, and
/// a slot + booking action on a second row.
class SalonCard extends StatelessWidget {
  const SalonCard({super.key, required this.salon, this.onBook});

  final Salon salon;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openSalon(context),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ZalonoTheme.borderLight),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumbnail(salon: salon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                salon.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: ZalonoTheme.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            SalonGenderTag(gender: salon.gender),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${salon.area.split(',').first} · ${salon.distanceKm} km',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ZalonoTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            _Meta(
                              icon: Icons.schedule_rounded,
                              text: '${salon.travelTimeMin} min away',
                            ),
                            _Meta(
                              icon: Icons.payments_outlined,
                              text: 'From ₹${salon.priceStart.toInt()}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          size: 15,
                          color: ZalonoTheme.accentGreen,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Next slot ${salon.nextSlotTime}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: ZalonoTheme.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _openSalon(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZalonoTheme.primaryBurgundy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Book now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
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

  void _openSalon(BuildContext context) {
    if (onBook != null) {
      onBook!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SalonDetailScreen(salon: salon)),
    );
  }
}

/// Image with the open/closed status overlaid and the rating on top, matching
/// the reference card.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.salon});

  final Salon salon;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        salon.isOpen ? ZalonoTheme.accentGreen : ZalonoTheme.textMuted;

    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              salon.imageUrl,
              width: 104,
              height: 104,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 104,
                height: 104,
                color: ZalonoTheme.borderLight,
                child: const Icon(
                  Icons.storefront_rounded,
                  color: ZalonoTheme.textMuted,
                ),
              ),
            ),
          ),
          // Status badge, top-left over the image.
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    salon.isOpen ? 'Open' : 'Closed',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Rating pill, bottom-left over the image.
          Positioned(
            left: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: ZalonoTheme.borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    '${salon.rating}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ZalonoTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: ZalonoTheme.textMuted),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(fontSize: 11.5, color: ZalonoTheme.textMuted),
        ),
      ],
    );
  }
}
