// Zalono Flutter Firebase Firestore Service
// Free Tier Firestore cloud sync for real-time salon slots and appointment queues

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class ZalonoFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream real-time bookings from Firestore
  Stream<List<Booking>> streamBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('bookedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Booking(
          id: doc.id,
          salonId: data['salonId'] ?? '',
          salonName: data['salonName'] ?? '',
          serviceName: data['serviceName'] ?? '',
          servicePrice: (data['servicePrice'] as num?)?.toDouble() ?? 399.0,
          serviceDuration: data['serviceDuration'] ?? 45,
          slotTime: data['slotTime'] ?? '',
          date: data['date'] ?? 'Today',
          distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0.8,
          travelTimeMin: data['travelTimeMin'] ?? 8,
          stylistName: data['stylistName'] ?? '',
          customerName: data['customerName'] ?? '',
          customerPhone: data['customerPhone'] ?? '',
          status: _parseStatus(data['status']),
          expectedWaitMin: data['expectedWaitMin'] ?? '0-5 min',
          queuePosition: data['queuePosition'] ?? 1,
          estimatedStartTime: data['estimatedStartTime'] ?? '',
        );
      }).toList();
    });
  }

  // Create new appointment in Firestore
  Future<void> createBooking(Booking booking) async {
    await _firestore.collection('bookings').doc(booking.id).set({
      'salonId': booking.salonId,
      'salonName': booking.salonName,
      'serviceName': booking.serviceName,
      'servicePrice': booking.servicePrice,
      'serviceDuration': booking.serviceDuration,
      'slotTime': booking.slotTime,
      'date': booking.date,
      'distanceKm': booking.distanceKm,
      'travelTimeMin': booking.travelTimeMin,
      'stylistName': booking.stylistName,
      'customerName': booking.customerName,
      'customerPhone': booking.customerPhone,
      'status': booking.status.name,
      'expectedWaitMin': booking.expectedWaitMin,
      'queuePosition': booking.queuePosition,
      'estimatedStartTime': booking.estimatedStartTime,
      'bookedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update live appointment queue status
  Future<void> updateBookingStatus(String bookingId, AppointmentStatus status, int queuePosition) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status.name,
      'queuePosition': queuePosition,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Toggle slot availability
  Future<void> updateSlotStatus(String salonId, String slotId, SlotStatus status) async {
    await _firestore.collection('salons').doc(salonId).update({
      'slots.$slotId.status': status.name,
    });
  }

  AppointmentStatus _parseStatus(String? status) {
    switch (status) {
      case 'checkedIn': return AppointmentStatus.checkedIn;
      case 'youAreNext': return AppointmentStatus.youAreNext;
      case 'inService': return AppointmentStatus.inService;
      case 'completed': return AppointmentStatus.completed;
      case 'cancelled': return AppointmentStatus.cancelled;
      default: return AppointmentStatus.booked;
    }
  }
}
