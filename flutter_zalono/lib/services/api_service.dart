import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  /// Base URL of the Node API.
  ///
  /// On the web build the app and the API are served from the same origin
  /// (Express serves both), so the current host is used. This keeps the
  /// deployed site working on any Render domain without a rebuild, and avoids
  /// a hardcoded localhost that would break once deployed.
  ///
  /// Override with `--dart-define=API_BASE_URL=https://api.example.com/api`
  /// when the API lives on a different host.
  static String baseUrl = _defaultBaseUrl();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String _defaultBaseUrl() {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
        return '${Uri.base.scheme}://$host/api';
      }
      return 'http://127.0.0.1:5000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://127.0.0.1:5000/api';
  }

  static final http.Client _client = http.Client();

  /// Check backend availability
  static Future<bool> isBackendAvailable() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Fetch all salons from backend
  static Future<List<Salon>?> fetchSalons() async {
    try {
      final res = await _client.get(Uri.parse('$baseUrl/salons')).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((json) => _parseSalon(json)).toList();
      }
    } catch (e) {
      debugPrint('ApiService fetchSalons error: $e');
    }
    return null;
  }

  /// Create a new booking
  static Future<Booking?> createBooking({
    required String salonId,
    required String serviceId,
    required String slotId,
    String? stylistName,
    String? customerName,
    String? customerPhone,
  }) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'salonId': salonId,
          'serviceId': serviceId,
          'slotId': slotId,
          'stylistName': stylistName,
          'customerName': customerName,
          'customerPhone': customerPhone,
        }),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return _parseBooking(data);
      }
    } catch (e) {
      debugPrint('ApiService createBooking error: $e');
    }
    return null;
  }

  /// Toggle slot availability
  static Future<bool> toggleSlot(String salonId, String slotId) async {
    try {
      final res = await _client.patch(
        Uri.parse('$baseUrl/salons/$salonId/slots/$slotId/toggle'),
      ).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService toggleSlot error: $e');
      return false;
    }
  }

  /// Update stylist status
  static Future<bool> updateStylistStatus(String salonId, String stylistId, String status) async {
    try {
      final res = await _client.patch(
        Uri.parse('$baseUrl/salons/$salonId/stylists/$stylistId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService updateStylistStatus error: $e');
      return false;
    }
  }

  /// Advance booking queue status
  static Future<bool> advanceBooking(String bookingId) async {
    try {
      final res = await _client.patch(
        Uri.parse('$baseUrl/bookings/$bookingId/advance'),
      ).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService advanceBooking error: $e');
      return false;
    }
  }

  /// Add walk-in customer
  static Future<bool> addWalkIn({
    required String salonId,
    required String customerName,
    required String serviceName,
    required String stylistName,
    required int durationMin,
  }) async {
    try {
      final res = await _client.post(
        Uri.parse('$baseUrl/walk-ins'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'salonId': salonId,
          'customerName': customerName,
          'serviceName': serviceName,
          'stylistName': stylistName,
          'durationMin': durationMin,
        }),
      ).timeout(const Duration(seconds: 5));
      return res.statusCode == 201;
    } catch (e) {
      debugPrint('ApiService addWalkIn error: $e');
      return false;
    }
  }

  static Salon _parseSalon(Map<String, dynamic> json) {
    return Salon(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewsCount: json['reviewsCount'] ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 1.0,
      travelTimeMin: json['travelTimeMin'] ?? 10,
      address: json['address'] ?? '',
      area: json['area'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&q=80&w=800',
      priceStart: (json['priceStart'] as num?)?.toDouble() ?? 299,
      isOpen: json['isOpen'] ?? true,
      openingHours: json['openingHours'] ?? 'Open · Closes 9:00 PM',
      expectedWaitMin: json['expectedWaitMin'] ?? '0-5 min',
      nextSlotTime: json['nextSlotTime'] ?? '11:30 AM',
      queueCount: json['queueCount'] ?? 0,
      stylistsCount: json['stylistsCount'] ?? 1,
      availableStylistsCount: json['availableStylistsCount'] ?? 1,
      busyLevel: _parseBusyLevel(json['busyLevel']),
      isVerified: json['isVerified'] ?? true,
      happyCustomersCount: json['happyCustomersCount'] ?? '500+',
      gender: _parseSalonGender(json['gender']),
      phone: (json['phone'] ?? '').toString(),
      services: (json['services'] as List<dynamic>?)?.map((s) => ServiceItem(
        id: s['id'] ?? '',
        name: s['name'] ?? '',
        price: (s['price'] as num?)?.toDouble() ?? 0,
        durationMinutes: s['durationMinutes'] ?? 30,
        description: s['description'] ?? '',
        category: s['category'] ?? 'Haircut',
      )).toList() ?? [],
      stylists: (json['stylists'] as List<dynamic>?)?.map((st) => Stylist(
        id: st['id'] ?? '',
        name: st['name'] ?? '',
        role: st['role'] ?? '',
        avatarUrl: st['avatarUrl'] ?? '',
        rating: (st['rating'] as num?)?.toDouble() ?? 4.5,
        status: _parseStylistStatus(st['status']),
        shiftHours: st['shiftHours'] ?? '',
      )).toList() ?? [],
      slots: (json['slots'] as List<dynamic>?)?.map((sl) => LiveSlot(
        id: sl['id'] ?? '',
        time: sl['time'] ?? '',
        hourGroup: sl['hourGroup'] ?? '',
        status: _parseSlotStatus(sl['status']),
        price: (sl['price'] as num?)?.toDouble() ?? 0,
        isEarliest: sl['isEarliest'] ?? false,
        isRecommended: sl['isRecommended'] ?? false,
        travelBufferMinutes: sl['travelBufferMinutes'],
        stylistName: sl['stylistName'],
      )).toList() ?? [],
    );
  }

  static Booking _parseBooking(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      salonId: json['salonId'] ?? '',
      salonName: json['salonName'] ?? '',
      serviceName: json['serviceName'] ?? '',
      servicePrice: (json['servicePrice'] as num?)?.toDouble() ?? 0,
      serviceDuration: json['serviceDuration'] ?? 45,
      slotTime: json['slotTime'] ?? '',
      date: json['date'] ?? 'Today',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 1.0,
      travelTimeMin: json['travelTimeMin'] ?? 10,
      stylistName: json['stylistName'] ?? 'Rahul',
      customerName: json['customerName'] ?? 'Isha ',
      customerPhone: json['customerPhone'] ?? '',
      status: _parseAppointmentStatus(json['status']),
      expectedWaitMin: json['expectedWaitMin'] ?? '0-5 min',
      queuePosition: json['queuePosition'] ?? 1,
      estimatedStartTime: json['estimatedStartTime'] ?? '',
    );
  }

  static SalonGender _parseSalonGender(String? str) {
    switch (str?.toLowerCase()) {
      case 'male':
      case 'men':
        return SalonGender.male;
      case 'female':
      case 'women':
        return SalonGender.female;
      default:
        return SalonGender.unisex;
    }
  }

  static BusyLevel _parseBusyLevel(String? str) {
    switch (str?.toLowerCase()) {
      case 'quiet': return BusyLevel.quiet;
      case 'moderate': return BusyLevel.moderate;
      case 'busy': return BusyLevel.busy;
      default: return BusyLevel.quiet;
    }
  }

  static StylistStatus _parseStylistStatus(String? str) {
    switch (str?.toLowerCase()) {
      case 'available': return StylistStatus.available;
      case 'withcustomer': return StylistStatus.withCustomer;
      case 'onbreak': return StylistStatus.onBreak;
      case 'off': return StylistStatus.off;
      default: return StylistStatus.available;
    }
  }

  static SlotStatus _parseSlotStatus(String? str) {
    switch (str?.toLowerCase()) {
      case 'available': return SlotStatus.available;
      case 'limited': return SlotStatus.limited;
      case 'booked': return SlotStatus.booked;
      case 'blocked': return SlotStatus.blocked;
      default: return SlotStatus.available;
    }
  }

  static AppointmentStatus _parseAppointmentStatus(String? str) {
    switch (str?.toLowerCase()) {
      case 'booked': return AppointmentStatus.booked;
      case 'checkedin': return AppointmentStatus.checkedIn;
      case 'youarenext': return AppointmentStatus.youAreNext;
      case 'inservice': return AppointmentStatus.inService;
      case 'completed': return AppointmentStatus.completed;
      case 'cancelled': return AppointmentStatus.cancelled;
      default: return AppointmentStatus.booked;
    }
  }
}
