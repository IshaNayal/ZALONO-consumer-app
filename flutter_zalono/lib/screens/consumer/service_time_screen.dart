import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/zalono_provider.dart';
import 'salon_list_screen.dart';

/// Second step of the booking flow.
///
/// Its only job is to capture *when* the user wants to visit. It deliberately
/// carries no salon, service, price or availability detail — that belongs on
/// the results page. Choosing an option continues straight to the salon list.
class ServiceTimeScreen extends StatefulWidget {
  final String categoryName;

  const ServiceTimeScreen({
    super.key,
    this.categoryName = 'Haircut',
  });

  @override
  State<ServiceTimeScreen> createState() => _ServiceTimeScreenState();
}

class _TimeOption {
  const _TimeOption({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

class _ServiceTimeScreenState extends State<ServiceTimeScreen> {
  static const List<_TimeOption> _options = [
    _TimeOption(
      id: 'now',
      label: 'Now (Fastest)',
      icon: Icons.bolt_rounded,
    ),
    _TimeOption(
      id: 'within_30_min',
      label: 'Within 30 min',
      icon: Icons.timelapse_rounded,
    ),
    _TimeOption(
      id: 'later_today',
      label: 'Later Today',
      icon: Icons.wb_twilight_rounded,
    ),
    _TimeOption(
      id: 'tomorrow',
      label: 'Tomorrow',
      icon: Icons.calendar_today_rounded,
    ),
    _TimeOption(
      id: 'custom',
      label: 'Pick a specific time',
      icon: Icons.schedule_rounded,
    ),
  ];

  String _selectedOption = 'now';
  TimeOfDay _selectedCustomTime = const TimeOfDay(hour: 12, minute: 0);
  DateTime _selectedDate = DateTime.now();

  bool get _hasCustomTime => _selectedDate != DateTime.now() || _selectedCustomTime != const TimeOfDay(hour: 12, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: ZalonoTheme.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: ZalonoTheme.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const Text(
              'When would you like to go or visit?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ZalonoTheme.textDark,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 20),
            for (final option in _options) ...[
              _buildOption(context, option),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 10),
            const Text(
              "We'll show you salons that are available around your chosen time and convenient for you to reach based on your location and traffic.",
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: ZalonoTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, _TimeOption option) {
    final isSelected = _selectedOption == option.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _onOptionTap(context, option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? ZalonoTheme.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              // Unselected borders are deliberately faint so the boxes stay
              // low-visibility; the selected one carries the contrast.
              color: isSelected
                  ? ZalonoTheme.primaryBurgundy
                  : ZalonoTheme.borderLight.withValues(alpha: 0.5),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                size: 18,
                color: isSelected
                    ? const Color.fromARGB(188, 176, 32, 63)
                    : ZalonoTheme.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color.fromARGB(255, 176, 60, 85)
                            : ZalonoTheme.textDark,
                      ),
                    ),
                    if (_captionFor(option) != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _captionFor(option)!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: ZalonoTheme.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: ZalonoTheme.primaryBurgundy,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// The chosen date/time for the custom option; null for the fixed ones,
  /// which have no second line.
  String? _captionFor(_TimeOption option) {
    if (option.id != 'custom' || !_hasCustomTime) return null;
    return '${_selectedCustomTime.format(context)} · ${DateFormat('d MMM').format(_selectedDate)}';
  }

  Future<void> _onOptionTap(BuildContext context, _TimeOption option) async {
    if (option.id == 'custom') {
      final picked = await _pickDateAndTime();
      if (picked == null || !mounted) return;
      setState(() {
        _selectedDate = picked.$1;
        _selectedCustomTime = picked.$2;
        _selectedOption = 'custom';
      });
    } else {
      setState(() => _selectedOption = option.id);
    }
    _continueToSalons();
  }

  Future<(DateTime, TimeOfDay)?> _pickDateAndTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
    );
    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedCustomTime,
    );
    if (time == null) return null;
    return (date, time);
  }

  void _continueToSalons() {
    final zalono = Provider.of<ZalonoProvider>(context, listen: false);
    zalono.setTimePreference(_selectedOption);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalonListScreen(
          categoryName: widget.categoryName,
          timeOption: _selectedOption,
        ),
      ),
    );
  }
}
