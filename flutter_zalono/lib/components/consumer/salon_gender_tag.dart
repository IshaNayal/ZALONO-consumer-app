import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

/// Small tag showing who a salon serves for.
///
/// Kept in one place so the Home card, the results card and the salon page all
/// show the same thing. Colours stay inside the Zalono palette — the icon and
/// label carry the meaning rather than introducing new hues.
class SalonGenderTag extends StatelessWidget {
  const SalonGenderTag({super.key, required this.gender, this.compact = false});

  final SalonGender gender;

  /// Drops the label, leaving just the icon.
  final bool compact;

  static IconData iconFor(SalonGender gender) {
    switch (gender) {
      case SalonGender.male:
        return Icons.person_rounded;
      case SalonGender.female:
        return Icons.person_3_rounded;
      case SalonGender.unisex:
        return Icons.people_alt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Unisex reads as the neutral "everyone" option, so it stays grey; the
    // targeted ones carry the soft brand pink.
    final isUnisex = gender == SalonGender.unisex;
    final background =
        isUnisex ? Colors.grey.shade100 : ZalonoTheme.primaryLight;
    final foreground =
        isUnisex ? ZalonoTheme.textMuted : ZalonoTheme.primaryBurgundy;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 7,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconFor(gender), size: compact ? 11 : 12, color: foreground),
          if (!compact) ...[
            const SizedBox(width: 4),
            // Flexible so the tag can ellipsize inside a tight row rather than
            // forcing the card to overflow on narrow screens.
            Flexible(
              child: Text(
                gender.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}