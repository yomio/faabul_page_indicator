import 'package:faabul_page_indicator/faabul_page_indicator.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    late final headlineStyle = Theme.of(context).textTheme.headlineMedium;
    late final colorScheme = Theme.of(context).colorScheme;
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text('3 pages', style: headlineStyle),
                    const _PageView(pages: 3),
                    const Divider(height: 64),
                    Text('42 pages', style: headlineStyle),
                    const _PageView(pages: 42, initialPage: 21),
                    const Divider(height: 64),
                    Text('Customized FaabulPageIndicatorDot',
                        style: headlineStyle),
                    _PageView(
                        pages: 16,
                        initialPage: 0,
                        size: 30,
                        itemBuilder: (
                          BuildContext context,
                          int index,
                          int? currentPage,
                        ) =>
                            FaabulPageIndicatorDot(
                              key: ValueKey(index),
                              size: 30,
                              decoration: index == currentPage
                                  ? BoxDecoration(
                                      border: Border.all(
                                          color: colorScheme.primary, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                      color: colorScheme.primaryContainer,
                                    )
                                  : BoxDecoration(
                                      border: Border.all(
                                          color: colorScheme.outlineVariant,
                                          width: 2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                              isActive: index == currentPage,
                            )),
                    const Divider(height: 64),
                    Text('Custom builder', style: headlineStyle),
                    _PageView(
                        pages: 42,
                        initialPage: 21,
                        size: 44,
                        itemBuilder: (
                          BuildContext context,
                          int index,
                          int? currentPage,
                        ) =>
                            _Dot(
                              key: ValueKey(index),
                              shape: index.isEven
                                  ? BoxShape.circle
                                  : BoxShape.rectangle,
                              isActive: index == currentPage,
                              child: Center(
                                child: Text('$index',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: index == currentPage
                                            ? colorScheme.onPrimary
                                            : colorScheme
                                                .onSecondaryContainer)),
                              ),
                            )),
                    const Divider(height: 64),
                    Text('A million pages', style: headlineStyle),
                    const _PageView(
                      pages: 1000000,
                      initialPage: 500000,
                    ),
                    const Divider(height: 64),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        children: [
                          Text('An RTL PageView', style: headlineStyle),
                          const _PageView(pages: 42, initialPage: 21),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageView extends StatefulWidget {
  final int pages;
  final int? initialPage;
  final FaabulDotIndicatorItemBuilder? itemBuilder;
  final double size;

  const _PageView({
    required this.pages,
    this.initialPage,
    this.itemBuilder,
    this.size = 20.0,
  });

  @override
  State<_PageView> createState() => __PageViewState();
}

class __PageViewState extends State<_PageView> {
  late final _controller = PageController(
      viewportFraction: 0.8, initialPage: widget.initialPage ?? 0);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: widget.pages,
            itemBuilder: _buildPage,
            controller: _controller,
          ),
        ),
        FaabulPageIndicator(
          itemBuilder: widget.itemBuilder,
          itemSize: Size(widget.size, widget.size),
          itemCount: widget.pages,
          controller: _controller,
        ),
      ],
    );
  }

  Widget? _buildPage(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.all(32),
      color: index.isEven ? Colors.red : Colors.blue,
      child: Center(
        child: Text(
          'Page $index',
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final BoxShape shape;
  final Widget child;
  final bool isActive;
  const _Dot(
      {required super.key,
      required this.shape,
      required this.child,
      required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 44,
      height: 44,
      child: Center(
          child: AnimatedContainer(
        duration: Durations.long2,
        curve: Curves.easeInOut,
        width: isActive ? 40 : 32,
        height: isActive ? 40 : 32,
        decoration: BoxDecoration(
          color:
              isActive ? colorScheme.primary : colorScheme.secondaryContainer,
          shape: shape,
        ),
        child: child,
      )),
    );
  }
}
