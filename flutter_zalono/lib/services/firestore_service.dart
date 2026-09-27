// Zalono Mock Sync Service (In-Memory / Offline First)
// Cloud Firestore integration can be enabled when google-services.json is added

import '../models/models.dart';

class ZalonoFirestoreService {
  // Stream bookings stub
  Stream<List<Booking>> streamBookings() {
    return Stream.value([]);
  }

  // Create new appointment stub
  Future<void> createBooking(Booking booking) async {
    // Stored in ZalonoProvider local state
  }

  // Update live appointment queue status stub
  Future<void> updateBookingStatus(String bookingId, AppointmentStatus status, int queuePosition) async {
    // Handled in ZalonoProvider
  }

  // Toggle slot availability stub
  Future<void> updateSlotStatus(String salonId, String slotId, SlotStatus status) async {
    // Handled in ZalonoProvider
  }
}
