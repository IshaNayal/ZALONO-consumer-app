import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/zalono_provider.dart';
import 'screens/consumer/home_screen.dart';
import 'screens/consumer/salon_list_screen.dart';
import 'screens/consumer/my_bookings_screen.dart';
import 'screens/partner/partner_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ZalonoProvider()),
      ],
      child: const ZalonoApp(),
    ),
  );
}

class ZalonoApp extends StatelessWidget {
  const ZalonoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zalono - Look Your Best. Without Waiting.',
      debugShowCheckedModeBanner: false,
      theme: ZalonoTheme.lightTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  bool _isPartnerMode = false;

  @override
  Widget build(BuildContext context) {
    if (_isPartnerMode) {
      return PartnerDashboardScreen(
        onSwitchToConsumer: () => setState(() => _isPartnerMode = false),
      );
    }

    final screens = [
      ConsumerHomeScreen(
        onSwitchToPartner: () => setState(() => _isPartnerMode = true),
      ),
      const SalonListScreen(categoryName: 'All Salons', timeOption: 'now'),
      const MyBookingsScreen(),
      const MyBookingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.explore_outlined, 'Explore'),
                _buildNavItem(2, Icons.calendar_today_outlined, 'Bookings'),
                _buildNavItem(3, Icons.person_outline_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade500,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? ZalonoTheme.primaryBurgundy : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
