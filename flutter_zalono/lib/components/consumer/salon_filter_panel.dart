import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

/// Sort orders offered on the results screen.
enum SalonSort {
  recommended('Recommended', 'closest first'),
  priceLowToHigh('Price', 'low to high'),
  ratingHighToLow('Rating', 'high to low');

  const SalonSort(this.label, this.hint);

  final String label;

  /// Direction of the sort, shown under the label in the picker.
  final String hint;
}

/// Distance options.
enum SalonDistance {
  any('Any distance'),
  under2Km('Under 2 km');

  const SalonDistance(this.label);

  final String label;
}

/// Price options: an explicit ordering plus two budget bands.
enum SalonPriceFilter {
  any('Any price'),
  lowToHigh('Lowest first'),
  under400('Under ₹400'),
  above400('₹400 and above');

  const SalonPriceFilter(this.label);

  final String label;
}

/// Rating options: an explicit ordering plus two thresholds.
enum SalonRatingFilter {
  any('Any rating'),
  highToLow('Highest first'),
  above45('4.5★ and up'),
  above40('4.0★ and up');

  const SalonRatingFilter(this.label);

  final String label;
}

/// Filter state for the results screen.
///
/// Held as one object so the panel stays presentational and the screen applies
/// it in a single place.
class SalonFilterState {
  final SalonPriceFilter price;
  final SalonRatingFilter rating;

  /// Selected salon types. Empty means "all".
  final Set<SalonGender> genders;

  final SalonDistance distance;

  const SalonFilterState({
    this.price = SalonPriceFilter.any,
    this.rating = SalonRatingFilter.any,
    this.genders = const {},
    this.distance = SalonDistance.any,
  });

  SalonFilterState copyWith({
    SalonPriceFilter? price,
    SalonRatingFilter? rating,
    Set<SalonGender>? genders,
    SalonDistance? distance,
  }) {
    return SalonFilterState(
      price: price ?? this.price,
      rating: rating ?? this.rating,
      genders: genders ?? this.genders,
      distance: distance ?? this.distance,
    );
  }

  /// Whether anything is narrowing the list, used for the "Clear all" affordance
  /// and the empty state copy.
  bool get isActive =>
      price != SalonPriceFilter.any ||
      rating != SalonRatingFilter.any ||
      genders.isNotEmpty ||
      distance != SalonDistance.any;

  /// Human-readable summary of the active filters.
  List<String> get activeFilters => [
        if (genders.isNotEmpty)
          genders.map((g) => g.label.toLowerCase()).join(' + '),
        if (distance == SalonDistance.under2Km) 'under 2 km',
        if (price != SalonPriceFilter.any) price.label.toLowerCase(),
        if (rating != SalonRatingFilter.any) rating.label.toLowerCase(),
      ];
}

/// Compact filter bar for the salon results screen.
///
/// Each control is a dropdown row that opens a picker sheet, so the bar stays
/// short enough to leave the results visible instead of pushing them off the
/// screen.
class SalonFilterPanel extends StatelessWidget {
  const SalonFilterPanel({
    super.key,
    required this.state,
    required this.onChanged,
    required this.resultCount,
    required this.totalCount,
  });

  final SalonFilterState state;
  final ValueChanged<SalonFilterState> onChanged;

