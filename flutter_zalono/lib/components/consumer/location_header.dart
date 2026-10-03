import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/zalono_provider.dart';
import '../../screens/consumer/location_picker_screen.dart';

/// Compact Home page header: the user's current pilot area and nothing else.
///
/// Reads the location from the provider (single source of truth) and opens the
/// existing [LocationPickerScreen] when tapped, so switching areas keeps
/// working exactly as before.
class LocationHeader extends StatelessWidget {
  const LocationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final location = Provider.of<ZalonoProvider>(context).currentLocation;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: ZalonoTheme.primaryLight,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 18,
                    color: ZalonoTheme.primaryBurgundy,
                  ),
                  const SizedBox(width: 6),
                  // Flexible keeps the label from overflowing on narrow phones
                  // or when a longer area name is selected.
                  Flexible(
                    child: Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ZalonoTheme.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: ZalonoTheme.primaryBurgundy,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
