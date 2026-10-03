import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

/// Small tag showing who a salon serves for.
///
/// Kept in one place so the Home card, the results card and the salon page all
/// show the same thing. Colours stay inside the Zalono palette — the icon and
/// label carry the meaning rather than introducing new hues.
class SalonGenderTag extends StatelessWidget {
  const SalonGenderTag({super.key, required this.gender});

  final SalonGender gender;

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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      // No flex and no ellipsis on the label: the tag is sized to its content
      // and callers that might run out of room wrap it onto the next line
      // rather than clipping it.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconFor(gender), size: 12, color: foreground),
          const SizedBox(width: 4),
          Text(
            gender.label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}