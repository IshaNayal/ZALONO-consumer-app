import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/zalono_provider.dart';
import 'screens/consumer/home_screen.dart';
import 'screens/consumer/salon_list_screen.dart';
import 'screens/consumer/my_bookings_screen.dart';
import 'screens/consumer/consumer_profile_screen.dart';
import 'screens/consumer/location_picker_screen.dart';
import 'screens/consumer/last_minute_slots_screen.dart';
import 'screens/consumer/book_by_time_screen.dart';
import 'screens/consumer/salon_detail_screen.dart';
import 'screens/consumer/service_time_screen.dart';
import 'screens/consumer/booking_confirmation_screen.dart';
import 'screens/consumer/live_appointment_screen.dart';
import 'screens/partner/partner_dashboard_screen.dart';
import 'screens/partner/manage_slots_screen.dart';
import 'screens/partner/staff_management_screen.dart';
import 'screens/partner/add_walk_in_screen.dart';
import 'screens/partner/customer_crm_screen.dart';
import 'screens/partner/analytics_screen.dart';
import 'screens/partner/during_service_screen.dart';
import 'screens/partner/incoming_bookings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZalonoApp());
}

class ZalonoApp extends StatelessWidget {
  const ZalonoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ZalonoProvider()),
      ],
      child: MaterialApp(
        title: 'Zalono - Look Your Best. Without Waiting.',
        debugShowCheckedModeBanner: false,
        theme: ZalonoTheme.lightTheme,
        home: const MainNavigationShell(),
      ),
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
  int _showcaseIndex = -1;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        setState(() {
          _showcaseIndex = _showcaseIndex < 0 ? 0 : (_showcaseIndex + 1) % 19;
        });
        return true;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        setState(() {
          _showcaseIndex = _showcaseIndex <= 0 ? 18 : _showcaseIndex - 1;
        });
        return true;
      }
    }
    return false;
  }

  Widget? _getExplicitScreen(ZalonoProvider zalono, [String? explicitParam]) {
    final screenParam = (explicitParam ?? Uri.base.queryParameters['screen'])?.toLowerCase();
    if (screenParam == null) return null;

    final demoSalon = zalono.salons.isNotEmpty ? zalono.salons.first : null;
    final demoBooking = zalono.bookings.isNotEmpty ? zalono.bookings.first : null;

    switch (screenParam) {
      case 'home':
      case '0':
        return ConsumerHomeScreen(onSwitchToPartner: () => setState(() => _isPartnerMode = true));
      case 'explore':
      case 'salon_list':
      case '1':
        return const SalonListScreen(categoryName: 'All Salons', timeOption: 'now');
      case 'salon_detail':
      case '2':
        return demoSalon != null ? SalonDetailScreen(salon: demoSalon) : const SizedBox();
      case 'service_time':
      case '3':
        return const ServiceTimeScreen(categoryName: 'Haircut');
      case 'book_by_time':
      case '4':
        return const BookByTimeScreen();
      case 'last_minute':
      case '5':
        return const LastMinuteSlotsScreen();
      case 'booking_confirmation':
      case '6':
        return demoBooking != null ? BookingConfirmationScreen(booking: demoBooking) : const SizedBox();
      case 'live_appointment':
      case '7':
        return const LiveAppointmentScreen();
      case 'bookings':
      case 'my_bookings':
      case '8':
        return const MyBookingsScreen();
      case 'profile':
      case '9':
        return const ConsumerProfileScreen();
      case 'location_picker':
      case '10':
        return const LocationPickerScreen();
      case 'partner_dashboard':
      case '11':
        return PartnerDashboardScreen(onSwitchToConsumer: () => setState(() => _isPartnerMode = false));
      case 'manage_slots':
      case '12':
        return const ManageSlotsScreen();
      case 'staff_management':
      case '13':
        return const StaffManagementScreen();
      case 'add_walk_in':
      case '14':
        return const AddWalkInScreen();
      case 'customer_crm':
      case '15':
        return const CustomerCRMScreen();
      case 'during_service':
      case '16':
        return const DuringServiceScreen();
      case 'incoming_bookings':
      case '17':
        return const IncomingBookingsScreen();
      case 'analytics':
      case '18':
        return const AnalyticsScreen();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);

    if (_showcaseIndex >= 0) {
      final showcaseScreen = _getExplicitScreen(zalono, _showcaseIndex.toString());
      if (showcaseScreen != null) {
        return showcaseScreen;
      }
    }

    final explicitScreen = _getExplicitScreen(zalono);
    if (explicitScreen != null) {
      return explicitScreen;
    }

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
      const ConsumerProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
