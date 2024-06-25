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
  });
}
