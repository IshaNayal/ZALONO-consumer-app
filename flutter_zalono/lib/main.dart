import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'providers/zalono_provider.dart';
import 'screens/consumer/home_screen.dart';
import 'screens/consumer/salon_list_screen.dart';
import 'screens/consumer/my_bookings_screen.dart';
import 'screens/consumer/consumer_profile_screen.dart';
import 'components/common/consumer_notification_host.dart';
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
        return const ConsumerHomeScreen();
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
        // Reachable only through the dev showcase router. There is no
        // customer-facing entry point into the partner app.
        return PartnerDashboardScreen(
          onSwitchToConsumer: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ConsumerHomeScreen()),
            (route) => false,
          ),
        );
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

    final navItems = _buildNavItems();

    // Guard against a stale index if the Search tab is toggled off at runtime.
    final safeIndex = _currentIndex.clamp(0, navItems.length - 1);

    return Scaffold(
      body: Column(
        children: [
          // Consumer prompts: one departure reminder and one rating request
          // per booking, never repeated.
          const ConsumerNotificationHost(),
          Expanded(
            child: IndexedStack(
              index: safeIndex,
              children: [for (final item in navItems) item.screen],
            ),
          ),
        ],
      ),
      // Floating pill navigation, matching the reference layout.
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var i = 0; i < navItems.length; i++)
                  _buildNavItem(i, navItems[i].icon, navItems[i].label),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Single source of truth for the consumer bottom navigation.
  ///
  /// Returns Home / Bookings / Profile, plus Search when
  /// [AppConfig.searchEnabled] is on. Flipping that flag is all that is needed
  /// to switch between the 3-tab and 4-tab layouts — no navigation code below
  /// this method changes.
  List<_NavItem> _buildNavItems() {
    return [
      const _NavItem(
        label: 'Home',
        icon: Icons.home_rounded,
        screen: ConsumerHomeScreen(),
      ),
      if (AppConfig.searchEnabled)
        const _NavItem(
          label: 'Search',
          icon: Icons.search_rounded,
          // No text-search backend exists yet. This reuses the existing salon
          // browse/filter screen rather than faking a search experience.
          screen: SalonListScreen(categoryName: 'All Salons', timeOption: 'now'),
        ),
      const _NavItem(
        label: 'Bookings',
        icon: Icons.calendar_today_outlined,
        screen: MyBookingsScreen(),
      ),
      const _NavItem(
        label: 'Profile',
        icon: Icons.person_outline_rounded,
        screen: ConsumerProfileScreen(),
      ),
    ];
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              // Pill behind the active tab, as in the reference nav.
              color: isSelected ? ZalonoTheme.primaryLight : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 21,
              color: isSelected
                  ? ZalonoTheme.primaryBurgundy
                  : ZalonoTheme.textMuted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? ZalonoTheme.primaryBurgundy
                  : ZalonoTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// One entry in the consumer bottom navigation.
class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.screen,
  });

  final String label;
  final IconData icon;
  final Widget screen;
}
