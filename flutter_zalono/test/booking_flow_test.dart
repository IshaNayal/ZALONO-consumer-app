import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalono/models/models.dart';
import 'package:zalono/providers/zalono_provider.dart';
import 'package:zalono/screens/consumer/booking_confirmation_screen.dart';
import 'package:zalono/screens/consumer/my_bookings_screen.dart';
import 'package:zalono/screens/consumer/payment_verification_screen.dart';
import 'package:zalono/screens/consumer/salon_detail_screen.dart';
import 'package:zalono/theme/app_theme.dart';
import 'package:zalono/components/common/consumer_notification_host.dart';

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  ZalonoProvider? provider,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => provider ?? ZalonoProvider(),
      child: MaterialApp(theme: ZalonoTheme.lightTheme, home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

/// Every string rendered on screen, for whole-page content assertions.
List<String> visibleText(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .toList();
}

/// Pulls the 6-digit demo OTP out of the banner the screen renders.
String demoOtpOnScreen(WidgetTester tester) {
  final banner = visibleText(tester).firstWhere((t) => t.contains('Demo build'));
  return RegExp(r'(\d{6})').firstMatch(banner)!.group(1)!;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Salon services page', () {
testWidgets('opens on services with a Book Now CTA',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpScreen(
        tester,
        SalonDetailScreen(salon: zalono.salons.first),
        provider: zalono,
      );

      expect(find.text('Select services'), findsOneWidget);
      expect(find.text('Haircut'), findsOneWidget);
      expect(find.text('Book Now'), findsOneWidget);
    });

    testWidgets('user can pick none, one, or many services',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      final salon = zalono.salons.first;
      await pumpScreen(
        tester,
        SalonDetailScreen(salon: salon),
        provider: zalono,
      );

      // None selected: the CTA is disabled and says so.
      expect(find.text('No services selected'), findsOneWidget);
      expect(find.text('Pick one or more to continue'), findsOneWidget);
      final bookButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Book Now'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(bookButton.onPressed, isNull);

      // One.
      await tester.tap(find.text(salon.services[0].name));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
      expect(
        find.textContaining('₹${salon.services[0].price.toInt()}'),
        findsWidgets,
      );

      // Two and three — selection accumulates.
      await tester.tap(find.text(salon.services[1].name));
      await tester.pumpAndSettle();
      expect(find.text('2 selected'), findsOneWidget);

      await tester.tap(find.text(salon.services[2].name));
      await tester.pumpAndSettle();
      expect(find.text('3 selected'), findsOneWidget);

      final total = salon.services
          .take(3)
          .fold<double>(0, (sum, s) => sum + s.price);
      expect(find.textContaining('₹${total.toInt()}'), findsWidgets);

      // Tapping again removes it.
      await tester.tap(find.text(salon.services[0].name));
      await tester.pumpAndSettle();
      expect(find.text('2 selected'), findsOneWidget);
    });

    testWidgets('book with several services sums price and duration',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      final salon = zalono.salons.first;
      final chosen = salon.services.take(2).toList();
      final before = zalono.bookings.length;

      await pumpScreen(
        tester,
        SalonDetailScreen(salon: salon),
        provider: zalono,
      );
      for (final service in chosen) {
        await tester.tap(find.text(service.name));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Book Now'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      final code = demoOtpOnScreen(tester);
      await tester.enterText(find.byType(TextField).last, code);
      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Pay ₹'));
      await tester.pumpAndSettle();

      expect(find.byType(BookingConfirmationScreen), findsOneWidget);
      expect(zalono.bookings.length, before + 1);

      final booking = zalono.bookings.first;
      // Names joined, prices and durations summed.
      expect(
        booking.serviceName,
        chosen.map((s) => s.name).join(' + '),
      );
      expect(
        booking.servicePrice,
        chosen.fold<double>(0, (sum, s) => sum + s.price),
      );
      expect(
        booking.serviceDuration,
        chosen.fold<int>(0, (sum, s) => sum + s.durationMinutes),
      );
    });

    testWidgets(
        'services list shows top services and expands on tapping explore more services',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      final salon = zalono.salons.first;
      await pumpScreen(
        tester,
        SalonDetailScreen(salon: salon),
        provider: zalono,
      );

      // Initially top services and the Explore More Services bar are shown.
      expect(find.text('Explore More Services'), findsOneWidget);
      expect(find.text(salon.services[0].name), findsOneWidget);
      expect(find.text(salon.services[1].name), findsOneWidget);
      expect(find.text(salon.services[2].name), findsOneWidget);

      // Tapping Explore More Services expands the remainder of the list.
      await tester.tap(find.text('Explore More Services'));
      await tester.pumpAndSettle();

      for (final service in salon.services) {
        expect(find.text(service.name), findsOneWidget);
      }
    });

    testWidgets('Book Now leads to payment/verification',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      final salon = zalono.salons.first;
      await pumpScreen(
        tester,
        SalonDetailScreen(salon: salon),
        provider: zalono,
      );

      // Needs at least one service before the CTA is live.
      await tester.tap(find.text(salon.services.first.name));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Book Now'));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentVerificationScreen), findsOneWidget);
      expect(find.text('Verify your mobile number'), findsOneWidget);
    });
  });

  group('Payment and verification', () {
    Future<ZalonoProvider> openPayment(WidgetTester tester) async {
      final zalono = ZalonoProvider();
      final salon = zalono.salons.first;
      await pumpScreen(
        tester,
        PaymentVerificationScreen(
          salon: salon,
          services: [salon.services.first],
          slot: salon.slots.first,
        ),
        provider: zalono,
      );
      return zalono;
    }

    testWidgets('rejects a wrong OTP and accepts the right one',
        (WidgetTester tester) async {
      await openPayment(tester);

      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();
      expect(find.text('Enter the OTP'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, '000000');
      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();
      expect(find.textContaining('not correct'), findsOneWidget);

      // Read the demo code the screen displays and use it.
      final code = demoOtpOnScreen(tester);
      await tester.enterText(find.byType(TextField).last, code);
      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Payment'), findsOneWidget);
    });

    testWidgets('successful payment confirms the booking automatically',
        (WidgetTester tester) async {
      final zalono = await openPayment(tester);
      final before = zalono.bookings.length;

      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();
      final code = demoOtpOnScreen(tester);
      await tester.enterText(find.byType(TextField).last, code);
      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Pay ₹'));
      await tester.pumpAndSettle();

      expect(find.byType(BookingConfirmationScreen), findsOneWidget);
      expect(zalono.bookings.length, before + 1);
      expect(zalono.activeBooking!.paymentStatus, PaymentStatus.paidUpi);
    });

    testWidgets('confirmation shows details and a Get Directions action',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      final booking = zalono.upcomingBookings.first;
      await pumpScreen(
        tester,
        BookingConfirmationScreen(booking: booking),
        provider: zalono,
      );

      expect(find.text('Booking Confirmed'), findsOneWidget);
      expect(find.text('Get Directions'), findsOneWidget);
      expect(find.text(booking.salonName), findsOneWidget);
      expect(find.textContaining(booking.serviceName), findsWidgets);
    });
  });

  group('Booking history', () {
    testWidgets('splits bookings into Upcoming and Past',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpScreen(tester, const MyBookingsScreen(), provider: zalono);

      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);
      // One card per booking, each showing salon + service + date + time.
      expect(find.text('Haircut + Beard'), findsOneWidget);
    });

    testWidgets('service and appointment time share one line',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpScreen(tester, const MyBookingsScreen(), provider: zalono);

      final booking = zalono.pastBookings.first;
      // Service and "date · time" sit on the same row.
      expect(
        find.text('${booking.date} · ${booking.slotTime}'),
        findsOneWidget,
      );

      final serviceY = tester.getTopLeft(find.text(booking.serviceName)).dy;
      final whenY = tester
          .getTopLeft(find.text('${booking.date} · ${booking.slotTime}'))
          .dy;
      expect((serviceY - whenY).abs(), lessThan(6));
    });

    testWidgets('cards offer support, message and call actions',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpScreen(tester, const MyBookingsScreen(), provider: zalono);

      expect(find.text('Customer Support'), findsWidgets);
      expect(find.text('Message Salon'), findsWidgets);
      expect(find.text('Call Salon'), findsWidgets);

      // The separate date and time rows are gone.
      expect(find.text('12 Sep'), findsNothing);
      expect(find.text('06:30 PM'), findsNothing);
    });

    testWidgets('seeded salons expose a contact number',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      for (final salon in zalono.salons) {
        expect(
          salon.phone.replaceAll(RegExp(r'\D'), '').length,
          greaterThanOrEqualTo(10),
        );
      }
    });

    testWidgets('shows a single empty state when there is no history',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider(seedDemoData: false);
      await pumpScreen(tester, const MyBookingsScreen(), provider: zalono);

      expect(find.text('No bookings yet'), findsOneWidget);
      expect(find.text('Upcoming'), findsNothing);
      expect(find.text('Past'), findsNothing);
    });
  });

  group('Notifications are shown at most once per booking', () {
    testWidgets('reminder appears once and never returns',
        (WidgetTester tester) async {
      final now = DateTime(2026, 3, 10, 10, 0);
      // A booking starting in 10 minutes, 8 minutes away: inside the window.
      final zalono = ZalonoProvider(now: () => now);
      zalono.upcomingBookings.first.startsAt =
          DateTime(2026, 3, 10, 10, 10);

      await pumpScreen(
        tester,
        const Column(children: [ConsumerNotificationHost()]),
        provider: zalono,
      );

      expect(find.text("It's almost time to leave"), findsOneWidget);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      // Consumed: the same booking must not prompt again.
      expect(find.text("It's almost time to leave"), findsNothing);
      expect(zalono.pendingDepartureReminder, isNull);
    });

    testWidgets('rating prompt appears once, and skipping also sticks',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider(now: () => DateTime(2026, 3, 10));
      await pumpScreen(
        tester,
        const Column(children: [ConsumerNotificationHost()]),
        provider: zalono,
      );

      expect(find.text('How was your experience?'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('How was your experience?'), findsNothing);
      expect(zalono.pendingRatingPrompt, isNull);
    });

    testWidgets('no prompt at all once the user has responded',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider(now: () => DateTime(2026, 3, 10));
      zalono.skipRating(zalono.pastBookings.first);

      await pumpScreen(
        tester,
        const Column(children: [ConsumerNotificationHost()]),
        provider: zalono,
      );

      expect(find.byType(ConsumerNotificationHost), findsOneWidget);
      expect(find.text('How was your experience?'), findsNothing);
    });
  });
}
