import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
// import '../../providers/zalono_provider.dart';
import 'salon_list_screen.dart';

class BookByTimeScreen extends StatefulWidget {
  const BookByTimeScreen({super.key});

  @override
  State<BookByTimeScreen> createState() => _BookByTimeScreenState();
}

class _BookByTimeScreenState extends State<BookByTimeScreen> {
  String _selectedTimeOption = 'now';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);

  final List<Map<String, dynamic>> _timeOptions = [
    {'id': 'now', 'label': '⚡ Right Now', 'sub': 'Fastest available', 'icon': Icons.bolt_rounded},
    {'id': '30min', 'label': 'In 30 Minutes', 'sub': 'Allow travel time', 'icon': Icons.directions_walk_rounded},
    {'id': '1hour', 'label': 'In 1 Hour', 'sub': 'Comfortable buffer', 'icon': Icons.schedule_rounded},
    {'id': 'later_today', 'label': 'Later Today', 'sub': 'Afternoon/Evening', 'icon': Icons.wb_sunny_outlined},
    {'id': 'tomorrow', 'label': 'Tomorrow', 'sub': 'Book ahead', 'icon': Icons.calendar_today_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: ZalonoTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book by Time',
          style: TextStyle(
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
                    'When do you want your appointment?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ZalonoTheme.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select a time window to see salons with confirmed slots. Zero waiting guaranteed.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // Time Options
                  ..._timeOptions.map((option) {
                    final isSelected = _selectedTimeOption == option['id'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: _buildTimeCard(
                        id: option['id'],
                        title: option['label'],
                        subtitle: option['sub'],
                        icon: option['icon'],
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedTimeOption = option['id']),
                      ),
                    );
                  }),

                  // Custom Date & Time
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _buildCustomTimeCard(),
                  ),

                  const SizedBox(height: 20),

                  // AI Search Bar
                  _buildAiSearchBar(),
                ],
              ),
            ),

            // Bottom CTA
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
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SalonListScreen(
                            categoryName: 'Haircut',
                            timeOption: _selectedTimeOption,
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
                          'Find Salons for This Time',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
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
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
                  ? ZalonoTheme.primaryBurgundy.withValues(alpha: 0.3)
                  : Colors.transparent,
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
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? ZalonoTheme.primaryBurgundy : ZalonoTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

  Widget _buildCustomTimeCard() {
    final isSelected = _selectedTimeOption == 'custom';

    return GestureDetector(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 14)),
        );
        if (pickedDate != null) {
          if (!mounted) return;
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: _selectedTime,
          );
          if (pickedTime != null && mounted) {
            setState(() {
              _selectedDate = pickedDate;
              _selectedTime = pickedTime;
              _selectedTimeOption = 'custom';
            });
          }
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
                Icons.calendar_month_rounded,
                color: isSelected ? Colors.white : ZalonoTheme.primaryBurgundy,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Specific Date & Time',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? ZalonoTheme.primaryBurgundy : ZalonoTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Pick exact seat on calendar',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 12, color: ZalonoTheme.accentGreen),
                      const SizedBox(width: 4),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at ${_selectedTime.format(context)}',
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

  Widget _buildAiSearchBar() {
    final TextEditingController controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZalonoTheme.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZalonoTheme.primaryBurgundy.withValues()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 18, color: ZalonoTheme.primaryBurgundy),
              SizedBox(width: 8),
              Text(
                'AI Seat Finder',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ZalonoTheme.primaryBurgundy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Try: "Haircut tomorrow after 6 near Patia"',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Describe what you need...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: ZalonoTheme.primaryBurgundy),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded, color: ZalonoTheme.primaryBurgundy),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('AI Search: "${controller.text}" - Finding matches...'),
                        backgroundColor: ZalonoTheme.primaryBurgundy,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    controller.clear();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}