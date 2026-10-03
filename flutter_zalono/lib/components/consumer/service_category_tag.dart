import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Small tag naming the sub-type of a service — "Hair Color", "Beard",
/// "Manicure" and so on.
///
/// Shown on every service row so the catalogue can be scanned by sub-type
/// rather than read line by line. Deliberately neutral: the tile's selected
/// state is already carried by the brand pink fill and border, so a coloured
/// tag would fight it for attention.
class ServiceCategoryTag extends StatelessWidget {
  const ServiceCategoryTag({super.key, required this.category});

  /// The service's sub-type, straight off the model. Nothing is hardcoded here
  /// so a new category needs no change to this widget.
  final String category;

  @override
  Widget build(BuildContext context) {
    final label = category.trim();

    // A service with no sub-type set should not render an empty pill.
    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: ZalonoTheme.backgroundLight,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: ZalonoTheme.borderLight),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: ZalonoTheme.textMuted,
        ),
      ),
    );
  }
}