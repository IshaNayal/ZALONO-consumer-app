import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// Mobile number the booking is held against. Verified by OTP before the
  /// booking is confirmed. Stored as digits only; use [formattedPhone] to
  /// display it.
  String _userPhone = '9876543210';

  String _userName = 'Isha ';
  String _userEmail = 'ishanayal16@example.com';
  bool _isSignedIn = true;

  final List<SavedLocation> _savedLocations = [
    SavedLocation(
      id: 'loc_home',
      label: 'Home',
      address: 'Plot 42, Saheed Nagar, Janpath Road',
      isDefault: true,
    ),
    SavedLocation(
      id: 'loc_work',
      label: 'Work',
      address: 'DLF Tower, Janpath Road, Bhubaneswar',
    ),
  ];

  final List<SavedPaymentMethod> _paymentMethods = [
    SavedPaymentMethod(
      id: 'pm_upi',
      type: 'UPI',
      label: 'Isha.Nayal@upi',
      isDefault: true,
    ),
  ];

  /// Bookings that already got their one allowed pre-appointment reminder
  /// and/or rating prompt. Persisted so "once per booking" survives an app
  /// restart, not just a navigation change.
  final Set<String> _remindedBookings = {};
  final Set<String> _ratedBookings = {};

  /// Injectable clock so reminder timing is deterministic under test.
  final DateTime Function() _now;

  /// When false, no demo bookings are seeded — used to exercise the
  /// first-run / empty states.
  final bool _seedDemoData;

  /// Guards the async callbacks (shared_preferences reads, post-frame work)
  /// that can land after this notifier has been disposed.
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _notify() {
    if (_isDisposed) return;
    notifyListeners();
  }

  ZalonoProvider({DateTime Function()? now, bool seedDemoData = true})
      : _now = now ?? DateTime.now,
        _seedDemoData = seedDemoData {
    _initializeData();
    _checkAndSyncBackend();
    _loadNotificationState();
  }

  /// How many categories are shown inline before the "More" affordance.
  static const int _topCategoryCount = 6;

  static const String _prefsReminded = 'zalono.reminded_bookings';
  static const String _prefsRated = 'zalono.rated_bookings';


  /// Seeded locally for now. Swap for an API call (alongside
  /// [_checkAndSyncBackend]) when categories are served remotely; the UI
  /// already reads everything from here.
  final List<ServiceCategory> _categories = const [
    ServiceCategory(id: 'haircut', name: 'Haircut', iconKey: 'haircut'),
    ServiceCategory(id: 'hair_color', name: 'Hair Color', iconKey: 'color'),
    ServiceCategory(id: 'facial', name: 'Facial', iconKey: 'facial'),
    ServiceCategory(id: 'beard', name: 'Beard', iconKey: 'beard'),
    ServiceCategory(id: 'hair_spa', name: 'Hair Spa', iconKey: 'spa'),
    ServiceCategory(id: 'manicure', name: 'Manicure', iconKey: 'manicure'),
    ServiceCategory(id: 'pedicure', name: 'Pedicure', iconKey: 'pedicure'),
    ServiceCategory(id: 'head_massage', name: 'Head Massage', iconKey: 'massage'),
  ];

  bool get isBackendConnected => _isBackendConnected;

  Future<void> _checkAndSyncBackend() async {
    final available = await ApiService.isBackendAvailable();
    if (_isDisposed) return;
    _isBackendConnected = available;
    if (available) {
      final remoteSalons = await ApiService.fetchSalons();
      if (_isDisposed) return;
      if (remoteSalons != null && remoteSalons.isNotEmpty) {
        _salons = remoteSalons;
        if (_selectedSalon != null) {
          _selectedSalon = _salons.firstWhere((s) => s.id == _selectedSalon!.id, orElse: () => _salons.first);
        }
      }
    }
    _notify();
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

  List<ServiceCategory> get categories => _categories;

  String get userPhone => _userPhone;

  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isSignedIn => _isSignedIn;

  /// [userPhone] with the country code and spacing applied for display.
  String get formattedPhone => _formatPhoneDigits(_userPhone);

  /// Formats a 10-digit number as "+91 98765 43210"; anything else is
  /// returned as-is so seeded or already-formatted values stay intact.
  static String _formatPhoneDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) return raw.trim();
    return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
  }
  List<SavedLocation> get savedLocations =>
      List.unmodifiable(_savedLocations);
  List<SavedPaymentMethod> get paymentMethods =>
      List.unmodifiable(_paymentMethods);

  /// Updates the editable profile fields and re-verifies the phone so the
  /// booking flow asks for the new number's OTP next time.
  void updateProfile({required String name, required String email, required String phone}) {
    _userName = name.trim().isEmpty ? _userName : name.trim();
    _userEmail = email.trim().isEmpty ? _userEmail : email.trim();
    // Stored as digits only: the "+91" is presentation, so keeping it in the
    // value would render as "+91 +91 ..." on the next edit.
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isNotEmpty) _userPhone = digits;
    notifyListeners();
  }

  void addSavedLocation({required String label, required String address}) {
    _savedLocations.add(
      SavedLocation(
        id: 'loc_${DateTime.now().millisecondsSinceEpoch}',
        label: label.trim().isEmpty ? 'Address' : label.trim(),
        address: address.trim(),
      ),
    );
    notifyListeners();
  }

  void removeSavedLocation(String id) {
    _savedLocations.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  /// Makes a saved address the active one, so Home and the salon list follow
  /// it immediately.
  void useSavedLocation(String id) {
    final match = _savedLocations.firstWhere(
      (l) => l.id == id,
      orElse: () => _savedLocations.isEmpty
          ? SavedLocation(id: '', label: '', address: '')
          : _savedLocations.first,
    );
    if (match.id.isEmpty) return;
    for (final location in _savedLocations) {
      location.isDefault = location.id == id;
    }
    setLocation(_locationNameFromAddress(match.address));
    notifyListeners();
  }

  /// Saved addresses are free text, so the pilot area is derived from the last
  /// comma-separated segment (e.g. "... Janpath Road, Saheed Nagar").
  String _locationNameFromAddress(String address) {
    final parts = address.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return _currentLocation;
    return parts.last;
  }

  void addPaymentMethod({required String type, required String label}) {
    _paymentMethods.add(
      SavedPaymentMethod(
        id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        label: label.trim(),
      ),
    );
    notifyListeners();
  }

  void removePaymentMethod(String id) {
    _paymentMethods.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void useDefaultPaymentMethod(String id) {
    for (final method in _paymentMethods) {
      method.isDefault = method.id == id;
    }
    notifyListeners();
  }

  void signOut() {
    _isSignedIn = false;
    notifyListeners();
  }

  void signIn() {
    _isSignedIn = true;
    notifyListeners();
  }

  /// Bookings still ahead of the user.
  List<Booking> get upcomingBookings => _bookings
      .where((b) =>
          b.status != AppointmentStatus.completed &&
          b.status != AppointmentStatus.cancelled)
      .toList(growable: false);

  /// Bookings already finished or cancelled.
  List<Booking> get pastBookings => _bookings
      .where((b) =>
          b.status == AppointmentStatus.completed ||
          b.status == AppointmentStatus.cancelled)
      .toList(growable: false);

  /// Categories shown inline on the Home page. The remainder are reachable
  /// through the "More" affordance in [CategorySection].
  List<ServiceCategory> get topCategories =>
      _categories.take(_topCategoryCount).toList(growable: false);

  bool get hasMoreCategories => _categories.length > _topCategoryCount;

  /// Salons that belong to the currently selected pilot area.
  ///
  /// Matching is done on [Salon.area] so the same filter works for the bundled
  /// mock data and for salons hydrated from the backend via [ApiService].
  /// Deliberately returns an empty list (rather than falling back to every
  /// salon) when an area has no coverage, so unrelated salons are never shown.
  List<Salon> get salonsForCurrentLocation {
    final needle = _currentLocation.trim().toLowerCase();
    if (needle.isEmpty) return const [];
    return _salons
        .where((salon) => salon.area.toLowerCase().contains(needle))
        .toList(growable: false);
  }

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

  /// Puts a booking on hold ahead of payment/OTP verification.
  ///
  /// The booking is created but stays [AppointmentStatus.booked] with a
  /// [PaymentStatus.pending] payment; [confirmBooking] flips it to confirmed
  /// once the mobile number has been verified.
  Booking holdBooking({
    required Salon salon,
    required LiveSlot seat,
    required List<ServiceItem> services,
    String? stylistName,
    String? phone,
  }) {
    final chosenStylist = stylistName ?? seat.stylistName ?? salon.stylists.first.name;

    seat.status = SlotStatus.booked;

    // Several services collapse into the booking's flat fields: names joined,
    // prices and durations summed. Keeps the booking record and the API shape
    // unchanged for the pilot.
    final names = services.map((s) => s.name).join(' + ');
    final totalPrice =
        services.fold<double>(0, (sum, s) => sum + s.price);
    final totalDuration =
        services.fold<int>(0, (sum, s) => sum + s.durationMinutes);

    final newBooking = Booking(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      salonId: salon.id,
      salonName: salon.name,
      serviceName: names,
      servicePrice: totalPrice,
      serviceDuration: totalDuration,
      slotTime: seat.time,
      date: _formatDateLabel(_now()),
      distanceKm: salon.distanceKm,
      travelTimeMin: salon.travelTimeMin,
      stylistName: chosenStylist,
      customerName: 'Isha Nayal',
      customerPhone: _formatPhoneDigits(phone ?? _userPhone),
      status: AppointmentStatus.booked,
      expectedWaitMin: '0-5 minutes',
      queuePosition: 1,
      estimatedStartTime: seat.time,
      startsAt: _resolveStart(seat.time),
    );

    _bookings.insert(0, newBooking);
    _activeBooking = newBooking;
    notifyListeners();
    return newBooking;
  }

  /// Completes an in-flight booking after OTP + payment succeeded.
  void confirmBooking(Booking booking, {String? phone}) {
    if (phone != null && phone.isNotEmpty) {
      _userPhone = phone;
    }
    booking.status = AppointmentStatus.booked;
    booking.paymentStatus = PaymentStatus.paidUpi;
    _activeBooking = booking;
    notifyListeners();
  }

  void setUserPhone(String phone) {
    _userPhone = phone;
    notifyListeners();
  }

  /// Existing entry point, kept so the partner/legacy call sites still work.
  /// Delegates to the hold + confirm pair.
  void bookSlot({
    required Salon salon,
    required LiveSlot seat,
    required ServiceItem service,
    String? stylistName,
  }) {
    final booking = holdBooking(
      salon: salon,
      seat: seat,
      services: [service],
      stylistName: stylistName,
    );
    confirmBooking(booking);
  }

  static String _formatDateLabel(DateTime now) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return 'Today, ${now.day} ${months[now.month - 1]}';
  }

  /// Turns a "11:40 AM" style seat label into a concrete time today, or null
  /// when the label cannot be parsed.
  DateTime? _resolveStart(String slotLabel) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(slotLabel.trim());
    if (match == null) return null;

    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final isPm = match.group(3)!.toUpperCase() == 'PM';
    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    final now = _now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // ---------------------------------------------------------------------------
  // Consumer notifications: at most one reminder before the appointment and one
  // rating prompt after it, ever. Nothing here repeats per booking.
  // ---------------------------------------------------------------------------

  /// How long before the appointment the single "time to leave" reminder fires.
  static const int _reminderLeadMinutes = 30;

  /// The one booking that should show a "time to leave" reminder right now, or
  /// null when there is nothing to say.
  ///
  /// Uses the salon's recommended travel time so the reminder lands when the
  /// user actually needs to set off. Returns a booking only once â€” the caller
  /// must hand it to [markReminderShown] for it to be consumed.
  Booking? get pendingDepartureReminder {
    if (_dismissedPromptId != null) {
      // A reminder is being shown right now; don't queue another.
      return null;
    }
    final now = _now();
    for (final booking in upcomingBookings) {
      final startsAt = booking.startsAt;
      if (startsAt == null) continue;
      if (_remindedBookings.contains(booking.id)) continue;

      final leaveBy = startsAt.subtract(
        Duration(minutes: booking.travelTimeMin + _reminderLeadMinutes),
      );
      final isNow = !now.isBefore(leaveBy) && now.isBefore(startsAt);
      if (isNow) return booking;
    }
    return null;
  }

  /// Id of the booking whose prompt is currently on screen, so the host does
  /// not stack a second prompt while the first is up.
  String? _dismissedPromptId;

  /// The one completed booking awaiting a rating prompt, or null.
  Booking? get pendingRatingPrompt {
    if (_dismissedPromptId != null) return null;
    for (final booking in pastBookings) {
      if (booking.status != AppointmentStatus.completed) continue;
      if (_ratedBookings.contains(booking.id)) continue;
      return booking;
    }
    return null;
  }

  void markReminderShown(Booking booking) {
    _remindedBookings.add(booking.id);
    _dismissedPromptId = booking.id;
    _persistNotificationState();
    notifyListeners();
  }

  /// User tapped "Rate Now" â€” the prompt must not appear again.
  void markRated(Booking booking) {
    _ratedBookings.add(booking.id);
    _dismissedPromptId = null;
    _persistNotificationState();
    notifyListeners();
  }

  /// User tapped "Skip" â€” the prompt must not come back, including on the
  /// next app launch.
  void skipRating(Booking booking) {
    _ratedBookings.add(booking.id);
    _dismissedPromptId = null;
    _persistNotificationState();
    notifyListeners();
  }

  /// Clears the in-session "currently showing" latch. Called when a prompt is
  /// dismissed by the host widget.
  void releaseNotificationLatch() {
    if (_dismissedPromptId == null) return;
    _dismissedPromptId = null;
    _notify();
  }

  Future<void> _loadNotificationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isDisposed) return;
      _remindedBookings
          .addAll(prefs.getStringList(_prefsReminded) ?? const <String>[]);
      _ratedBookings.addAll(prefs.getStringList(_prefsRated) ?? const <String>[]);
      _notify();
    } catch (_) {
      // Persistence is a convenience for "once per booking"; if unavailable the
      // in-memory sets still enforce it for the current session.
    }
  }

  Future<void> _persistNotificationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsReminded, _remindedBookings.toList());
      await prefs.setStringList(_prefsRated, _ratedBookings.toList());
    } catch (_) {
      // Ignore: see _loadNotificationState.
    }
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
        for (var seat in salon.slots) {
          if (seat.id == slotId) {
            seat.status = seat.status == SlotStatus.available 
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
        openingHours: 'Open Â· Closes 9:00 PM',
        expectedWaitMin: '0-5 min',
        nextSlotTime: '11:30 AM',
        queueCount: 3,
        stylistsCount: 4,
        availableStylistsCount: 2,
        busyLevel: BusyLevel.quiet,
        isVerified: true,
        happyCustomersCount: '1000+',
        gender: SalonGender.unisex,
        phone: '9876543210',
        services: [
          const ServiceItem(id: 's1', name: 'Haircut', price: 399, durationMinutes: 45, category: 'Haircut', description: 'Consultation & Precision cut'),
          const ServiceItem(id: 's2', name: 'Haircut + Beard', price: 599, durationMinutes: 60, category: 'Haircut', description: 'Cut with hot towel shape'),
          const ServiceItem(id: 's3', name: 'Premium Haircut', price: 799, durationMinutes: 60, category: 'Haircut', description: 'Director styling & wash'),
          const ServiceItem(id: 's4', name: 'Hair Spa', price: 899, durationMinutes: 75, category: 'Hair Spa', description: 'Wash, massage & shine treatment'),
          const ServiceItem(id: 's5', name: 'Facial', price: 749, durationMinutes: 50, category: 'Facial', description: 'Cleanse, exfoliate & hydrate'),
          const ServiceItem(id: 's6', name: 'Global Hair Color', price: 1349, durationMinutes: 90, category: 'Hair Color', description: 'Ammonia-free colour with gloss'),
          const ServiceItem(id: 's7', name: 'Beard Sculpt & Shape', price: 299, durationMinutes: 30, category: 'Beard', description: 'Hot towel shape & line-up'),
          const ServiceItem(id: 's8', name: 'Classic Manicure', price: 599, durationMinutes: 40, category: 'Manicure', description: 'Shape, cuticle care & polish'),
          const ServiceItem(id: 's9', name: 'Deluxe Pedicure', price: 799, durationMinutes: 50, category: 'Pedicure', description: 'Soak, exfoliation & foot massage'),
          const ServiceItem(id: 's10', name: 'Stress-Relief Head Massage', price: 649, durationMinutes: 35, category: 'Head Massage', description: 'Warm herbal oil relaxation'),
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

      // Demo coverage so the gender filter has something to act on: one
      // men-only, one women-only and one more unisex salon in Saheed Nagar.
      // Replace with real listings from the backend.
      Salon(
        id: 'salon_2',
        name: 'The Men’s Studio',
        rating: 4.5,
        reviewsCount: 189,
        distanceKm: 1.2,
        travelTimeMin: 12,
        address: 'Plot 18, Saheed Nagar, Janpath Road',
        area: 'Saheed Nagar, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&q=80&w=800',
        priceStart: 349,
        isOpen: true,
        openingHours: 'Open · Closes 9:00 PM',
        expectedWaitMin: '5-10 min',
        nextSlotTime: '12:15 PM',
        queueCount: 1,
        stylistsCount: 2,
        availableStylistsCount: 2,
        busyLevel: BusyLevel.quiet,
        isVerified: true,
        happyCustomersCount: '600+',
        gender: SalonGender.male,
        phone: '9876501111',
        services: const [
          ServiceItem(id: 'm1', name: 'Men’s Haircut', price: 349, durationMinutes: 40, category: 'Haircut', description: 'Precision cut & wash'),
          ServiceItem(id: 'm2', name: 'Beard Trim', price: 249, durationMinutes: 25, category: 'Beard', description: 'Shape & finish'),
        ],
        stylists: [
          Stylist(id: 'mst1', name: 'Arjun', role: 'Senior Stylist', avatarUrl: '', rating: 4.6, status: StylistStatus.available, shiftHours: '10:00 AM - 8:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'msl1', time: '12:15 PM', hourGroup: '12 PM', status: SlotStatus.available, price: 349, stylistName: 'Arjun'),
          LiveSlot(id: 'msl2', time: '1:00 PM', hourGroup: '1 PM', status: SlotStatus.available, price: 349, stylistName: 'Arjun'),
        ],
      ),
      Salon(
        id: 'salon_3',
        name: 'Belle Beauty Parlour',
        rating: 4.8,
        reviewsCount: 412,
        distanceKm: 0.6,
        travelTimeMin: 7,
        address: 'Plot 7, Saheed Nagar, Janpath Road',
        area: 'Saheed Nagar, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?auto=format&fit=crop&q=80&w=800',
        priceStart: 549,
        isOpen: true,
        openingHours: 'Open · Closes 8:00 PM',
        expectedWaitMin: '10-15 min',
        nextSlotTime: '11:50 AM',
        queueCount: 2,
        stylistsCount: 3,
        availableStylistsCount: 1,
        busyLevel: BusyLevel.moderate,
        isVerified: true,
        happyCustomersCount: '900+',
        gender: SalonGender.female,
        phone: '9876502222',
        services: const [
          ServiceItem(id: 'w1', name: 'Facial', price: 749, durationMinutes: 50, category: 'Facial', description: 'Cleanse, exfoliate & hydrate'),
          ServiceItem(id: 'w2', name: 'Hair Spa', price: 899, durationMinutes: 75, category: 'Hair Spa', description: 'Wash, massage & shine'),
          ServiceItem(id: 'w3', name: 'Manicure', price: 649, durationMinutes: 45, category: 'Manicure', description: 'Shape, cuticle care & polish'),
          ServiceItem(id: 'w4', name: 'Spa Pedicure', price: 749, durationMinutes: 45, category: 'Pedicure', description: 'Soak, scrub & foot massage'),
          ServiceItem(id: 'w5', name: 'Aromatherapy Head Massage', price: 699, durationMinutes: 40, category: 'Head Massage', description: 'Deep relaxation therapy'),
        ],
        stylists: [
          Stylist(id: 'wst1', name: 'Meera', role: 'Beauty Expert', avatarUrl: '', rating: 4.9, status: StylistStatus.available, shiftHours: '10:00 AM - 8:00 PM'),
          Stylist(id: 'wst2', name: 'Kavya', role: 'Hair Stylist', avatarUrl: '', rating: 4.7, status: StylistStatus.withCustomer, shiftHours: '11:00 AM - 8:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'wsl1', time: '11:50 AM', hourGroup: '11 AM', status: SlotStatus.available, price: 749, stylistName: 'Meera'),
          LiveSlot(id: 'wsl2', time: '2:30 PM', hourGroup: '2 PM', status: SlotStatus.limited, price: 649, stylistName: 'Kavya'),
        ],
      ),
      Salon(
        id: 'salon_4',
        name: 'Style Studio Unisex',
        rating: 4.3,
        reviewsCount: 96,
        distanceKm: 1.9,
        travelTimeMin: 18,
        address: 'Plot 55, Saheed Nagar, Near Flyover',
        area: 'Saheed Nagar, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&q=80&w=800',
        priceStart: 299,
        isOpen: true,
        openingHours: 'Open · Closes 9:00 PM',
        expectedWaitMin: '5-10 min',
        nextSlotTime: '1:45 PM',
        queueCount: 0,
        stylistsCount: 2,
        availableStylistsCount: 1,
        busyLevel: BusyLevel.quiet,
        isVerified: false,
        happyCustomersCount: '300+',
        gender: SalonGender.unisex,
        phone: '9876503333',
        services: const [
          ServiceItem(id: 'u1', name: 'Haircut', price: 299, durationMinutes: 40, category: 'Haircut', description: 'Classic cut for everyone'),
          ServiceItem(id: 'u2', name: 'Head Massage', price: 399, durationMinutes: 30, category: 'Head Massage', description: 'Relaxing oil massage'),
          ServiceItem(id: 'u3', name: 'Global Hair Color', price: 1099, durationMinutes: 80, category: 'Hair Color', description: 'Ammonia-free colour & gloss'),
          ServiceItem(id: 'u4', name: 'Beard Trim & Shape', price: 249, durationMinutes: 25, category: 'Beard', description: 'Even it out'),
          ServiceItem(id: 'u5', name: 'Hair Spa', price: 849, durationMinutes: 60, category: 'Hair Spa', description: 'Wash, massage & shine'),
        ],
        stylists: [
          Stylist(id: 'ust1', name: 'Riya', role: 'Stylist', avatarUrl: '', rating: 4.4, status: StylistStatus.available, shiftHours: '11:00 AM - 9:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'usl1', time: '1:45 PM', hourGroup: '1 PM', status: SlotStatus.available, price: 299, stylistName: 'Riya'),
        ],
      ),

      // One salon past the 2 km mark, so the distance filter visibly narrows
      // the list instead of matching every seeded salon.
      Salon(
        id: 'salon_5',
        name: 'Glow Spa & Salon',
        rating: 4.6,
        reviewsCount: 143,
        distanceKm: 3.4,
        travelTimeMin: 26,
        address: 'Plot 12, Nayapalli, Bhubaneswar',
        area: 'Saheed Nagar, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&q=80&w=800',
        priceStart: 649,
        isOpen: true,
        openingHours: 'Open · Closes 9:00 PM',
        expectedWaitMin: '10-15 min',
        nextSlotTime: '2:00 PM',
        queueCount: 2,
        stylistsCount: 3,
        availableStylistsCount: 2,
        busyLevel: BusyLevel.moderate,
        isVerified: true,
        happyCustomersCount: '700+',
        gender: SalonGender.female,
        phone: '9876504444',
        services: [
          const ServiceItem(id: 'g1', name: 'Deep Tissue Massage', price: 999, durationMinutes: 60, category: 'Head Massage', description: 'Relaxing full-body massage'),
          const ServiceItem(id: 'g2', name: 'Clean-up Facial', price: 599, durationMinutes: 45, category: 'Facial', description: 'Gentle cleanse and hydrate'),
          const ServiceItem(id: 'g3', name: 'Classic Manicure', price: 549, durationMinutes: 40, category: 'Manicure', description: 'Shape & polish'),
          const ServiceItem(id: 'g4', name: 'Deluxe Pedicure', price: 749, durationMinutes: 50, category: 'Pedicure', description: 'Soak & foot massage'),
          const ServiceItem(id: 'g5', name: 'Hair Spa Ritual', price: 999, durationMinutes: 70, category: 'Hair Spa', description: 'Repair & shine treatment'),
        ],
        stylists: [
          Stylist(id: 'gst1', name: 'Ananya', role: 'Spa Therapist', avatarUrl: '', rating: 4.8, status: StylistStatus.available, shiftHours: '10:00 AM - 8:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'gsl1', time: '2:00 PM', hourGroup: '2 PM', status: SlotStatus.available, price: 999, stylistName: 'Ananya'),
        ],
      ),

      // Wider pilot coverage. Each of these carries services across several
      // categories so that opening, say, the Beard page lists more than the
      // one or two salons that used to have a Beard service. Replace with real
      // listings from the backend.
      Salon(
        id: 'salon_6',
        name: 'Crown Unisex Salon',
        rating: 4.4,
        reviewsCount: 154,
        distanceKm: 2.2,
        travelTimeMin: 17,
        address: 'Plot 88, Saheed Nagar, Near IOC Office',
        area: 'Saheed Nagar, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?auto=format&fit=crop&q=80&w=800',
        priceStart: 379,
        isOpen: true,
        openingHours: 'Open · Closes 9:00 PM',
        expectedWaitMin: '5-10 min',
        nextSlotTime: '1:20 PM',
        queueCount: 2,
        stylistsCount: 3,
        availableStylistsCount: 2,
        busyLevel: BusyLevel.quiet,
        isVerified: true,
        happyCustomersCount: '500+',
        gender: SalonGender.unisex,
        phone: '9876505555',
        services: const [
          ServiceItem(id: 'c1', name: 'Classic Haircut', price: 379, durationMinutes: 40, category: 'Haircut', description: 'Consultation, cut & wash'),
          ServiceItem(id: 'c2', name: 'Global Hair Color', price: 1249, durationMinutes: 85, category: 'Hair Color', description: 'Ammonia-free global colour'),
          ServiceItem(id: 'c3', name: 'Beard Sculpt', price: 299, durationMinutes: 30, category: 'Beard', description: 'Shape, line-up & hot towel'),
          ServiceItem(id: 'c4', name: 'Clean-up Facial', price: 649, durationMinutes: 45, category: 'Facial', description: 'Gentle cleanse & hydrate'),
          ServiceItem(id: 'c5', name: 'Spa Pedicure', price: 749, durationMinutes: 45, category: 'Pedicure', description: 'Soak, scrub & massage'),
          ServiceItem(id: 'c6', name: 'Hair Spa', price: 949, durationMinutes: 60, category: 'Hair Spa', description: 'Wash, massage & shine'),
        ],
        stylists: [
          Stylist(id: 'cst1', name: 'Sandeep', role: 'Senior Stylist', avatarUrl: '', rating: 4.5, status: StylistStatus.available, shiftHours: '10:00 AM - 8:00 PM'),
          Stylist(id: 'cst2', name: 'Ritika', role: 'Color Expert', avatarUrl: '', rating: 4.6, status: StylistStatus.available, shiftHours: '11:00 AM - 8:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'csl1', time: '1:20 PM', hourGroup: '1 PM', status: SlotStatus.available, price: 379, stylistName: 'Sandeep'),
          LiveSlot(id: 'csl2', time: '1:40 PM', hourGroup: '1 PM', status: SlotStatus.available, price: 1249, isRecommended: true, travelBufferMinutes: 12, stylistName: 'Ritika'),
        ],
      ),
      Salon(
        id: 'salon_7',
        name: 'Aroma Beauty Lounge',
        rating: 4.7,
        reviewsCount: 268,
        distanceKm: 1.4,
        travelTimeMin: 14,
        address: 'Plot 23, Saheed Nagar, Near Flyover',
        area: 'Saheed Nagar, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?auto=format&fit=crop&q=80&w=800',
        priceStart: 599,
        isOpen: true,
        openingHours: 'Open · Closes 8:00 PM',
        expectedWaitMin: '10-15 min',
        nextSlotTime: '12:30 PM',
        queueCount: 3,
        stylistsCount: 4,
        availableStylistsCount: 1,
        busyLevel: BusyLevel.moderate,
        isVerified: true,
        happyCustomersCount: '800+',
        gender: SalonGender.female,
        phone: '9876506666',
        services: const [
          ServiceItem(id: 'a1', name: 'Brightening Facial', price: 799, durationMinutes: 55, category: 'Facial', description: 'Vitamin-C glow & hydration'),
          ServiceItem(id: 'a2', name: 'Nourishing Hair Spa', price: 899, durationMinutes: 60, category: 'Hair Spa', description: 'Scalp massage & shine treatment'),
          ServiceItem(id: 'a3', name: 'Gel Manicure', price: 599, durationMinutes: 40, category: 'Manicure', description: 'Shape, cuticle care & polish'),
          ServiceItem(id: 'a4', name: 'Deluxe Pedicure', price: 799, durationMinutes: 50, category: 'Pedicure', description: 'Soak, exfoliation & foot massage'),
          ServiceItem(id: 'a5', name: 'Aromatherapy Head Massage', price: 799, durationMinutes: 40, category: 'Head Massage', description: 'Deep relaxation therapy'),
        ],
        stylists: [
          Stylist(id: 'ast1', name: 'Sneha', role: 'Beauty Expert', avatarUrl: '', rating: 4.8, status: StylistStatus.available, shiftHours: '10:00 AM - 8:00 PM'),
          Stylist(id: 'ast2', name: 'Pooja', role: 'Nail Artist', avatarUrl: '', rating: 4.7, status: StylistStatus.withCustomer, shiftHours: '11:00 AM - 8:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'asl1', time: '12:30 PM', hourGroup: '12 PM', status: SlotStatus.available, price: 799, stylistName: 'Sneha'),
          LiveSlot(id: 'asl2', time: '3:15 PM', hourGroup: '3 PM', status: SlotStatus.available, price: 899, isRecommended: true, travelBufferMinutes: 15, stylistName: 'Sneha'),
        ],
      ),
      Salon(
        id: 'salon_8',
        name: 'Royal Touch Salon',
        rating: 4.2,
        reviewsCount: 87,
        distanceKm: 2.6,
        travelTimeMin: 21,
        address: 'Unit 9, Patia, Near KIIT Gate 2',
        area: 'Patia, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?auto=format&fit=crop&q=80&w=800',
        priceStart: 449,
        isOpen: true,
        openingHours: 'Open · Closes 9:00 PM',
        expectedWaitMin: '15-20 min',
        nextSlotTime: '2:45 PM',
        queueCount: 4,
        stylistsCount: 3,
        availableStylistsCount: 1,
        busyLevel: BusyLevel.busy,
        isVerified: false,
        happyCustomersCount: '250+',
        gender: SalonGender.unisex,
        phone: '9876507777',
        services: const [
          ServiceItem(id: 'r1', name: 'Signature Haircut', price: 449, durationMinutes: 45, category: 'Haircut', description: 'Precision cut & styling'),
          ServiceItem(id: 'r2', name: 'Root Touch-Up', price: 949, durationMinutes: 60, category: 'Hair Color', description: 'Seamless root coverage'),
          ServiceItem(id: 'r3', name: 'Facial', price: 699, durationMinutes: 50, category: 'Facial', description: 'Cleanse, exfoliate & hydrate'),
          ServiceItem(id: 'r4', name: 'Beard Trim', price: 299, durationMinutes: 25, category: 'Beard', description: 'Shape & finish'),
          ServiceItem(id: 'r5', name: 'Classic Manicure', price: 549, durationMinutes: 40, category: 'Manicure', description: 'Shape, cuticle care & polish'),
          ServiceItem(id: 'r6', name: 'Hair Spa', price: 899, durationMinutes: 60, category: 'Hair Spa', description: 'Wash, massage & shine'),
        ],
        stylists: [
          Stylist(id: 'rst1', name: 'Manoj', role: 'Stylist', avatarUrl: '', rating: 4.2, status: StylistStatus.available, shiftHours: '11:00 AM - 9:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'rsl1', time: '2:45 PM', hourGroup: '2 PM', status: SlotStatus.limited, price: 449, stylistName: 'Manoj'),
        ],
      ),
      Salon(
        id: 'salon_9',
        name: 'Men’s Kraft Barbershop',
        rating: 4.6,
        reviewsCount: 231,
        distanceKm: 0.9,
        travelTimeMin: 9,
        address: 'Plot 61, Saheed Nagar, Janpath Road',
        area: 'Saheed Nagar, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=800',
        priceStart: 299,
        isOpen: true,
        openingHours: 'Open · Closes 9:00 PM',
        expectedWaitMin: '0-5 min',
        nextSlotTime: '12:00 PM',
        queueCount: 1,
        stylistsCount: 3,
        availableStylistsCount: 3,
        busyLevel: BusyLevel.quiet,
        isVerified: true,
        happyCustomersCount: '650+',
        gender: SalonGender.male,
        phone: '9876508888',
        services: const [
          ServiceItem(id: 'k1', name: 'Skin Fade', price: 299, durationMinutes: 40, category: 'Haircut', description: 'Sharp fade & beard line'),
          ServiceItem(id: 'k2', name: 'Beard Trim & Shape', price: 249, durationMinutes: 25, category: 'Beard', description: 'Razor edge detailing'),
          ServiceItem(id: 'k3', name: 'Head Massage', price: 349, durationMinutes: 30, category: 'Head Massage', description: 'Warm oil pressure-point relief'),
        ],
        stylists: [
          Stylist(id: 'kst1', name: 'Vikram', role: 'Senior Barber', avatarUrl: '', rating: 4.7, status: StylistStatus.available, shiftHours: '10:00 AM - 9:00 PM'),
          Stylist(id: 'kst2', name: 'Rakesh', role: 'Barber', avatarUrl: '', rating: 4.5, status: StylistStatus.available, shiftHours: '11:00 AM - 9:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'ksl1', time: '12:00 PM', hourGroup: '12 PM', status: SlotStatus.available, price: 299, isEarliest: true, stylistName: 'Vikram'),
          LiveSlot(id: 'ksl2', time: '12:30 PM', hourGroup: '12 PM', status: SlotStatus.available, price: 299, isRecommended: true, travelBufferMinutes: 10, stylistName: 'Rakesh'),
        ],
      ),
      Salon(
        id: 'salon_10',
        name: 'Colour Splash Salon',
        rating: 4.5,
        reviewsCount: 176,
        distanceKm: 1.7,
        travelTimeMin: 16,
        address: 'Plot 9, Nayapalli, Near CRPF Road',
        area: 'Nayapalli, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1562322140-8baeececf3df?auto=format&fit=crop&q=80&w=800',
        priceStart: 899,
        isOpen: true,
        openingHours: 'Open · Closes 8:00 PM',
        expectedWaitMin: '10-15 min',
        nextSlotTime: '1:00 PM',
        queueCount: 2,
        stylistsCount: 3,
        availableStylistsCount: 2,
        busyLevel: BusyLevel.moderate,
        isVerified: true,
        happyCustomersCount: '700+',
        gender: SalonGender.female,
        phone: '9876509999',
        services: const [
          ServiceItem(id: 'cs1', name: 'Fashion Hair Color', price: 1399, durationMinutes: 90, category: 'Hair Color', description: 'Trend-led global colour'),
          ServiceItem(id: 'cs2', name: 'Hair Spa Ritual', price: 949, durationMinutes: 60, category: 'Hair Spa', description: 'Repair & shine treatment'),
          ServiceItem(id: 'cs3', name: 'Brightening Facial', price: 899, durationMinutes: 55, category: 'Facial', description: 'Glow & hydration pack'),
        ],
        stylists: [
          Stylist(id: 'csst1', name: 'Nisha', role: 'Color Expert', avatarUrl: '', rating: 4.8, status: StylistStatus.available, shiftHours: '10:00 AM - 8:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'cssl1', time: '1:00 PM', hourGroup: '1 PM', status: SlotStatus.available, price: 1399, stylistName: 'Nisha'),
          LiveSlot(id: 'cssl2', time: '2:00 PM', hourGroup: '2 PM', status: SlotStatus.available, price: 949, isRecommended: true, travelBufferMinutes: 14, stylistName: 'Nisha'),
        ],
      ),
      Salon(
        id: 'salon_11',
        name: 'Serenity Spa & Wellness',
        rating: 4.8,
        reviewsCount: 356,
        distanceKm: 1.1,
        travelTimeMin: 12,
        address: 'Plot 30, Saheed Nagar, Near SBI Square',
        area: 'Saheed Nagar, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&q=80&w=800',
        priceStart: 1099,
        isOpen: true,
        openingHours: 'Open · Closes 9:00 PM',
        expectedWaitMin: '10-15 min',
        nextSlotTime: '12:20 PM',
        queueCount: 3,
        stylistsCount: 5,
        availableStylistsCount: 2,
        busyLevel: BusyLevel.moderate,
        isVerified: true,
        happyCustomersCount: '1200+',
        gender: SalonGender.unisex,
        phone: '9876510000',
        services: const [
          ServiceItem(id: 'p1', name: 'Luxury Spa Ritual', price: 1099, durationMinutes: 75, category: 'Hair Spa', description: 'Full-head therapy & steam'),
          ServiceItem(id: 'p2', name: 'Gold Facial', price: 1199, durationMinutes: 60, category: 'Facial', description: 'Luxury glow & lifting'),
          ServiceItem(id: 'p3', name: 'Classic Manicure', price: 599, durationMinutes: 40, category: 'Manicure', description: 'Nourish, shape & polish'),
          ServiceItem(id: 'p4', name: 'Deluxe Pedicure', price: 899, durationMinutes: 55, category: 'Pedicure', description: 'Soak, scrub & reflexology'),
          ServiceItem(id: 'p5', name: 'Aromatherapy Head Massage', price: 749, durationMinutes: 45, category: 'Head Massage', description: 'Deep relaxation therapy'),
          ServiceItem(id: 'p6', name: 'Beard Grooming', price: 399, durationMinutes: 30, category: 'Beard', description: 'Hot towel shape & conditioning'),
        ],
        stylists: [
          Stylist(id: 'pst1', name: 'Aditi', role: 'Spa Therapist', avatarUrl: '', rating: 4.9, status: StylistStatus.available, shiftHours: '10:00 AM - 9:00 PM'),
          Stylist(id: 'pst2', name: 'Tara', role: 'Skin Specialist', avatarUrl: '', rating: 4.8, status: StylistStatus.withCustomer, shiftHours: '10:00 AM - 9:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'psl1', time: '12:20 PM', hourGroup: '12 PM', status: SlotStatus.available, price: 1099, stylistName: 'Aditi'),
          LiveSlot(id: 'psl2', time: '1:30 PM', hourGroup: '1 PM', status: SlotStatus.available, price: 1199, isRecommended: true, travelBufferMinutes: 13, stylistName: 'Tara'),
        ],
      ),
      Salon(
        id: 'salon_12',
        name: 'Trim & Shine Studio',
        rating: 4.1,
        reviewsCount: 74,
        distanceKm: 3.1,
        travelTimeMin: 24,
        address: 'Plot 44, Patia, Near Infocity Road',
        area: 'Patia, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&q=80&w=800',
        priceStart: 329,
        isOpen: true,
        openingHours: 'Open · Closes 8:00 PM',
        expectedWaitMin: '20-25 min',
        nextSlotTime: '4:00 PM',
        queueCount: 5,
        stylistsCount: 2,
        availableStylistsCount: 1,
        busyLevel: BusyLevel.busy,
        isVerified: false,
        happyCustomersCount: '180+',
        gender: SalonGender.unisex,
        phone: '9876511111',
        services: const [
          ServiceItem(id: 't1', name: 'Regular Haircut', price: 329, durationMinutes: 35, category: 'Haircut', description: 'Trim, wash & tidy'),
          ServiceItem(id: 't2', name: 'Beard Trim', price: 199, durationMinutes: 20, category: 'Beard', description: 'Even it out'),
          ServiceItem(id: 't3', name: 'Global Hair Color', price: 1149, durationMinutes: 80, category: 'Hair Color', description: 'Ammonia-free colour'),
          ServiceItem(id: 't4', name: 'Hair Spa', price: 799, durationMinutes: 55, category: 'Hair Spa', description: 'Wash, massage & shine'),
          ServiceItem(id: 't5', name: 'Classic Manicure', price: 499, durationMinutes: 35, category: 'Manicure', description: 'Shape & polish'),
          ServiceItem(id: 't6', name: 'Head Massage', price: 349, durationMinutes: 30, category: 'Head Massage', description: 'Relaxing oil massage'),
        ],
        stylists: [
          Stylist(id: 'tst1', name: 'Deepak', role: 'Stylist', avatarUrl: '', rating: 4.1, status: StylistStatus.available, shiftHours: '11:00 AM - 8:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'tsl1', time: '4:00 PM', hourGroup: '4 PM', status: SlotStatus.limited, price: 329, stylistName: 'Deepak'),
        ],
      ),
      Salon(
        id: 'salon_13',
        name: 'Glow & Grace Parlour',
        rating: 4.3,
        reviewsCount: 128,
        distanceKm: 1.5,
        travelTimeMin: 15,
        address: 'Plot 71, Nayapalli, Near Nayapalli Square',
        area: 'Nayapalli, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1519699047748-de8e457a634e?auto=format&fit=crop&q=80&w=800',
        priceStart: 649,
        isOpen: true,
        openingHours: 'Open · Closes 8:00 PM',
        expectedWaitMin: '10-15 min',
        nextSlotTime: '2:10 PM',
        queueCount: 2,
        stylistsCount: 3,
        availableStylistsCount: 2,
        busyLevel: BusyLevel.quiet,
        isVerified: true,
        happyCustomersCount: '400+',
        gender: SalonGender.female,
        phone: '9876512222',
        services: const [
          ServiceItem(id: 'gg1', name: 'Facial', price: 649, durationMinutes: 50, category: 'Facial', description: 'Cleanse, exfoliate & hydrate'),
          ServiceItem(id: 'gg2', name: 'Classic Manicure', price: 599, durationMinutes: 40, category: 'Manicure', description: 'Shape, cuticle care & polish'),
          ServiceItem(id: 'gg3', name: 'Hair Color & Highlights', price: 1199, durationMinutes: 85, category: 'Hair Color', description: 'Global colour & gloss'),
          ServiceItem(id: 'gg4', name: 'Spa Pedicure', price: 699, durationMinutes: 45, category: 'Pedicure', description: 'Soak, scrub & massage'),
        ],
        stylists: [
          Stylist(id: 'ggst1', name: 'Lakshmi', role: 'Beauty Expert', avatarUrl: '', rating: 4.4, status: StylistStatus.available, shiftHours: '10:00 AM - 8:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'ggsl1', time: '2:10 PM', hourGroup: '2 PM', status: SlotStatus.available, price: 649, stylistName: 'Lakshmi'),
        ],
      ),
      Salon(
        id: 'salon_14',
        name: 'The Barber Collective',
        rating: 4.7,
        reviewsCount: 302,
        distanceKm: 2.0,
        travelTimeMin: 19,
        address: 'Plot 12, Saheed Nagar, Near Market',
        area: 'Saheed Nagar, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1622286342621-4bd858c1933b?auto=format&fit=crop&q=80&w=800',
        priceStart: 399,
        isOpen: true,
        openingHours: 'Open · Closes 9:00 PM',
        expectedWaitMin: '5-10 min',
        nextSlotTime: '12:50 PM',
        queueCount: 2,
        stylistsCount: 4,
        availableStylistsCount: 2,
        busyLevel: BusyLevel.quiet,
        isVerified: true,
        happyCustomersCount: '950+',
        gender: SalonGender.male,
        phone: '9876513333',
        services: const [
          ServiceItem(id: 'b1', name: 'Textured Crop', price: 399, durationMinutes: 40, category: 'Haircut', description: 'Modern crop & finish'),
          ServiceItem(id: 'b2', name: 'Full Beard Sculpt', price: 349, durationMinutes: 30, category: 'Beard', description: 'Shape, line-up & oil'),
          ServiceItem(id: 'b3', name: 'Scalp Massage', price: 399, durationMinutes: 30, category: 'Head Massage', description: 'Warm herbal oil relief'),
          ServiceItem(id: 'b4', name: 'Grey Blending', price: 899, durationMinutes: 60, category: 'Hair Color', description: 'Natural-looking coverage'),
          ServiceItem(id: 'b5', name: 'Hair Spa', price: 899, durationMinutes: 60, category: 'Hair Spa', description: 'Wash, massage & shine'),
        ],
        stylists: [
          Stylist(id: 'bst1', name: 'Imran', role: 'Senior Barber', avatarUrl: '', rating: 4.8, status: StylistStatus.available, shiftHours: '10:00 AM - 9:00 PM'),
          Stylist(id: 'bst2', name: 'Suresh', role: 'Barber', avatarUrl: '', rating: 4.6, status: StylistStatus.onBreak, shiftHours: '11:00 AM - 9:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'bsl1', time: '12:50 PM', hourGroup: '12 PM', status: SlotStatus.available, price: 399, stylistName: 'Imran'),
          LiveSlot(id: 'bsl2', time: '1:10 PM', hourGroup: '1 PM', status: SlotStatus.available, price: 349, isRecommended: true, travelBufferMinutes: 15, stylistName: 'Suresh'),
        ],
      ),
      Salon(
        id: 'salon_15',
        name: 'Velvet Touch Salon',
        rating: 4.0,
        reviewsCount: 63,
        distanceKm: 4.2,
        travelTimeMin: 31,
        address: 'Plot 5, Chandrasekharpur, Near NH-16',
        area: 'Chandrasekharpur, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1633681926022-84c23e8cb2d6?auto=format&fit=crop&q=80&w=800',
        priceStart: 499,
        isOpen: true,
        openingHours: 'Open · Closes 9:00 PM',
        expectedWaitMin: '15-20 min',
        nextSlotTime: '3:30 PM',
        queueCount: 3,
        stylistsCount: 2,
        availableStylistsCount: 1,
        busyLevel: BusyLevel.moderate,
        isVerified: false,
        happyCustomersCount: '150+',
        gender: SalonGender.unisex,
        phone: '9876514444',
        services: const [
          ServiceItem(id: 'v1', name: 'Haircut', price: 499, durationMinutes: 45, category: 'Haircut', description: 'Consultation & cut'),
          ServiceItem(id: 'v2', name: 'Highlights', price: 1499, durationMinutes: 90, category: 'Hair Color', description: 'Partial highlights & gloss'),
          ServiceItem(id: 'v3', name: 'Facial', price: 699, durationMinutes: 50, category: 'Facial', description: 'Cleanse & hydrate'),
          ServiceItem(id: 'v4', name: 'Manicure', price: 549, durationMinutes: 40, category: 'Manicure', description: 'Shape & polish'),
          ServiceItem(id: 'v5', name: 'Beard Trim', price: 299, durationMinutes: 25, category: 'Beard', description: 'Shape & finish'),
          ServiceItem(id: 'v6', name: 'Spa Pedicure', price: 749, durationMinutes: 45, category: 'Pedicure', description: 'Soak & foot massage'),
          ServiceItem(id: 'v7', name: 'Hair Spa', price: 849, durationMinutes: 60, category: 'Hair Spa', description: 'Wash, massage & shine'),
        ],
        stylists: [
          Stylist(id: 'vst1', name: 'Rajat', role: 'Stylist', avatarUrl: '', rating: 4.0, status: StylistStatus.available, shiftHours: '11:00 AM - 9:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'vsl1', time: '3:30 PM', hourGroup: '3 PM', status: SlotStatus.available, price: 499, stylistName: 'Rajat'),
        ],
      ),
      Salon(
        id: 'salon_16',
        name: 'Nitty Gritty Nails',
        rating: 4.6,
        reviewsCount: 197,
        distanceKm: 2.8,
        travelTimeMin: 22,
        address: 'Shop 4, Patia, Near Infocity Square',
        area: 'Patia, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1604654894610-df63bc536371?auto=format&fit=crop&q=80&w=800',
        priceStart: 549,
        isOpen: true,
        openingHours: 'Open · Closes 8:00 PM',
        expectedWaitMin: '10-15 min',
        nextSlotTime: '2:00 PM',
        queueCount: 2,
        stylistsCount: 3,
        availableStylistsCount: 2,
        busyLevel: BusyLevel.quiet,
        isVerified: true,
        happyCustomersCount: '600+',
        gender: SalonGender.female,
        phone: '9876515555',
        services: const [
          ServiceItem(id: 'n1', name: 'Classic Manicure', price: 549, durationMinutes: 40, category: 'Manicure', description: 'Shape, cuticle care & polish'),
          ServiceItem(id: 'n2', name: 'Spa Pedicure', price: 749, durationMinutes: 45, category: 'Pedicure', description: 'Soak, exfoliation & massage'),
          ServiceItem(id: 'n3', name: 'Express Facial', price: 549, durationMinutes: 35, category: 'Facial', description: 'Quick cleanse & glow'),
        ],
        stylists: [
          Stylist(id: 'nst1', name: 'Divya', role: 'Nail Artist', avatarUrl: '', rating: 4.7, status: StylistStatus.available, shiftHours: '10:00 AM - 8:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'nsl1', time: '2:00 PM', hourGroup: '2 PM', status: SlotStatus.available, price: 549, isRecommended: true, stylistName: 'Divya'),
        ],
      ),
      Salon(
        id: 'salon_17',
        name: 'Scalp Science Clinic',
        rating: 4.9,
        reviewsCount: 421,
        distanceKm: 0.5,
        travelTimeMin: 6,
        address: 'Plot 3, Saheed Nagar, Near College Square',
        area: 'Saheed Nagar, Bhubaneswar',
        imageUrl: 'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?auto=format&fit=crop&q=80&w=800',
        priceStart: 1299,
        isOpen: true,
        openingHours: 'Open · Closes 8:00 PM',
        expectedWaitMin: '10-15 min',
        nextSlotTime: '12:15 PM',
        queueCount: 3,
        stylistsCount: 4,
        availableStylistsCount: 2,
        busyLevel: BusyLevel.moderate,
        isVerified: true,
        happyCustomersCount: '1500+',
        gender: SalonGender.unisex,
        phone: '9876516666',
        services: const [
          ServiceItem(id: 'sc1', name: 'Scalp Diagnostic Haircut', price: 1299, durationMinutes: 75, category: 'Haircut', description: 'Scalp analysis & precision cut'),
          ServiceItem(id: 'sc2', name: 'Advanced Hair Color', price: 1699, durationMinutes: 95, category: 'Hair Color', description: 'Ammonia-free colour correction'),
          ServiceItem(id: 'sc3', name: 'Therapeutic Hair Spa', price: 1299, durationMinutes: 70, category: 'Hair Spa', description: 'Clinical scalp therapy'),
          ServiceItem(id: 'sc4', name: 'Stress-Relief Head Massage', price: 899, durationMinutes: 45, category: 'Head Massage', description: 'Pressure-point therapy'),
          ServiceItem(id: 'sc5', name: 'Beard Sculpt', price: 449, durationMinutes: 35, category: 'Beard', description: 'Precision shape & line-up'),
          ServiceItem(id: 'sc6', name: 'Classic Manicure', price: 699, durationMinutes: 45, category: 'Manicure', description: 'Shape, cuticle care & polish'),
          ServiceItem(id: 'sc7', name: 'Spa Pedicure', price: 899, durationMinutes: 50, category: 'Pedicure', description: 'Soak, exfoliation & massage'),
        ],
        stylists: [
          Stylist(id: 'scst1', name: 'Dr. Ishaan', role: 'Scalp Specialist', avatarUrl: '', rating: 4.9, status: StylistStatus.available, shiftHours: '10:00 AM - 8:00 PM'),
        ],
        slots: [
          LiveSlot(id: 'scsl1', time: '12:15 PM', hourGroup: '12 PM', status: SlotStatus.available, price: 1299, isEarliest: true, stylistName: 'Dr. Ishaan'),
          LiveSlot(id: 'scsl2', time: '12:45 PM', hourGroup: '12 PM', status: SlotStatus.available, price: 1299, isRecommended: true, travelBufferMinutes: 9, stylistName: 'Dr. Ishaan'),
        ],
      ),
    ];

    _selectedSalon = _salons.first;

    _bookings = _seedDemoData
        ? [
            Booking(
        id: 'bk_demo_1',
        salonId: 'salon_1',
        salonName: 'Looks Salon',
        serviceName: 'Haircut',
        servicePrice: 399,
        serviceDuration: 45,
        slotTime: '11:40 AM',
        date: _formatDateLabel(_now()),
        distanceKm: 0.8,
        travelTimeMin: 8,
        stylistName: 'Rahul',
        customerName: 'Isha Nayal',
        customerPhone: '+91 00000 00000',
        status: AppointmentStatus.booked,
        expectedWaitMin: '0-5 minutes',
        queuePosition: 1,
        estimatedStartTime: '11:43 AM',
        paymentStatus: PaymentStatus.paidUpi,
        // A few hours out, so it reads as an upcoming appointment.
        startsAt: _now().add(const Duration(hours: 4)),
      ),
      Booking(
        id: 'bk_demo_past',
        salonId: 'salon_1',
        salonName: 'Looks Salon',
        serviceName: 'Haircut + Beard',
        servicePrice: 599,
        serviceDuration: 60,
        slotTime: '06:30 PM',
        date: '12 Sep',
        distanceKm: 0.8,
        travelTimeMin: 8,
        stylistName: 'Priya',
        customerName: 'Isha Nayal',
        customerPhone: '+91 00000 00000',
        status: AppointmentStatus.completed,
        expectedWaitMin: '0-5 minutes',
        queuePosition: 0,
        estimatedStartTime: '06:30 PM',
        paymentStatus: PaymentStatus.paidUpi,
        // Last week, so it reads as history.
        startsAt: _now().subtract(const Duration(days: 7)),
      ),
          ]
        : <Booking>[];

    _activeBooking = _bookings.isEmpty ? null : _bookings.first;
  }
}
