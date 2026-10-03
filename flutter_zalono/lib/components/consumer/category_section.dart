import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';
import '../../theme/app_theme.dart';
import '../../screens/consumer/service_time_screen.dart';

/// Maps a category's semantic [ServiceCategory.iconKey] to its Zalono icon.
///
/// Kept in the UI layer so [ServiceCategory] stays a plain data model that the
/// backend can populate without shipping Flutter types.
IconData categoryIconFor(String iconKey) {
  switch (iconKey) {
    case 'haircut':
      return Icons.content_cut_rounded;
    case 'color':
      return Icons.color_lens_outlined;
    case 'facial':
      return Icons.face_retouching_natural;
    case 'beard':
      return Icons.face_unlock_outlined;
    case 'spa':
      return Icons.spa_outlined;
    case 'manicure':
      return Icons.pan_tool_outlined;
    case 'pedicure':
      return Icons.pan_tool_alt_outlined;
    case 'massage':
      return Icons.self_improvement_rounded;
    default:
      return Icons.storefront_rounded;
  }
}

/// Horizontally scrollable "Top Categories" strip.
///
/// Only the most-used categories are shown inline; the rest are reachable via
/// the trailing "More" tile, which opens a bottom sheet. This keeps the Home
/// page from growing vertically as the catalogue expands.
class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);
    final top = zalono.topCategories;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label in the reference's uppercase, letter-spaced style.
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Text(
              'SERVICES',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: ZalonoTheme.textMuted,
              ),
            ),
          ),
          SizedBox(
            // Sized from the tile rather than a magic constant: the strip
            // hands its tiles a tight height, so the label growing with the
            // system text scale used to run past the bottom by a pixel or two
            // from 1.5x up.
            height: CategoryItem.stripHeightFor(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: top.length + (zalono.hasMoreCategories ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == top.length) {
                  return _MoreCategoryTile(
                    onTap: () => _showAllCategories(context, zalono),
                  );
                }
                final category = top[index];
                return CategoryItem(
                  category: category,
                  isSelected: zalono.selectedCategory == category.name,
                  onTap: () => _selectCategory(context, zalono, category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _selectCategory(
    BuildContext context,
    ZalonoProvider zalono,
    ServiceCategory category,
  ) {
    zalono.selectCategory(category.name);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceTimeScreen(categoryName: category.name),
      ),
    );
  }

  Future<void> _showAllCategories(
    BuildContext context,
    ZalonoProvider zalono,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    'All Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ZalonoTheme.textDark,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: zalono.categories.length,
                    itemBuilder: (context, index) {
                      final category = zalono.categories[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ZalonoTheme.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            categoryIconFor(category.iconKey),
                            size: 20,
                            color: ZalonoTheme.primaryBurgundy,
                          ),
                        ),
                        title: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ZalonoTheme.textDark,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: ZalonoTheme.textMuted,
                        ),
                        onTap: () => Navigator.pop(sheetContext, category.name),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !context.mounted) return;
    final category = zalono.categories.firstWhere(
      (c) => c.name == selected,
      orElse: () => zalono.categories.first,
    );
    _selectCategory(context, zalono, category);
  }
}

/// A single category tile in the horizontal strip.
class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.category,
    required this.onTap,
    this.isSelected = false,
  });

  final ServiceCategory category;
  final VoidCallback onTap;
  final bool isSelected;

  /// Height of the strip at an unscaled label: 85.5px of tile plus the
  /// breathing room the layout has always had.
  static const double _restHeight = 92.0;

  /// The tile's label is the only part that scales, and it gains 15.5px for
  /// every 1x of system text scale. 16 leaves a little headroom so nonlinear
  /// scalers cannot push the label back out of the box.
  static const double _heightPerScaleStep = 16;

  /// Height the horizontal strip needs so no tile label is ever clipped.
  static double stripHeightFor(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return (_restHeight + (scale - 1) * _heightPerScaleStep).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? ZalonoTheme.primaryLight : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? ZalonoTheme.primaryBurgundy : ZalonoTheme.borderLight,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Icon(
                categoryIconFor(category.iconKey),
                color: isSelected
                    ? ZalonoTheme.primaryBurgundy
                    : ZalonoTheme.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: ZalonoTheme.textDark,
              ),
            ),
            // Underline marks the active item, as in the reference strip.
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(top: 5),
              height: 2.5,
              width: isSelected ? 24 : 0,
              decoration: BoxDecoration(
                color: ZalonoTheme.primaryBurgundy,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreCategoryTile extends StatelessWidget {
  const _MoreCategoryTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ZalonoTheme.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ZalonoTheme.primaryBurgundy),
              ),
              child: const Icon(
                Icons.more_horiz_rounded,
                color: ZalonoTheme.primaryBurgundy,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'More',
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ZalonoTheme.primaryBurgundy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
