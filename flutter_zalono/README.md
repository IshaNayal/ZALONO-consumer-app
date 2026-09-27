# Zalono - Real-Time Salon Booking & Live Slots (Flutter & Dart)

> **"Look Your Best. Without Waiting."**
> Modern, availability-first salon booking app built with Flutter 3.x and Dart.

---

## 📱 App Highlights & Architecture

### 1. Consumer Journey
- **Personalized Home**: Immediate visibility into live openings near you (Bhubaneswar, etc.) with real-time wait estimates and quick 1-tap rebooking of usual salons.
- **Fastest Slot Selection**: Travel-time calculation engine with automatic buffer times (e.g., 8 min travel + 5 min buffer = recommended 11:40 AM slot).
- **Salon Detail & Live Slots Matrix**: 4-Tab availability breakdown across 10 AM, 11 AM, 12 PM, 1 PM, 2 PM with color-coded live statuses:
  - 🟢 **Available** (Instant booking)
  - 🟡 **Limited** (Few slots left)
  - 🔴 **Booked** (Locked)
- **Live Appointment Tracking**: Stepper progress tracker with live queue position (Position: 1, Estimated start, On-Time verification, message & call salon).
- **Payment & Feedback**: Flexible payment (Pay at Salon or UPI) + 5-star rating with on-time prompt and instant rebooking reminders.

### 2. Partner Journey (Salon Owners & Staff)
- **Real-Time Salon Dashboard**: Appointments, expected revenue, walk-ins, and available slots at a glance.
- **Interactive Slot Manager**: Open or close slots on the fly with instant propagation to the customer app.
- **Walk-in Queue Manager**: Add in-store walk-in clients directly to the queue to keep digital wait times accurate.
- **Stylist Management**: Real-time status toggling (Available, With Customer, On Break).

---

## 🚀 Running the Flutter App

### Prerequisites
- Flutter SDK `>= 3.16.0`
- Dart SDK `>= 3.2.0`
- iOS Simulator / Android Emulator / Physical Device or Chrome

### Steps
```bash
# 1. Navigate to the flutter project directory
cd flutter_zalono

# 2. Get dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Folder Structure
```
flutter_zalono/
├── pubspec.yaml
├── lib/
│   ├── main.dart                      # App entry point & shell navigation
│   ├── theme/
│   │   └── app_theme.dart             # Zalono brand colors (Burgundy, Emerald, Cream)
│   ├── models/
│   │   └── models.dart                # Salon, LiveSlot, Booking, Stylist models
│   ├── providers/
│   │   └── zalono_provider.dart       # ChangeNotifier state management
│   ├── screens/
│   │   ├── consumer/
│   │   │   ├── home_screen.dart       # Availability-first customer home
│   │   │   ├── salon_detail_screen.dart # Live slot timeline & booking
│   │   │   └── live_appointment_screen.dart # Queue tracker & on-time status
│   │   └── partner/
│   │       ├── partner_dashboard_screen.dart # Salon owner stats & staff
│   │       └── manage_slots_screen.dart      # Real-time slot management
│   └── widgets/
│       └── smart_slot_badge.dart
```
