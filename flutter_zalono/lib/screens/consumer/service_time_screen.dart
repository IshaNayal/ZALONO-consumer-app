import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/zalono_provider.dart';
import 'salon_list_screen.dart';

class ServiceTimeScreen extends StatefulWidget {
  final String categoryName;

  const ServiceTimeScreen({
    super.key,
    this.categoryName = 'Haircut',
  });

  @override
  State<ServiceTimeScreen> createState() => _ServiceTimeScreenState();
}

class _ServiceTimeScreenState extends State<ServiceTimeScreen> {
  String _selectedOption = 'now';
  TimeOfDay _selectedCustomTime = const TimeOfDay(hour: 12, minute: 0);
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: ZalonoTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'When would you like to go?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ZalonoTheme.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We will only show salons with instant confirmed slots matching your schedule.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // Option 1: Now (Recommended)
                  _buildTimeCard(
                    id: 'now',
                    title: 'Now',
                    badge: '⚡ Fastest Slot',
                    subtitle: 'Find nearest available within 5-15 min',
                    waitEstimate: 'Wait: 0-5 min',
                    icon: Icons.bolt_rounded,
                    isRecommended: true,
                  ),
                  const SizedBox(height: 12),

                  // Option 2: In 30 mins
                  _buildTimeCard(
                    id: '30min',
                    title: 'In 30 minutes',
                    subtitle: 'Allow travel & transit time before your slot',
                    waitEstimate: 'Slots around 11:45 AM - 12:00 PM',
                    icon: Icons.directions_walk_rounded,
                  ),
                  const SizedBox(height: 12),

                  // Option 3: Later today
                  _buildTimeCard(
                    id: 'later_today',
                    title: 'Later today (Afternoon / Evening)',
                    subtitle: 'Slots from 2:00 PM - 8:00 PM',
                    waitEstimate: '18 confirmed slots open',
                    icon: Icons.wb_twilight_rounded,
                  ),
                  const SizedBox(height: 12),

                  // Option 4: Tomorrow
                  _buildTimeCard(
                    id: 'tomorrow',
                    title: 'Tomorrow',
                    subtitle: 'Book ahead with top stylists',
                    waitEstimate: 'All salon rosters open',
                    icon: Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 12),

                  // Option 5: Custom Date & Time
                  _buildTimeCard(
                    id: 'custom',
                    title: 'Select specific date & time',
                    subtitle: 'Pick exact slot on calendar',
                    waitEstimate: '${_selectedDate.day}/${_selectedDate.month} at ${_selectedCustomTime.format(context)}',
                    icon: Icons.schedule_rounded,
                    onTapCustom: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 14)),
                      );
                      if (pickedDate != null) {
                        if (!context.mounted) return;
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _selectedCustomTime,
                        );
                        if (pickedTime != null && context.mounted) {
                          setState(() {
                            _selectedDate = pickedDate;
                            _selectedCustomTime = pickedTime;
                            _selectedOption = 'custom';
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            // Bottom CTA Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZalonoTheme.primaryBurgundy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Show Available Salons',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard({
    required String id,
    required String title,
    required String subtitle,
    required String waitEstimate,
    required IconData icon,
    String? badge,
    bool isRecommended = false,
    VoidCallback? onTapCustom,
  }) {
    final isSelected = _selectedOption == id;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedOption = id);
        if (onTapCustom != null) {
          onTapCustom();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? ZalonoTheme.primaryBurgundy.withValues()
                  : Colors.black.withValues(),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : ZalonoTheme.primaryBurgundy,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? ZalonoTheme.primaryBurgundy : ZalonoTheme.textDark,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 12, color: ZalonoTheme.accentGreen),
                      const SizedBox(width: 4),
                      Text(
                        waitEstimate,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ZalonoTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade300,
                  width: 2,
                ),
                color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
