import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Search field for the Home page.
///
/// Filters what is already loaded for the selected location — it is a local
/// filter over the salons Zalono has for that area, not a server-side search.
class SalonSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const SalonSearchBar({
    super.key,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search salons or services',
  });

  @override
  State<SalonSearchBar> createState() => _SalonSearchBarState();
}

class _SalonSearchBarState extends State<SalonSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14, color: ZalonoTheme.textDark),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(fontSize: 14, color: ZalonoTheme.textMuted),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: ZalonoTheme.primaryBurgundy,
          ),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: ZalonoTheme.textMuted,
                  onPressed: _clear,
                  tooltip: 'Clear',
                ),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26),
            borderSide: const BorderSide(color: ZalonoTheme.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26),
            borderSide: const BorderSide(
              color: ZalonoTheme.primaryBurgundy,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
