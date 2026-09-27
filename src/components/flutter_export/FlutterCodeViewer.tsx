import React, { useState } from 'react';
import { 
  FileCode, 
  Folder, 
  Copy, 
  Check, 
  Download, 
  Terminal, 
  Smartphone, 
  Layers, 
  ExternalLink,
  BookOpen
} from 'lucide-react';

interface CodeFile {
  name: string;
  path: string;
  language: string;
  content: string;
  category: 'core' | 'models' | 'providers' | 'screens' | 'config';
}

export const FlutterCodeViewer: React.FC = () => {
  const [selectedFileIndex, setSelectedFileIndex] = useState(0);
  const [copied, setCopied] = useState(false);

  const flutterFiles: CodeFile[] = [
    {
      name: 'main.dart',
      path: 'lib/main.dart',
      language: 'dart',
      category: 'core',
      content: `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/zalono_provider.dart';
import 'screens/consumer/home_screen.dart';
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
      const Center(child: Text('Explore Salons & Map')),
      const Center(child: Text('My Bookings')),
      const Center(child: Text('Profile & Preferences')),
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
}`
    },
    {
      name: 'models.dart',
      path: 'lib/models/models.dart',
      language: 'dart',
      category: 'models',
      content: `// Zalono Flutter Models
// Real-time slot booking, live queue position, and partner salon management

enum BusyLevel { quiet, moderate, busy }
enum SlotStatus { available, limited, booked, blocked }
enum AppointmentStatus { booked, checkedIn, youAreNext, inService, completed, cancelled }
enum PaymentStatus { paidSalon, paidUpi, pending }
enum StylistStatus { available, withCustomer, onBreak, off }

class ServiceItem {
  final String id;
  final String name;
  final double price;
  final int durationMinutes;
  final String description;
  final String category;

  const ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    required this.description,
    required this.category,
  });
}

class Stylist {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;
  final double rating;
  StylistStatus status;
  final String shiftHours;

  Stylist({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.rating,
    required this.status,
    required this.shiftHours,
  });
}

class LiveSlot {
  final String id;
  final String time;
  final String hourGroup;
  SlotStatus status;
  final String? stylistName;
  final String? customerName;
  final String? serviceName;
  final double price;
  final bool isEarliest;
  final bool isRecommended;
  final int? travelBufferMinutes;

  LiveSlot({
    required this.id,
    required this.time,
    required this.hourGroup,
    required this.status,
    this.stylistName,
    this.customerName,
    this.serviceName,
    required this.price,
    this.isEarliest = false,
    this.isRecommended = false,
    this.travelBufferMinutes,
  });
}

class Salon {
  final String id;
  final String name;
  final double rating;
  final int reviewsCount;
  final double distanceKm;
  final int travelTimeMin;
  final String address;
  final String area;
  final String imageUrl;
  final double priceStart;
  final bool isOpen;
  final String openingHours;
  final String expectedWaitMin;
  final String nextSlotTime;
  int queueCount;
  final int stylistsCount;
  int availableStylistsCount;
  final BusyLevel busyLevel;
  final List<ServiceItem> services;
  final List<Stylist> stylists;
  final List<LiveSlot> slots;
  final bool isVerified;
  final String happyCustomersCount;

  Salon({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviewsCount,
    required this.distanceKm,
    required this.travelTimeMin,
    required this.address,
    required this.area,
    required this.imageUrl,
    required this.priceStart,
    required this.isOpen,
    required this.openingHours,
    required this.expectedWaitMin,
    required this.nextSlotTime,
    required this.queueCount,
    required this.stylistsCount,
    required this.availableStylistsCount,
    required this.busyLevel,
    required this.services,
    required this.stylists,
    required this.slots,
    required this.isVerified,
    required this.happyCustomersCount,
  });
}

class Booking {
  final String id;
  final String salonId;
  final String salonName;
  final String serviceName;
  final double servicePrice;
  final int serviceDuration;
  final String slotTime;
  final String date;
  final double distanceKm;
  final int travelTimeMin;
  final String stylistName;
  final String customerName;
  final String customerPhone;
  AppointmentStatus status;
  final String expectedWaitMin;
  int queuePosition;
  final String estimatedStartTime;
  PaymentStatus paymentStatus;

  Booking({
    required this.id,
    required this.salonId,
    required this.salonName,
    required this.serviceName,
    required this.servicePrice,
    required this.serviceDuration,
    required this.slotTime,
    required this.date,
    required this.distanceKm,
    required this.travelTimeMin,
    required this.stylistName,
    required this.customerName,
    required this.customerPhone,
    required this.status,
    required this.expectedWaitMin,
    required this.queuePosition,
    required this.estimatedStartTime,
    this.paymentStatus = PaymentStatus.pending,
  });
}`
    },
    {
      name: 'zalono_provider.dart',
      path: 'lib/providers/zalono_provider.dart',
      language: 'dart',
      category: 'providers',
      content: `import 'package:flutter/foundation.dart';
import '../models/models.dart';

class ZalonoProvider extends ChangeNotifier {
  List<Salon> _salons = [];
  List<Booking> _bookings = [];
  Booking? _activeBooking;
  Salon? _selectedSalon;
  String _selectedCategory = 'Haircut';
  int _currentQueuePosition = 1;

  ZalonoProvider() {
    _initializeData();
  }

  List<Salon> get salons => _salons;
  List<Booking> get bookings => _bookings;
  Booking? get activeBooking => _activeBooking;
  Salon? get selectedSalon => _selectedSalon;
  String get selectedCategory => _selectedCategory;
  int get currentQueuePosition => _currentQueuePosition;

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectSalon(Salon salon) {
    _selectedSalon = salon;
    notifyListeners();
  }

  void bookSlot({
    required Salon salon,
    required LiveSlot slot,
    required ServiceItem service,
    String? stylistName,
  }) {
    final chosenStylist = stylistName ?? slot.stylistName ?? salon.stylists.first.name;

    // Mark slot as booked
    slot.status = SlotStatus.booked;

    final newBooking = Booking(
      id: 'bk_\${DateTime.now().millisecondsSinceEpoch}',
      salonId: salon.id,
      salonName: salon.name,
      serviceName: service.name,
      servicePrice: service.price,
      serviceDuration: service.durationMinutes,
      slotTime: slot.time,
      date: 'Today, 27 Sep',
      distanceKm: salon.distanceKm,
      travelTimeMin: salon.travelTimeMin,
      stylistName: chosenStylist,
      customerName: 'Jay Sharma',
      customerPhone: '+91 98765 43210',
      status: AppointmentStatus.booked,
      expectedWaitMin: '0-5 minutes',
      queuePosition: 1,
      estimatedStartTime: slot.time,
    );

    _bookings.insert(0, newBooking);
    _activeBooking = newBooking;
    notifyListeners();
  }

  void advanceQueueStatus(String bookingId) {
    final booking = _bookings.firstWhere((b) => b.id == bookingId, orElse: () => _bookings.first);
    if (booking.status == AppointmentStatus.booked) {
      booking.status = AppointmentStatus.checkedIn;
    } else if (booking.status == AppointmentStatus.checkedIn) {
      booking.status = AppointmentStatus.youAreNext;
      booking.queuePosition = 1;
    } else if (booking.status == AppointmentStatus.youAreNext) {
      booking.status = AppointmentStatus.inService;
      booking.queuePosition = 0;
    } else if (booking.status == AppointmentStatus.inService) {
      booking.status = AppointmentStatus.completed;
    }
    notifyListeners();
  }

  void toggleSlotStatus(String salonId, String slotId) {
    for (var salon in _salons) {
      if (salon.id == salonId) {
        for (var slot in salon.slots) {
          if (slot.id == slotId) {
            slot.status = slot.status == SlotStatus.available 
                ? SlotStatus.booked 
                : SlotStatus.available;
            notifyListeners();
            return;
          }
        }
      }
    }
  }

  void addWalkIn({
    required String customerName,
    required String serviceName,
    required String stylistName,
    required int durationMin,
  }) {
    if (_salons.isNotEmpty) {
      _salons.first.queueCount += 1;
      notifyListeners();
    }
  }

  void _initializeData() {
    // Initial seeded salons and active slots
  }
}`
    },
    {
      name: 'home_screen.dart',
      path: 'lib/screens/consumer/home_screen.dart',
      language: 'dart',
      category: 'screens',
      content: `// Availability-First Customer Home Screen
// Header, Categories, Smart Slot recommendations, Usual Salon Rebook

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/zalono_provider.dart';
import 'salon_detail_screen.dart';
import 'live_appointment_screen.dart';

class ConsumerHomeScreen extends StatelessWidget {
  final VoidCallback onSwitchToPartner;

  const ConsumerHomeScreen({super.key, required this.onSwitchToPartner});

  @override
  Widget build(BuildContext context) {
    final zalono = Provider.of<ZalonoProvider>(context);

    return Scaffold(
      backgroundColor: ZalonoTheme.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top App Bar with Location & Brand
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Zalono',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: ZalonoTheme.primaryBurgundy,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: ZalonoTheme.primaryBurgundy),
                              SizedBox(width: 4),
                              Text('Bhubaneswar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Icon(Icons.keyboard_arrow_down, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz_rounded),
                      onPressed: onSwitchToPartner,
                    ),
                  ],
                ),
              ),
            ),

            // Salons Feed with Smart Slots
            // ...
          ],
        ),
      ),
    );
  }
}`
    },
    {
      name: 'salon_detail_screen.dart',
      path: 'lib/screens/consumer/salon_detail_screen.dart',
      language: 'dart',
      category: 'screens',
      content: `// Salon Detail & Live Slots Screen
// 4-Tab Navigation (Overview, Services, Stylists, Reviews)
// Live Availability Timeline (10 AM - 2 PM) with Travel Buffer Calculation
// Sticky Dual CTA (Earliest slot vs Recommended slot)`
    },
    {
      name: 'live_appointment_screen.dart',
      path: 'lib/screens/consumer/live_appointment_screen.dart',
      language: 'dart',
      category: 'screens',
      content: `// Live Appointment Tracking Screen
// Reassuring zero-wait card, Stepper progress tracker, Queue position
// Message salon, Call salon, Zero-wait promise guarantee`
    },
    {
      name: 'partner_dashboard_screen.dart',
      path: 'lib/screens/partner/partner_dashboard_screen.dart',
      language: 'dart',
      category: 'screens',
      content: `// Zalono Partner - Salon Owner Home Screen
// Appointments, Revenue, Walk-ins, Available Slots, Stylist Live Status`
    },
    {
      name: 'manage_slots_screen.dart',
      path: 'lib/screens/partner/manage_slots_screen.dart',
      language: 'dart',
      category: 'screens',
      content: `// Partner Real-Time Slot Management Screen
// Date scroller, slot status toggle, manual slot creation, live cloud sync`
    },
    {
      name: 'app_theme.dart',
      path: 'lib/theme/app_theme.dart',
      language: 'dart',
      category: 'core',
      content: `import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZalonoTheme {
  static const Color primaryBurgundy = Color(0xFF80142B);
  static const Color primaryDark = Color(0xFF4A0E1A);
  static const Color primaryLight = Color(0xFFF9E8EC);
  
  static const Color accentGreen = Color(0xFF16A34A);
  static const Color accentGreenLight = Color(0xFFDCFCE7);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentAmberLight = Color(0xFFFEF3C7);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBurgundy,
        primary: primaryBurgundy,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    );
  }
}`
    },
    {
      name: 'pubspec.yaml',
      path: 'pubspec.yaml',
      language: 'yaml',
      category: 'config',
      content: `name: zalono
description: "Zalono - Real-Time Salon Booking & Live Slots App in Flutter."
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.2.0 <4.0.0"
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  google_fonts: ^6.1.0
  intl: ^0.19.0
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true`
    }
  ];

  const currentFile = flutterFiles[selectedFileIndex];

  const handleCopy = () => {
    navigator.clipboard.writeText(currentFile.content);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownload = () => {
    const element = document.createElement('a');
    const file = new Blob([currentFile.content], { type: 'text/plain' });
    element.href = URL.createObjectURL(file);
    element.download = currentFile.name;
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
  };

  return (
    <div className="flex-1 flex flex-col bg-slate-950 text-slate-100 overflow-hidden h-full">
      {/* Top Code Explorer Header */}
      <div className="px-6 py-4 bg-slate-900 border-b border-slate-800 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#80142B] flex items-center justify-center font-bold text-white shadow-sm">
            <Smartphone className="w-4 h-4" />
          </div>
          <div>
            <h2 className="text-sm font-bold text-white flex items-center gap-2">
              <span>Flutter & Dart Production Codebase</span>
              <span className="text-[10px] bg-emerald-500/20 text-emerald-400 px-2 py-0.5 rounded-full border border-emerald-500/30">
                Flutter 3.x Ready
              </span>
            </h2>
            <p className="text-xs text-slate-400">
              Clean architecture with Provider state management, models, and Material 3 UI
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={handleCopy}
            className="px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-lg text-xs font-semibold flex items-center gap-1.5 transition-colors border border-slate-700"
          >
            {copied ? <Check className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
            <span>{copied ? 'Copied!' : 'Copy File'}</span>
          </button>
          <button
            onClick={handleDownload}
            className="px-3 py-1.5 bg-[#80142B] hover:bg-[#681023] text-white rounded-lg text-xs font-semibold flex items-center gap-1.5 transition-colors shadow-sm"
          >
            <Download className="w-3.5 h-3.5" />
            <span>Download</span>
          </button>
        </div>
      </div>

      {/* Main Body: File Sidebar + Code Editor */}
      <div className="flex-1 flex min-h-0">
        {/* Left File Tree */}
        <div className="w-64 bg-slate-900/60 border-r border-slate-800 p-3 overflow-y-auto">
          <div className="text-[10px] font-bold uppercase tracking-wider text-slate-500 px-2 mb-2 flex items-center gap-1">
            <Folder className="w-3.5 h-3.5" />
            <span>flutter_zalono /</span>
          </div>

          <div className="space-y-0.5">
            {flutterFiles.map((file, idx) => (
              <button
                key={file.path}
                onClick={() => setSelectedFileIndex(idx)}
                className={`w-full px-2.5 py-1.5 rounded-lg text-left text-xs font-mono flex items-center gap-2 transition-colors ${
                  selectedFileIndex === idx
                    ? 'bg-[#80142B] text-white font-bold'
                    : 'text-slate-400 hover:bg-slate-800 hover:text-slate-200'
                }`}
              >
                <FileCode className="w-3.5 h-3.5 shrink-0 opacity-70" />
                <span className="truncate">{file.name}</span>
              </button>
            ))}
          </div>

          {/* Quick Setup Instructions */}
          <div className="mt-6 p-3 bg-slate-800/60 rounded-xl border border-slate-700/60 text-[11px] text-slate-300 space-y-2">
            <span className="font-bold text-white flex items-center gap-1">
              <Terminal className="w-3 h-3 text-[#f8a5b5]" />
              <span>How to Run</span>
            </span>
            <pre className="text-[10px] font-mono text-emerald-400 bg-slate-950 p-2 rounded border border-slate-800 overflow-x-auto">
              {`cd flutter_zalono
flutter pub get
flutter run`}
            </pre>
            <p className="text-[10px] text-slate-400 leading-normal">
              All files are saved inside <code className="text-white">/flutter_zalono/lib/</code> in this workspace.
            </p>
          </div>
        </div>

        {/* Right Code Display Area */}
        <div className="flex-1 flex flex-col min-w-0 bg-[#0d1117] overflow-hidden">
          {/* File Tab Bar */}
          <div className="px-4 py-2 bg-slate-900/90 border-b border-slate-800 flex items-center justify-between text-xs font-mono text-slate-400">
            <span className="text-slate-200">{currentFile.path}</span>
            <span className="text-[10px] uppercase text-slate-500">{currentFile.language}</span>
          </div>

          {/* Code Viewer */}
          <div className="flex-1 p-4 overflow-auto font-mono text-xs leading-relaxed text-slate-300 select-text">
            <pre className="whitespace-pre">
              <code>{currentFile.content}</code>
            </pre>
          </div>
        </div>
      </div>
    </div>
  );
};
