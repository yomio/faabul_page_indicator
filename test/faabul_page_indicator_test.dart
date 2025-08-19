import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:faabul_page_indicator/faabul_page_indicator.dart';

void main() {
  group('FaabulPageIndicator Tests', () {
    late PageController controller;

    setUp(() {
      controller = PageController();
    });

    testWidgets('FaabulPageIndicator renders correct number of dots',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller,
                    children: List.generate(
                        5, (index) => Container(color: Colors.blue)),
                  ),
                ),
                FaabulPageIndicator(
                  itemCount: 5,
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FaabulPageIndicatorDot), findsNWidgets(5));
    });

    testWidgets('FaabulPageIndicator changes active dot on page change',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller,
                    children: List.generate(
                        3, (index) => Container(color: Colors.blue)),
                  ),
                ),
                FaabulPageIndicator(
                  itemCount: 3,
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      );

      controller.jumpToPage(1);
      await tester.pumpAndSettle();

      final activeDots = tester.widgetList<FaabulPageIndicatorDot>(
        find.byType(FaabulPageIndicatorDot),
      );
      expect(activeDots.where((dot) => dot.isActive), hasLength(1));
    });

    testWidgets('FaabulPageIndicator reacts to tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller,
                    children: List.generate(
                        3, (index) => Container(color: Colors.blue)),
                  ),
                ),
                FaabulPageIndicator(
                  itemCount: 3,
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FaabulPageIndicatorDot).at(1));
      await tester.pumpAndSettle();

      expect(controller.page, 1);
    });

    testWidgets('FaabulPageIndicator fades edges if fadeEdges is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller,
                    children: List.generate(
                        100, (index) => Container(color: Colors.blue)),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: FaabulPageIndicator(
                    itemCount: 100,
                    controller: controller,
                    fadeEdges: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('shader_mask')), findsOneWidget);
    });

    testWidgets('FaabulPageIndicator does not fade edges if fadeEdges is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller,
                    children: List.generate(
                        100, (index) => Container(color: Colors.blue)),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: FaabulPageIndicator(
                    itemCount: 100,
                    controller: controller,
                    fadeEdges: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('shader_mask')), findsNothing);
    });
    testWidgets('FaabulPageIndicator handles zero items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller,
                    children: const [],
                  ),
                ),
                FaabulPageIndicator(
                  itemCount: 0,
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FaabulPageIndicatorDot), findsNothing);
    });

    testWidgets('FaabulPageIndicator handles one item',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller,
                    children: [Container(color: Colors.blue)],
                  ),
                ),
                FaabulPageIndicator(
                  itemCount: 1,
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FaabulPageIndicatorDot), findsOneWidget);
    });

    testWidgets('FaabulPageIndicator handles a very large number of items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller,
                    children: List.generate(
                        1000000, (index) => Container(color: Colors.blue)),
                  ),
                ),
                SizedBox(
                  width: 90, // Constrains width to 5 dots max
                  child: FaabulPageIndicator(
                    itemCount: 1000000,
                    controller: controller,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FaabulPageIndicatorDot), findsNWidgets(5));
    });

    testWidgets('FaabulPageIndicator uses custom itemBuilder',
        (WidgetTester tester) async {
      Widget customItemBuilder(
          BuildContext context, int index, int? currentPage) {
        return Container(
          key: ValueKey('custom_dot_$index'),
          width: 10,
          height: 10,
          color: index == currentPage ? Colors.red : Colors.grey,
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller,
                    children: List.generate(
                        3, (index) => Container(color: Colors.blue)),
                  ),
                ),
                FaabulPageIndicator(
                  itemCount: 3,
                  controller: controller,
                  itemBuilder: customItemBuilder,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('custom_dot_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('custom_dot_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('custom_dot_2')), findsOneWidget);
    });

    testWidgets(
        'FaabulPageIndicator shows correct active dot with initial page set',
        (WidgetTester tester) async {
      controller = PageController(initialPage: 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller,
                    children: List.generate(
                        200, (index) => Container(color: Colors.blue)),
                  ),
                ),
                FaabulPageIndicator(
                  itemCount: 200,
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final activeDots = tester.widgetList<FaabulPageIndicatorDot>(
        find.byType(FaabulPageIndicatorDot),
      );
      expect(activeDots.where((dot) => dot.isActive), hasLength(1));
    });

    testWidgets('FaabulPageIndicator handles rapid page changes without errors',
        (WidgetTester tester) async {
      controller = PageController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller,
                    children: List.generate(
                        100, (index) => Container(color: Colors.blue)),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: FaabulPageIndicator(
                    itemCount: 100,
                    controller: controller,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Rapidly jump to different pages
      controller.jumpToPage(99);
      await tester.pump();
      controller.jumpToPage(0);
      await tester.pump();
      controller.jumpToPage(50);
      await tester.pump();
      controller.jumpToPage(75);
      await tester.pump();
      controller.jumpToPage(25);
      await tester.pumpAndSettle();

      // Test should pass without throwing ScrollController not attached error
      expect(controller.page, 25);
    });

    testWidgets(
        'FaabulPageIndicator handles immediate jump to last page after initialization',
        (WidgetTester tester) async {
      controller = PageController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller,
                    children: List.generate(
                        50, (index) => Container(color: Colors.blue)),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: FaabulPageIndicator(
                    itemCount: 50,
                    controller: controller,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Immediately jump to last page
      controller.jumpToPage(49);
      await tester.pumpAndSettle();

      // Test should pass without throwing ScrollController not attached error
      expect(controller.page, 49);
    });

    testWidgets('FaabulPageIndicator handles widget disposal during animation',
        (WidgetTester tester) async {
      controller = PageController();
      bool showIndicator = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: controller,
                      children: List.generate(
                          10, (index) => Container(color: Colors.blue)),
                    ),
                  ),
                  if (showIndicator)
                    FaabulPageIndicator(
                      itemCount: 10,
                      controller: controller,
                    ),
                  ElevatedButton(
                    onPressed: () => setState(() => showIndicator = false),
                    child: const Text('Hide'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Start animating to a different page
      controller.animateToPage(
        5,
        duration: const Duration(seconds: 1),
        curve: Curves.linear,
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Dispose the widget during animation
      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();

      // Test should pass without errors
      expect(find.byType(FaabulPageIndicator), findsNothing);
    });
  });
}
