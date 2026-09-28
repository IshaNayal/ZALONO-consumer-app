import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ZalonoProvider extends ChangeNotifier {
  List<Salon> _salons = [];
  List<Booking> _bookings = [];
  Booking? _activeBooking;
  Salon? _selectedSalon;
  String _selectedCategory = 'Haircut';
  final int _currentQueuePosition = 1;
  String _currentLocation = 'Saheed Nagar';
  String _timePreference = 'now';
  Map<String, dynamic>? _incomingBookingNotification;
  bool _isBackendConnected = false;

  ZalonoProvider() {
    _initializeData();
    _checkAndSyncBackend();
  }

  bool get isBackendConnected => _isBackendConnected;

  Future<void> _checkAndSyncBackend() async {
    final available = await ApiService.isBackendAvailable();
    _isBackendConnected = available;
    if (available) {
      final remoteSalons = await ApiService.fetchSalons();
      if (remoteSalons != null && remoteSalons.isNotEmpty) {
        _salons = remoteSalons;
        if (_selectedSalon != null) {
          _selectedSalon = _salons.firstWhere((s) => s.id == _selectedSalon!.id, orElse: () => _salons.first);
        }
      }
    }
    notifyListeners();
  }

  List<Salon> get salons => _salons;
  List<Booking> get bookings => _bookings;
  Booking? get activeBooking => _activeBooking;
  Salon? get selectedSalon => _selectedSalon;
  String get selectedCategory => _selectedCategory;
  int get currentQueuePosition => _currentQueuePosition;
  String get currentLocation => _currentLocation;
  String get timePreference => _timePreference;
  Map<String, dynamic>? get incomingBookingNotification => _incomingBookingNotification;

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void selectSalon(Salon salon) {
    _selectedSalon = salon;
    notifyListeners();
  }

  void setSelectedSalon(Salon salon) {
    _selectedSalon = salon;
    notifyListeners();
  }

  void setLocation(String location) {
    _currentLocation = location;
    notifyListeners();
  }

  void updateStylistStatus(String salonId, String stylistId, StylistStatus status) {
    for (var salon in _salons) {
      if (salon.id == salonId) {
        for (var stylist in salon.stylists) {
          if (stylist.id == stylistId) {
            stylist.status = status;
            notifyListeners();
            return;
          }
        }
      }
    }
  }

  void setActiveBooking(Booking booking) {
    _activeBooking = booking;
    notifyListeners();
  }

  void setTimePreference(String preference) {
    _timePreference = preference;
    notifyListeners();
  }

  void setIncomingBookingNotification(Map<String, dynamic> notification) {
    _incomingBookingNotification = notification;
    notifyListeners();
  }

  void clearIncomingNotification() {
    _incomingBookingNotification = null;
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
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
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
      customerName: 'Isha Nayal',
      customerPhone: '+91 00000 00000',
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
    _salons = [
      Salon(
        id: 'salon_1',
        name: 'Looks Salon',
        rating: 4.7,
        reviewsCount: 328,
        distanceKm: 0.8,
        travelTimeMin: 8,
        address: 'Plot 42, Saheed Nagar, Janpath Road',
        area: 'Saheed Nagar, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&q=80&w=800',
        priceStart: 399,
        isOpen: true,
        openingHours: 'Open · Closes 9:00 PM',
        expectedWaitMin: '0-5 min',
        nextSlotTime: '11:30 AM',
        queueCount: 3,
        stylistsCount: 4,
        availableStylistsCount: 2,
        busyLevel: BusyLevel.quiet,
        isVerified: true,
        happyCustomersCount: '1000+',
        services: [
          const ServiceItem(id: 's1', name: 'Haircut', price: 399, durationMinutes: 45, category: 'Haircut', description: 'Consultation & Precision cut'),
          const ServiceItem(id: 's2', name: 'Haircut + Beard', price: 599, durationMinutes: 60, category: 'Haircut', description: 'Cut with hot towel shape'),
          const ServiceItem(id: 's3', name: 'Premium Haircut', price: 799, durationMinutes: 60, category: 'Haircut', description: 'Director styling & wash'),
        ],
        stylists: [
          Stylist(id: 'st1', name: 'Rahul', role: 'Senior Stylist', avatarUrl: '', rating: 4.9, status: StylistStatus.available, shiftHours: '10:00 AM - 7:00 PM'),
          Stylist(id: 'st2', name: 'Priya', role: 'Hair Specialist', avatarUrl: '', rating: 4.8, status: StylistStatus.withCustomer, shiftHours: '10:00 AM - 7:00 PM'),
          Stylist(id: 'st3', name: 'Amit', role: 'Stylist', avatarUrl: '', rating: 4.7, status: StylistStatus.available, shiftHours: '11:00 AM - 8:00 PM'),
          Stylist(id: 'st4', name: 'Neha', role: 'Color Expert', avatarUrl: '', rating: 4.6, status: StylistStatus.onBreak, shiftHours: '10:00 AM - 7:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'sl1', time: '11:15 AM', hourGroup: '11 AM', status: SlotStatus.available, price: 399, isEarliest: true, stylistName: 'Rahul'),
          LiveSlot(id: 'sl2', time: '11:30 AM', hourGroup: '11 AM', status: SlotStatus.available, price: 399, isEarliest: true, stylistName: 'Rahul'),
          LiveSlot(id: 'sl3', time: '11:40 AM', hourGroup: '11 AM', status: SlotStatus.available, price: 399, isRecommended: true, travelBufferMinutes: 13, stylistName: 'Rahul'),
          LiveSlot(id: 'sl4', time: '12:00 PM', hourGroup: '12 PM', status: SlotStatus.available, price: 399, stylistName: 'Amit'),
          LiveSlot(id: 'sl5', time: '12:30 PM', hourGroup: '12 PM', status: SlotStatus.limited, price: 399, stylistName: 'Neha'),
        ],
      ),
    ];

    _selectedSalon = _salons.first;

    _bookings = [
      Booking(
        id: 'bk_demo_1',
        salonId: 'salon_1',
        salonName: 'Looks Salon',
        serviceName: 'Haircut',
        servicePrice: 399,
        serviceDuration: 45,
        slotTime: '11:40 AM',
        date: 'Today, 27 Sep',
        distanceKm: 0.8,
        travelTimeMin: 8,
        stylistName: 'Rahul',
        customerName: 'Isha Nayal',
        customerPhone: '+91 00000 00000',
        status: AppointmentStatus.youAreNext,
        expectedWaitMin: '0-5 minutes',
        queuePosition: 1,
        estimatedStartTime: '11:43 AM',
      )
    ];

    _activeBooking = _bookings.first;
  }
}
