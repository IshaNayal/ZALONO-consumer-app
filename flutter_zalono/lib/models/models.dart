// Zalono Flutter Models
// Real-time seat booking, live queue position, and partner salon management

enum BusyLevel { quiet, moderate, busy }
enum SlotStatus { available, limited, booked, blocked }
enum AppointmentStatus { booked, checkedIn, youAreNext, inService, completed, cancelled }
enum PaymentStatus { paidSalon, paidUpi, pending }
enum StylistStatus { available, withCustomer, onBreak, off }

/// Who a salon serves. Used by the gender filter on the consumer side.
enum SalonGender {
  male('Men'),
  female('Women'),
  unisex('Unisex');

  const SalonGender(this.label);

  /// Display label, kept on the enum so the UI never hardcodes it.
  final String label;
}

/// A top-level service category surfaced on the Home page.
///
/// `iconKey` is a semantic identifier rather than an IconData so this model
/// stays free of Flutter UI imports and can be populated from the API later
/// without the UI hardcoding labels or icons.
class ServiceCategory {
  final String id;
  final String name;
  final String iconKey;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.iconKey,
  });
}

/// A user-saved address the customer can book around.
class SavedLocation {
  final String id;
  final String label;
  final String address;

  /// Mutable so [ZalonoProvider.useSavedLocation] can move the default flag.
  bool isDefault;

  SavedLocation({
    required this.id,
    required this.label,
    required this.address,
    this.isDefault = false,
  });
}

/// A saved payment instrument, shown on the Payment Methods screen.
class SavedPaymentMethod {
  final String id;
  final String type;
  final String label;

  /// Mutable so [ZalonoProvider.useDefaultPaymentMethod] can move the flag.
  bool isDefault;

  SavedPaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    this.isDefault = false,
  });
}

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

  /// Who this salon serves; drives the gender filter.
  final SalonGender gender;

  /// Contact number for call/message actions, digits only (no country code).
  final String phone;

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
    this.gender = SalonGender.unisex,
    this.phone = '',
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

  /// Concrete appointment start, used to time the single pre-appointment
  /// reminder. Null for bookings that come from the API without a parseable
  /// time, in which case no reminder is scheduled.
  DateTime? startsAt;

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
    this.startsAt,
  });
}
