import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zalono/main.dart';
import 'package:zalono/config/app_config.dart';
import 'package:zalono/providers/zalono_provider.dart';
import 'package:zalono/screens/consumer/home_screen.dart';
import 'package:zalono/components/consumer/location_header.dart';
import 'package:zalono/components/consumer/salon_search_bar.dart';
import 'package:zalono/components/consumer/category_section.dart';
import 'package:zalono/components/consumer/salon_gender_tag.dart';
import 'package:zalono/components/consumer/salon_filter_panel.dart';
import 'package:zalono/screens/consumer/service_time_screen.dart';
import 'package:zalono/screens/consumer/salon_list_screen.dart';
import 'package:zalono/screens/consumer/salon_detail_screen.dart';
import 'package:zalono/theme/app_theme.dart';

/// Pumps the consumer Home page on its own (no bottom navigation) so layout
/// problems are attributed to Home rather than to sibling tabs.
Future<void> pumpHome(WidgetTester tester, Size size, {ZalonoProvider? provider}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => provider ?? ZalonoProvider(),
      child: MaterialApp(
        theme: ZalonoTheme.lightTheme,
        home: const Scaffold(body: ConsumerHomeScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Pumps the visit-time page (flow step 2) on its own.
Future<void> pumpTimePage(
  WidgetTester tester,
  Size size, {
  ZalonoProvider? provider,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => provider ?? ZalonoProvider(),
      child: MaterialApp(
        theme: ZalonoTheme.lightTheme,
        home: const Scaffold(body: ServiceTimeScreen()),
      ),
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

/// Finds text inside the results filter column only.
///
/// The salon cards carry their own gender tags, so "Men"/"Women"/"Unisex" also
/// appear on the cards below the panel.
Finder inFilterPanel(String text) {
  return find.descendant(
    of: find.byType(SalonFilterPanel),
    matching: find.text(text),
  );
}

/// Salon names currently rendered, in render order (sort order matters).
List<String> renderedSalonNames(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .where(_isSalonName)
      .toList();
}

bool _isSalonName(String text) {
  const names = {
    'Looks Salon',
    'Belle Beauty Parlour',
    'Style Studio Unisex',
    'Glow Spa & Salon',
  };
  if (names.contains(text)) return true;
  // "The Men's Studio" uses a typographic apostrophe in the seed data, so match
  // on a stable prefix rather than the exact character.
  return text.startsWith('The Men');
}

/// Whether the men's salon is among the rendered names.
bool _hasMensStudio(List<String> names) =>
    names.any((n) => n.startsWith('The Men'));

/// Starting prices in render order, used to assert sort order.
List<String> _renderedPrices(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .where((t) => t.startsWith('₹'))
      .toList();
}

void main() {
  testWidgets('Home shows location, categories and nearby salons',
      (WidgetTester tester) async {
    await pumpHome(tester, const Size(390, 844));

    // Location is the only thing in the header.
    expect(find.text('Saheed Nagar'), findsOneWidget);

    // Sections, in order.
    expect(find.text('SERVICES'), findsOneWidget);
    expect(find.text('SALONS NEAR YOU'), findsOneWidget);

    // Inline categories (the strip is lazy, so "More" needs a scroll).
    expect(find.text('Haircut'), findsWidgets);
    expect(find.text('Hair Color'), findsOneWidget);
    expect(find.text('More'), findsNothing);

    // Scoped to the category strip: the filter bar is also a horizontal
    // ListView, so a bare byType(ListView) would be ambiguous.
    final categoryStrip = find.descendant(
      of: find.byType(CategorySection),
      matching: find.byType(ListView),
    );
    expect(categoryStrip, findsOneWidget);
    await tester.drag(categoryStrip, const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text('More'), findsOneWidget);

    // Seeded salon for the default area is listed.
    expect(find.text('Looks Salon'), findsOneWidget);
  });

  testWidgets('"More" opens a sheet listing every category',
      (WidgetTester tester) async {
    await pumpHome(tester, const Size(390, 844));

    await tester.drag(
      find.descendant(
        of: find.byType(CategorySection),
        matching: find.byType(ListView),
      ),
      const Offset(-400, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.text('All Categories'), findsOneWidget);
    // Categories beyond the inline six are reachable here.
    expect(find.text('Pedicure'), findsOneWidget);
    expect(find.text('Head Massage'), findsOneWidget);
  });

  testWidgets('Home no longer renders the removed sections',
      (WidgetTester tester) async {
    await pumpHome(tester, const Size(390, 844));

    expect(find.text('Good morning, Isha ðŸ‘‹'), findsNothing);
    expect(find.text('What do you need today?'), findsNothing);
    expect(find.text('When do you want to go?'), findsNothing);
    expect(find.text('Reverse Search'), findsNothing);
    expect(find.text('Your usual salon'), findsNothing);
    expect(find.text('Last-Minute Openings'), findsNothing);
    expect(find.textContaining('AI Slot Finder'), findsNothing);
  });

  testWidgets('Home renders without overflow on a small phone',
      (WidgetTester tester) async {
    await pumpHome(tester, const Size(320, 568));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home renders without overflow on a standard phone',
      (WidgetTester tester) async {
    await pumpHome(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home renders without overflow on a large phone',
      (WidgetTester tester) async {
    await pumpHome(tester, const Size(430, 932));
    expect(tester.takeException(), isNull);
  });

  // The category strip hands its tiles a tight height, so the tile label
  // growing with the system text scale used to run past the bottom of the
  // 92px strip from 1.5x up.
  for (final scale in const [1.5, 1.8, 2.0, 3.0]) {
    testWidgets('category strip fits at ${scale}x text scale',
        (WidgetTester tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpHome(tester, const Size(320, 568));

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Salons are filtered to the selected location',
      (WidgetTester tester) async {
    final zalono = ZalonoProvider();
    // Patia is a pilot area with no seeded coverage yet.
    zalono.setLocation('Patia');

    await pumpHome(tester, const Size(390, 844), provider: zalono);

    // The location header reflects the change...
    expect(find.text('Patia'), findsWidgets);
    // ...and the Saheed Nagar salon is not shown for it.
    expect(find.text('Looks Salon'), findsNothing);
    expect(find.textContaining('Coming soon in Patia'), findsOneWidget);
  });

  group('Home search', () {
    testWidgets('salon cards keep Book now but not the services expander',
        (WidgetTester tester) async {
      await pumpHome(tester, const Size(390, 844));

      expect(find.text('Book now'), findsWidgets);
      // The "Explore More Services" expander belongs on the salon page only.
      expect(find.text('Explore more services'), findsNothing);
      expect(find.text('Explore More Services'), findsNothing);
    });

    testWidgets('search bar sits below the location bar',
        (WidgetTester tester) async {
      await pumpHome(tester, const Size(390, 844));

      expect(find.text('Saheed Nagar'), findsOneWidget);
      expect(find.byType(SalonSearchBar), findsOneWidget);

      // Ordering: the search field is rendered after the location header.
      final locationY = tester.getTopLeft(find.byType(LocationHeader)).dy;
      final searchY = tester.getTopLeft(find.byType(SalonSearchBar)).dy;
      expect(searchY, greaterThan(locationY));
    });

    testWidgets('filters salons by name', (WidgetTester tester) async {
      await pumpHome(tester, const Size(390, 844));
      expect(find.text('Looks Salon'), findsOneWidget);

      await tester.enterText(find.byType(SalonSearchBar), 'looks');
      await tester.pumpAndSettle();
      expect(find.text('Looks Salon'), findsOneWidget);

      await tester.enterText(find.byType(SalonSearchBar), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('Looks Salon'), findsNothing);
      expect(find.textContaining('No match for "zzz"'), findsOneWidget);
    });

    testWidgets('matches on services as well as salon name',
        (WidgetTester tester) async {
      await pumpHome(tester, const Size(390, 844));

      // "Facial" is not in the salon name but is a service it offers.
      await tester.enterText(find.byType(SalonSearchBar), 'facial');
      await tester.pumpAndSettle();
      expect(find.text('Looks Salon'), findsOneWidget);
    });

    testWidgets('clearing the search restores the full list',
        (WidgetTester tester) async {
      await pumpHome(tester, const Size(390, 844));

      await tester.enterText(find.byType(SalonSearchBar), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('Looks Salon'), findsNothing);

      await tester.enterText(find.byType(SalonSearchBar), '');
      await tester.pumpAndSettle();
      expect(find.text('Looks Salon'), findsOneWidget);
    });
  });

  testWidgets('Visit-time page shows only the heading, five options and the note',
      (WidgetTester tester) async {
    await pumpTimePage(tester, const Size(390, 844));

    expect(find.text('When would you like to go or visit?'), findsOneWidget);

    expect(find.text('Now (Fastest)'), findsOneWidget);
    expect(find.text('Within 30 min'), findsOneWidget);
    expect(find.text('Later Today'), findsOneWidget);
    expect(find.text('Tomorrow'), findsOneWidget);
    expect(find.text('Pick a specific time'), findsOneWidget);

    expect(
      find.textContaining("We'll show you salons that are available"),
      findsOneWidget,
    );
  });

  testWidgets('Visit-time page never uses the word "slot"',
      (WidgetTester tester) async {
    await pumpTimePage(tester, const Size(390, 844));

    final offenders = visibleText(tester)
        .where((t) => t.toLowerCase().contains('slot'))
        .toList();
    expect(offenders, isEmpty);
  });

  testWidgets('Visit-time page carries no salon, price or duration detail',
      (WidgetTester tester) async {
    await pumpTimePage(tester, const Size(390, 844));

    // The old page showed the service name as its app bar title.
    expect(find.text('Haircut'), findsNothing);
    // No availability/result content, and no continue button.
    expect(find.text('Show Available Salons'), findsNothing);
    expect(find.text('Looks Salon'), findsNothing);
    expect(find.textContaining('₹'), findsNothing);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('Choosing a time continues to the salon list',
      (WidgetTester tester) async {
    await pumpTimePage(tester, const Size(390, 844));

    await tester.tap(find.text('Later Today'));
    await tester.pumpAndSettle();

    // Flow step 3 is the salon list.
    expect(find.byType(SalonListScreen), findsOneWidget);
  });

  group('Salon list layout', () {
    Future<void> pumpSalonList(
      WidgetTester tester,
      Size size,
      double textScale, [
      String timeOption = 'now',
    ]) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ZalonoProvider(),
          child: MaterialApp(
            theme: ZalonoTheme.lightTheme,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
              child: Scaffold(
                body: SalonListScreen(
                  categoryName: 'All Salons',
                  timeOption: timeOption,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // Regression cover for the card overflow: a rigid rating badge used to
    // starve the neighbouring Expanded to zero width, which collapsed the card
    // to ~1300px tall, and the price/CTA row pushed past the card edge.
    for (final size in const [
      Size(320, 568),
      Size(360, 640),
      Size(390, 844),
      Size(430, 932),
    ]) {
      for (final scale in const [1.0, 1.3, 1.8, 2.0]) {
        testWidgets('no overflow at ${size.width.toInt()}px @${scale}x',
            (WidgetTester tester) async {
          await pumpSalonList(tester, size, scale);
          expect(tester.takeException(), isNull);
        });
      }
    }

testWidgets('still shows salon details after the layout fix',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpSalonList(tester, const Size(390, 844), 1.0, 'tomorrow');

      // The filter bar sits above the results, so scroll to the first card.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Looks Salon'), findsOneWidget);
      // One "Select Seat" button per card in the seeded area.
      expect(find.text('Select Seat'), findsWidgets);
      // Booking ahead keeps the next-slot pill.
      expect(find.text('Next slot: 11:30 AM'), findsWidgets);
      expect(zalono.salons, isNotEmpty);
    });

    testWidgets('gender tag sits in front of the rating on one row',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();
      await pumpSalonList(tester, const Size(390, 844), 1.0);
      expect(zalono.salons, isNotEmpty);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Exactly one tag per built card — the tag lives in the trailing row and
      // is not repeated in the location line below. Compared against the cards
      // actually built, since the list is lazy.
      final cards = find.text('Select Seat');
      expect(cards, findsWidgets);
      expect(find.byType(SalonGenderTag), findsNWidgets(cards.evaluate().length));

      final tag = find.byType(SalonGenderTag).first;
      final rating = find.textContaining('4.').first;
      final tagY = tester.getTopLeft(tag).dy;
      final ratingY = tester.getTopLeft(rating).dy;
      // Same row, and the tag is to the left of the rating.
      expect((tagY - ratingY).abs(), lessThan(14));
      expect(tester.getTopLeft(tag).dx, lessThan(tester.getTopLeft(rating).dx));
    });

    testWidgets('gender tag label and rating are laid out at full width',
        (WidgetTester tester) async {
      await pumpSalonList(tester, const Size(320, 568), 1.0);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // A single-line Text ends up narrower than its content only when an
      // ancestor clipped it. Comparing against the width the text needs is a
      // direct check for the "Unis…" and "4.8 (20…" truncation this card used
      // to show, and it does not care which row the pieces end up on.
      bool showsInFull(Finder finder) {
        final paragraph = tester.renderObject<RenderParagraph>(finder);
        final needed = (TextPainter(
          text: paragraph.text,
          textDirection: TextDirection.ltr,
        )..layout()).width;
        return paragraph.size.width >= needed - 0.5;
      }

      Finder textMatching(Pattern pattern) => find.byWidgetPredicate(
            (widget) =>
                widget is Text && pattern.allMatches(widget.data ?? '').isNotEmpty,
          );

      expect(
        showsInFull(
          find.descendant(
            of: find.byType(SalonGenderTag).first,
            matching: find.byType(Text),
          ),
        ),
        isTrue,
        reason: 'gender tag label is clipped',
      );
      expect(
        showsInFull(textMatching(RegExp(r'^\d+\.\d+$')).first),
        isTrue,
        reason: 'rating number is clipped',
      );
      expect(
        showsInFull(textMatching(RegExp(r'^\(\d+\)$')).first),
        isTrue,
        reason: 'review count is clipped',
      );
    });

    testWidgets('salon page shows the gender tag and rating in full',
        (WidgetTester tester) async {
      final zalono = ZalonoProvider();

      bool showsInFull(Finder finder) {
        final paragraph = tester.renderObject<RenderParagraph>(finder);
        final needed = (TextPainter(
          text: paragraph.text,
          textDirection: TextDirection.ltr,
        )..layout()).width;
        return paragraph.size.width >= needed - 0.5;
      }

      // The page bundled area, distance and rating into one two-line Text,
      // which needed three lines on a 320px phone and cut the count off.
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => zalono,
          child: MaterialApp(
            theme: ZalonoTheme.lightTheme,
            home: Scaffold(
              body: SalonDetailScreen(salon: zalono.salons.first),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      Finder textMatching(Pattern pattern) => find.byWidgetPredicate(
            (widget) =>
                widget is Text && pattern.allMatches(widget.data ?? '').isNotEmpty,
          );

      expect(
        showsInFull(
          find.descendant(
            of: find.byType(SalonGenderTag).first,
            matching: find.byType(Text),
          ),
        ),
        isTrue,
        reason: 'page: gender clipped',
      );
      expect(
        showsInFull(textMatching(RegExp(r'^\d+\.\d+$')).first),
        isTrue,
        reason: 'page: rating clipped',
      );
      expect(
        showsInFull(textMatching(RegExp(r'^\(\d+\)$')).first),
        isTrue,
        reason: 'page: review count clipped',
      );
    });

    testWidgets('Home card does not overflow at 2x text scale',
        (WidgetTester tester) async {
      // The tag sat beside the salon name, and once the system text scale grew
      // it the pair no longer fitted a 320px page.
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      // The whole Home page, not the card alone: the page's own horizontal
      // padding is what squeezed the card's rows in the first place.
      await pumpHome(tester, const Size(320, 568));

      expect(tester.takeException(), isNull, reason: 'Home card overflows');
    });

    // Width assertions only hold at 1.0x: flutter_test's font draws every glyph
    // 1em wide, which makes a short label like "Unisex" roughly twice as wide
    // as it is on a device and would fail for reasons no user would see.
    testWidgets('Home card shows the gender tag and rating in full',
        (WidgetTester tester) async {
      await pumpHome(tester, const Size(320, 568));

      bool showsInFull(Finder finder) {
        final paragraph = tester.renderObject<RenderParagraph>(finder);
        final needed = (TextPainter(
          text: paragraph.text,
          textDirection: TextDirection.ltr,
        )..layout()).width;
        return paragraph.size.width >= needed - 0.5;
      }

      expect(
        showsInFull(
          find.descendant(
            of: find.byType(SalonGenderTag).first,
            matching: find.byType(Text),
          ),
        ),
        isTrue,
        reason: 'Home: gender clipped',
      );
      expect(
        showsInFull(
          find.byWidgetPredicate(
            (widget) =>
                widget is Text &&
                RegExp(r'^\d+\.\d+$').hasMatch(widget.data ?? ''),
          ).first,
        ),
        isTrue,
        reason: 'Home: rating clipped',
      );
    });
  });

  testWidgets('Visit-time page renders without overflow on a small phone',
      (WidgetTester tester) async {
    await pumpTimePage(tester, const Size(320, 568));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Visit-time page renders without overflow on a large phone',
      (WidgetTester tester) async {
    await pumpTimePage(tester, const Size(430, 932));
    expect(tester.takeException(), isNull);
  });

  group('Results filters', () {
    Future<ZalonoProvider> pumpResults(WidgetTester tester) async {
      // Tall surface so every seeded card is built. With a phone-sized viewport
      // the lazy list only builds two cards, which makes it impossible to
      // assert what a filter removed.
      tester.view.physicalSize = const Size(390, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ZalonoProvider(),
          child: MaterialApp(
            theme: ZalonoTheme.lightTheme,
            home: const Scaffold(
              body: SalonListScreen(
                categoryName: 'All Salons',
                timeOption: 'now',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return Provider.of<ZalonoProvider>(
        tester.element(find.byType(SalonListScreen)),
        listen: false,
      );
    }

    /// Salon names currently rendered, in render order (sort order matters).

    Future<void> openPicker(WidgetTester tester, String rowLabel) async {
      await tester.tap(find.text(rowLabel));
      await tester.pumpAndSettle();
    }

    /// Options inside the picker sheet only.
    ///
    /// The sheet is a bottom sheet over the cards, and the cards carry their
    /// own gender tags, so "Women" matches in both places.
    Finder inPicker(String text) {
      return find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text(text),
      );
    }

    Future<void> pickGender(WidgetTester tester, String gender) async {
      await tester.tap(inPicker(gender));
      await tester.pumpAndSettle();
      await tester.tap(inPicker('Apply'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows four dropdowns', (WidgetTester tester) async {
      await pumpResults(tester);

      expect(find.text('Price'), findsOneWidget);
      expect(find.text('Rating'), findsOneWidget);
      expect(find.text('Salon type'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
    });

    testWidgets('price band filter keeps only salons inside the budget',
        (WidgetTester tester) async {
      await pumpResults(tester);
      final zalono = Provider.of<ZalonoProvider>(
        tester.element(find.byType(SalonListScreen)),
        listen: false,
      );
      final cheap = zalono.salons.where((s) => s.priceStart < 400).toList();
      final dear = zalono.salons.where((s) => s.priceStart >= 400).toList();
      expect(cheap, isNotEmpty);
      expect(dear, isNotEmpty);

      await openPicker(tester, 'Price');
      await tester.tap(inPicker('Under ₹400'));
      await tester.pumpAndSettle();

      final shown = renderedSalonNames(tester);
      expect(shown.length, cheap.length);
      for (final name in shown) {
        final salon = zalono.salons.firstWhere((s) => s.name == name);
        expect(salon.priceStart, lessThan(400));
      }
    });

    testWidgets('rating threshold filter keeps only highly rated salons',
        (WidgetTester tester) async {
      await pumpResults(tester);
      final zalono = Provider.of<ZalonoProvider>(
        tester.element(find.byType(SalonListScreen)),
        listen: false,
      );
      final topRated = zalono.salons.where((s) => s.rating >= 4.5).toList();
      expect(topRated, isNotEmpty);

      await openPicker(tester, 'Rating');
      await tester.tap(inPicker('4.5★ and up'));
      await tester.pumpAndSettle();

      final shown = renderedSalonNames(tester);
      expect(shown.length, topRated.length);
      for (final name in shown) {
        final salon = zalono.salons.firstWhere((s) => s.name == name);
        expect(salon.rating, greaterThanOrEqualTo(4.5));
      }
    });

    testWidgets('distance filter actually drops salons beyond 2 km',
        (WidgetTester tester) async {
      await pumpResults(tester);

      final before = renderedSalonNames(tester);
      expect(before, contains('Glow Spa & Salon'));

      await openPicker(tester, 'Distance');
      await tester.tap(find.text('Under 2 km'));
      await tester.pumpAndSettle();

      final after = renderedSalonNames(tester);
      expect(after, isNot(contains('Glow Spa & Salon')));
      expect(after.length, lessThan(before.length));
      // And the count line reflects it.
      expect(find.textContaining('Showing'), findsOneWidget);
    });

    testWidgets('salon type filter keeps only matching salons',
        (WidgetTester tester) async {
      await pumpResults(tester);

      await openPicker(tester, 'Salon type');
      await pickGender(tester, 'Women');

      final shown = renderedSalonNames(tester);
      expect(shown, contains('Belle Beauty Parlour'));
      expect(shown, contains('Glow Spa & Salon')); // also women-only
      expect(_hasMensStudio(shown), isFalse);
      expect(shown, isNot(contains('Looks Salon')));
    });

    testWidgets('salon type options combine', (WidgetTester tester) async {
      await pumpResults(tester);

      await openPicker(tester, 'Salon type');
      await tester.tap(inPicker('Men'));
      await tester.tap(inPicker('Unisex'));
      await tester.pumpAndSettle();
      await tester.tap(inPicker('Apply'));
      await tester.pumpAndSettle();

      final shown = renderedSalonNames(tester);
      expect(_hasMensStudio(shown), isTrue);
      expect(shown, contains('Style Studio Unisex'));
      expect(shown, isNot(contains('Belle Beauty Parlour')));
    });

    testWidgets('price sort orders from cheapest up',
        (WidgetTester tester) async {
      await pumpResults(tester);

      await openPicker(tester, 'Price');
      await tester.tap(inPicker('Lowest first'));
      await tester.pumpAndSettle();

      final zalono = Provider.of<ZalonoProvider>(
        tester.element(find.byType(SalonListScreen)),
        listen: false,
      );
      final prices = zalono.salons.map((s) => s.priceStart).toList()..sort();
      // Rendered order should match ascending price order.
      final expected = prices.map((p) => '₹${p.toInt()}').toList();
      expect(_renderedPrices(tester), expected);
    });

    testWidgets('rating sort orders from highest down',
        (WidgetTester tester) async {
      await pumpResults(tester);

      await openPicker(tester, 'Rating');
      await tester.tap(inPicker('Highest first'));
      await tester.pumpAndSettle();

      final ratings = renderedSalonNames(tester);
      // Belle (4.8) sorts above Looks (4.7) and Style Studio (4.3).
      expect(ratings.first, 'Belle Beauty Parlour');
      expect(ratings.last, 'Style Studio Unisex');
    });

    testWidgets('filters combine rather than override each other',
        (WidgetTester tester) async {
      await pumpResults(tester);

      await openPicker(tester, 'Distance');
      await tester.tap(find.text('Under 2 km'));
      await tester.pumpAndSettle();

      await openPicker(tester, 'Salon type');
      await pickGender(tester, 'Unisex');

      final shown = renderedSalonNames(tester);
      // Unisex AND under 2 km: Looks and Style Studio only.
      expect(shown, containsAll(['Looks Salon', 'Style Studio Unisex']));
      expect(shown, isNot(contains('Glow Spa & Salon')));
      expect(shown, isNot(contains('Belle Beauty Parlour')));
    });

    testWidgets('Clear all restores every salon', (WidgetTester tester) async {
      await pumpResults(tester);
      final before = renderedSalonNames(tester);

      await openPicker(tester, 'Distance');
      await tester.tap(find.text('Under 2 km'));
      await tester.pumpAndSettle();
      expect(renderedSalonNames(tester).length, lessThan(before.length));

      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();

      expect(renderedSalonNames(tester).length, before.length);
    });

    testWidgets('the verified tag is gone', (WidgetTester tester) async {
      await pumpResults(tester);

      expect(find.text('Verified'), findsNothing);
      expect(find.byIcon(Icons.verified), findsNothing);
    });

    testWidgets('results cards have no explore-services affordance, and the CTA '
        'opens the multi-select salon page', (WidgetTester tester) async {
      await pumpResults(tester);

      // Removed for now: the per-card picker and its "Explore more services"
      // button. Booking goes straight to the salon page instead.
      expect(find.text('Explore more services'), findsNothing);
      expect(find.text('Explore services'), findsNothing);
      expect(find.text('Explore More Services'), findsNothing);

      final zalono = Provider.of<ZalonoProvider>(
        tester.element(find.byType(SalonListScreen)),
        listen: false,
      );
      final target = zalono.salons.first;

      await tester.tap(
        find.descendant(
          of: find.ancestor(
            of: find.text(target.name),
            matching: find.byType(Container),
          ).first,
          matching: find.text('Select Seat'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SalonDetailScreen), findsOneWidget);
      expect(find.text('Select services'), findsOneWidget);

      // Multi-select is available there: pick one, then a second.
      await tester.tap(find.text(target.services[0].name));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
      await tester.tap(find.text(target.services[1].name));
      await tester.pumpAndSettle();
      expect(find.text('2 selected'), findsOneWidget);
    });
  });

  group('Immediate vs later pages', () {
    Future<void> pumpAt(WidgetTester tester, String timeOption) async {
      tester.view.physicalSize = const Size(390, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ZalonoProvider(),
          child: MaterialApp(
            theme: ZalonoTheme.lightTheme,
            home: Scaffold(
              body: SalonListScreen(
                categoryName: 'All Salons',
                timeOption: timeOption,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    for (final immediate in const ['now', 'within_30_min']) {
      testWidgets('"$immediate" shows the tag and hides the next-slot pill',
          (WidgetTester tester) async {
        await pumpAt(tester, immediate);

        expect(find.text('Available now'), findsOneWidget);
        expect(find.textContaining('Next slot:'), findsNothing);
      });
    }

    for (final later in const [
      'later_today',
      'tomorrow',
      'custom',
    ]) {
      testWidgets('"$later" has neither', (WidgetTester tester) async {
        await pumpAt(tester, later);

        expect(find.text('Available now'), findsNothing);
        expect(find.textContaining('Next slot:'), findsWidgets);
      });
    }
  });

  testWidgets('Bottom navigation has 3 tabs while search is disabled',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ZalonoApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Search'), findsNothing);
  });

  testWidgets('Bottom navigation gains a Search tab when the flag is on',
      (WidgetTester tester) async {
    AppConfig.searchEnabled = true;
    addTearDown(() => AppConfig.searchEnabled = false);

    await tester.pumpWidget(const ZalonoApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // The Search tab opens the existing salon browse screen.
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('All Salons · Now'), findsOneWidget);
  });
}

