import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalono/providers/zalono_provider.dart';
import 'package:zalono/screens/consumer/consumer_profile_screen.dart';
import 'package:zalono/screens/consumer/edit_profile_screen.dart';
import 'package:zalono/screens/consumer/help_support_screen.dart';
import 'package:zalono/screens/consumer/payment_methods_screen.dart';
import 'package:zalono/screens/consumer/saved_locations_screen.dart';
import 'package:zalono/screens/consumer/signed_out_screen.dart';
import 'package:zalono/screens/consumer/terms_screen.dart';
import 'package:zalono/theme/app_theme.dart';

Future<ZalonoProvider> pumpProfile(
  WidgetTester tester,
  Widget screen,
  ZalonoProvider zalono,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: zalono,
      child: MaterialApp(theme: ZalonoTheme.lightTheme, home: screen),
    ),
  );
  await tester.pumpAndSettle();
  return zalono;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Profile has no placeholder screens left', () {
    testWidgets('every tile opens a real screen',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpProfile(tester, const ConsumerProfileScreen(), zalono);

      for (final tile in const [
        'Edit Profile',
        'Saved Locations',
        'Payment Methods',
        'Help & Support',
        'Terms & Agreement',
      ]) {
        expect(find.text(tile), findsOneWidget);
      }
      expect(find.text('Log Out'), findsOneWidget);

      // The placeholder message must not exist anywhere in the app.
      expect(
        find.textContaining('not part of this pilot build'),
        findsNothing,
      );
    });

    testWidgets('Edit Profile opens its own screen',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpProfile(tester, const ConsumerProfileScreen(), zalono);

      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileScreen), findsOneWidget);
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Mobile number'), findsOneWidget);
    });

    testWidgets('Log Out asks first, then shows the signed-out screen',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpProfile(tester, const ConsumerProfileScreen(), zalono);

      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      expect(find.text('Log Out?'), findsOneWidget);

      // Cancelling leaves the user signed in.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(zalono.isSignedIn, isTrue);

      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Log out'));
      await tester.pumpAndSettle();

      expect(find.byType(SignedOutScreen), findsOneWidget);
      expect(zalono.isSignedIn, isFalse);
    });
  });

  group('Edit Profile', () {
    testWidgets('saves the edited details to the provider',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpProfile(tester, const EditProfileScreen(), zalono);

      await tester.enterText(
        find.widgetWithText(TextField, 'Full name'),
        'Riya Kapoor',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Mobile number'),
        '9876543210',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(zalono.userName, 'Riya Kapoor');
      expect(zalono.userPhone, '9876543210');
    });

    testWidgets('rejects a short mobile number', (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpProfile(tester, const EditProfileScreen(), zalono);

      await tester.enterText(
        find.widgetWithText(TextField, 'Mobile number'),
        '12345',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.textContaining('valid 10-digit'), findsOneWidget);
    });

    // Regression: the Profile identity block used to be hardcoded, so edits
    // saved correctly but never showed up here.
    testWidgets('edits are reflected on the Profile screen',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpProfile(tester, const ConsumerProfileScreen(), zalono);

      expect(find.text('Isha '), findsOneWidget);
      expect(find.text(zalono.formattedPhone), findsOneWidget);

      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Full name'),
        'Riya Kapoor',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'riya.kapoor@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Mobile number'),
        '9876543210',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      // Back on Profile, every edited field is shown.
      expect(find.text('Riya Kapoor'), findsOneWidget);
      expect(find.text('riya.kapoor@example.com'), findsOneWidget);
      expect(find.text('+91 98765 43210'), findsOneWidget);
      expect(find.text('Isha '), findsNothing);
      // Avatar initials follow the new name.
      expect(find.text('RK'), findsOneWidget);
    });

    testWidgets('re-editing prefills the saved number without a doubled +91',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpProfile(tester, const EditProfileScreen(), zalono);

      final phoneField =
          tester.widget<TextField>(find.widgetWithText(TextField, 'Mobile number'));
      expect(phoneField.controller?.text, '9876543210');
    });
  });

  group('Saved Locations', () {
    testWidgets('lists saved addresses and adds a new one',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpProfile(tester, const SavedLocationsScreen(), zalono);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);

      await tester.tap(find.text('Add address'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Label (e.g. Home, Work)'),
        'Gym',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Full address'),
        'Sailendra Park, Bhubaneswar',
      );
      await tester.tap(find.text('Save address'));
      await tester.pumpAndSettle();

      expect(zalono.savedLocations.length, 3);
      expect(zalono.savedLocations.last.label, 'Gym');
      expect(zalono.savedLocations.last.address, 'Sailendra Park, Bhubaneswar');

      // The new card renders once it is scrolled into view.
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Gym'), findsOneWidget);
    });

    testWidgets('switching location also moves the active area',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpProfile(tester, const SavedLocationsScreen(), zalono);

      // Only the non-default card offers the action.
      await tester.tap(find.text('Use this location'));
      await tester.pumpAndSettle();

      // The chosen address becomes the active pilot area everywhere.
      expect(zalono.currentLocation, 'Bhubaneswar');
      expect(zalono.savedLocations.firstWhere((l) => l.isDefault).label, 'Work');
    });
  });

  group('Payment Methods', () {
    testWidgets('lists methods and adds a UPI id', (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpProfile(tester, const PaymentMethodsScreen(), zalono);

      expect(find.text('Isha.Nayal@upi'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);

      await tester.tap(find.text('Add method'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'UPI ID (e.g. name@bank)'),
        'riya@okaxis',
      );
      await tester.tap(find.text('Save method'));
      await tester.pumpAndSettle();

      expect(find.text('riya@okaxis'), findsOneWidget);
      expect(zalono.paymentMethods.length, 2);
    });

    testWidgets('can change the default method', (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      zalono.addPaymentMethod(type: 'UPI', label: 'second@upi');

      await pumpProfile(tester, const PaymentMethodsScreen(), zalono);
      await tester.tap(find.text('Set default'));
      await tester.pumpAndSettle();

      expect(zalono.paymentMethods.firstWhere((m) => m.isDefault).label,
          'second@upi');
    });
  });

  group('Help, Terms and signed-out', () {
    testWidgets('help screen shows contact options and FAQs',
        (WidgetTester tester) async {
      await pumpProfile(
        tester,
        const HelpSupportScreen(),
        ZalonoProvider(),
      );

      expect(find.text('Call support'), findsOneWidget);
      expect(find.text('Email us'), findsOneWidget);
      expect(find.text('How do I book an appointment?'), findsOneWidget);

      // FAQs expand to reveal the answer.
      await tester.tap(find.text('How do I book an appointment?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Pick a service'), findsOneWidget);
    });

    testWidgets('terms screen lists the agreement sections',
        (WidgetTester tester) async {
      await pumpProfile(tester, const TermsScreen(), ZalonoProvider());

      expect(find.textContaining('About this service'), findsOneWidget);
      expect(find.textContaining('Bookings'), findsOneWidget);

      // The closing line sits at the end of the document.
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(find.textContaining('By using Zalono you agree'), findsOneWidget);
    });

    testWidgets('signed-out screen signs the user back in',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      zalono.signOut();
      await pumpProfile(tester, const SignedOutScreen(), zalono);

      expect(find.text('You are signed out'), findsOneWidget);
      await tester.tap(find.text('Sign back in'));
      await tester.pumpAndSettle();

      expect(zalono.isSignedIn, isTrue);
    });
  });
}