  /// Salons currently shown, and how many exist before filtering.
  final int resultCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result count makes the effect of a filter visible at a glance.
          Row(
            children: [
              Expanded(
                child: Text(
                  resultCount == totalCount
                      ? '$totalCount salons near you'
                      : 'Showing $resultCount of $totalCount salons',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: ZalonoTheme.textMuted,
                  ),
                ),
              ),
              if (state.isActive)
                TextButton(
                  onPressed: () =>
                      onChanged(const SalonFilterState()),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ZalonoTheme.primaryBurgundy,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          _DropdownRow(
            label: 'Price',
            value: state.price.label,
            isActive: state.price != SalonPriceFilter.any,
            onTap: () => _openPriceSheet(context),
          ),
          _DropdownRow(
            label: 'Rating',
            value: state.rating.label,
            isActive: state.rating != SalonRatingFilter.any,
            onTap: () => _openRatingSheet(context),
          ),
          _DropdownRow(
            label: 'Salon type',
            value: state.genders.isEmpty
                ? 'All'
                : state.genders.map((g) => g.label).join(', '),
            isActive: state.genders.isNotEmpty,
            onTap: () => _openGenderSheet(context),
          ),
          _DropdownRow(
            label: 'Distance',
            value: state.distance.label,
            isActive: state.distance != SalonDistance.any,
            onTap: () => _openDistanceSheet(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openPriceSheet(BuildContext context) async {
    final picked = await _showPickerSheet<SalonPriceFilter>(
      context: context,
      title: 'Price',
      options: SalonPriceFilter.values,
      labelOf: (o) => o.label,
      hintOf: (o) => switch (o) {
            SalonPriceFilter.any => 'no limit',
            SalonPriceFilter.lowToHigh => 'cheapest first',
            SalonPriceFilter.under400 => 'budget salons',
            SalonPriceFilter.above400 => 'premium salons',
          },
      selected: {state.price},
      allowMultiple: false,
    );
    if (picked.isEmpty || !context.mounted) return;
    onChanged(state.copyWith(price: picked.first));
  }

  Future<void> _openRatingSheet(BuildContext context) async {
    final picked = await _showPickerSheet<SalonRatingFilter>(
      context: context,
      title: 'Rating',
      options: SalonRatingFilter.values,
      labelOf: (o) => o.label,
      hintOf: (o) => switch (o) {
            SalonRatingFilter.any => 'no limit',
            SalonRatingFilter.highToLow => 'best rated first',
            SalonRatingFilter.above45 => 'highly rated',
            SalonRatingFilter.above40 => 'rated 4.0 and up',
          },
      selected: {state.rating},
      allowMultiple: false,
    );
    if (picked.isEmpty || !context.mounted) return;
    onChanged(state.copyWith(rating: picked.first));
  }

  Future<void> _openGenderSheet(BuildContext context) async {
    final picked = await _showPickerSheet<SalonGender>(
      context: context,
      title: 'Salon type',
      options: SalonGender.values,
      labelOf: (g) => g.label,
      hintOf: (g) => switch (g) {
            SalonGender.male => 'men only',
            SalonGender.female => 'women only',
            SalonGender.unisex => 'everyone',
          },
      selected: state.genders,
      allowMultiple: true,
    );
    // An empty result means the user cleared everything, which is valid.
    if (!context.mounted) return;
    onChanged(state.copyWith(genders: picked));
  }

  Future<void> _openDistanceSheet(BuildContext context) async {
    final picked = await _showPickerSheet<SalonDistance>(
      context: context,
      title: 'Distance',
      options: SalonDistance.values,
      labelOf: (o) => o.label,
      hintOf: (o) =>
          o == SalonDistance.under2Km ? '2 km or closer' : 'any distance',
      selected: {state.distance},
      allowMultiple: false,
    );
    if (picked.isEmpty || !context.mounted) return;
    onChanged(state.copyWith(distance: picked.first));
  }
}

/// Label on the left, current value plus a chevron on the right.
class _DropdownRow extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                SizedBox(
                  width: 105,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: ZalonoTheme.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? ZalonoTheme.primaryBurgundy
                                : ZalonoTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isActive
                            ? ZalonoTheme.primaryBurgundy
                            : ZalonoTheme.textMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom-sheet picker shared by all three dropdowns.
///
/// Returns the chosen options, or an empty set when dismissed.
Future<Set<T>> _showPickerSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required String Function(T) labelOf,
  required String Function(T) hintOf,
  required Set<T> selected,
  required bool allowMultiple,
}) async {
  final result = await showModalBottomSheet<Set<T>>(
    context: context,
    backgroundColor: Colors.white,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => _PickerSheet<T>(
      title: title,
      options: options,
      labelOf: labelOf,
      hintOf: hintOf,
      initialSelection: selected,
      allowMultiple: allowMultiple,
    ),
  );
  return result ?? <T>{};
}

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.labelOf,
    required this.hintOf,
    required this.initialSelection,
    required this.allowMultiple,
  });

  final String title;
  final List<T> options;
  final String Function(T) labelOf;
  final String Function(T) hintOf;
  final Set<T> initialSelection;
  final bool allowMultiple;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  late final Set<T> _selection = Set<T>.of(widget.initialSelection);

  void _toggle(T option) {
    if (!widget.allowMultiple) {
      Navigator.pop(context, {option});
      return;
    }
    setState(() {
      if (!_selection.remove(option)) _selection.add(option);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ZalonoTheme.textDark,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              children: [
                for (final option in widget.options)
                  _PickerTile(
                    label: widget.labelOf(option),
                    hint: widget.hintOf(option),
                    isSelected: _selection.contains(option),
                    showCheck: widget.allowMultiple,
                    onTap: () => _toggle(option),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selection),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZalonoTheme.primaryBurgundy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.allowMultiple ? 'Apply' : 'Done',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.hint,
    required this.isSelected,
    required this.showCheck,
    required this.onTap,
  });

  final String label;
  final String hint;
  final bool isSelected;
  final bool showCheck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground =
        isSelected ? ZalonoTheme.primaryBurgundy : ZalonoTheme.textDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? ZalonoTheme.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: ZalonoTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  showCheck
                      ? Icons.check_box_rounded
                      : Icons.check_circle_rounded,
                  size: 19,
                  color: ZalonoTheme.primaryBurgundy,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
