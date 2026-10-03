import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Reusable bar displaying "Explore More Services" with remaining count badge
/// and expansion chevron, matching the design in explore-more-service.png.
class ExploreMoreServicesBar extends StatelessWidget {
  const ExploreMoreServicesBar({
    super.key,
    required this.onTap,
    this.remainingCount = 0,
    this.isExpanded = false,
    this.label,
  });

  final VoidCallback onTap;
  final int remainingCount;
  final bool isExpanded;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final title = label ?? (isExpanded ? 'Show Less' : 'Explore More Services');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ZalonoTheme.borderLight),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isExpanded ? Icons.remove : Icons.add,
                size: 18,
                color: ZalonoTheme.primaryBurgundy,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ZalonoTheme.primaryBurgundy,
                  ),
                ),
              ),
              if (!isExpanded && remainingCount > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '+$remainingCount',
                  style: const TextStyle(
                    fontSize: 13,
                    color: ZalonoTheme.textMuted,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.chevron_right_rounded,
                size: 18,
                color: ZalonoTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
