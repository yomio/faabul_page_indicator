library faabul_page_indicator;

import 'dart:math';

import 'package:flutter/material.dart';

/// A page indicator widget
///
/// Pass it the same [controller] that is used with the [PageView] and the number of pages in [itemCount].
///
/// [itemSize] is a constant size for all dot containers. If you use a custom [itemBuilder], make sure the size of the
/// built items is the same.
///
/// If the number of dots is larger than available horizontal area, the dots will scroll and edges will fade out
/// to indicate that there are more items. To disable the fading effect, set [fadeEdges] to false.
///
class FaabulPageIndicator extends StatefulWidget {
  /// The custom builder for the indicator items
  ///
  /// If not specified, a builder for [FaabulPageIndicatorDot] will be used.
  /// If you use a custom builder, make sure the size of the built items is the same as [itemSize].
  final FaabulDotIndicatorItemBuilder? itemBuilder;

  /// The size of each indicator item. This must be constant for all items
  final Size itemSize;

  /// The total number of items in the PageView
  final int itemCount;

  /// The controller for the PageView
  final PageController controller;

  /// Whether the edges of the indicator should fade out to indicate that there are more items
  final bool fadeEdges;

  /// The duration of the animation
  final Duration duration;

  /// The curve of the animation
  final Curve curve;

  const FaabulPageIndicator({
    super.key,
    required this.itemCount,
    required this.controller,
    this.itemBuilder,
    this.itemSize = const Size(20, 20),
    this.fadeEdges = true,
    this.duration = Durations.medium3,
    this.curve = Curves.easeInOut,
  });

  @override
  State<FaabulPageIndicator> createState() => _FaabulPageIndicatorState();
}

class _FaabulPageIndicatorState extends State<FaabulPageIndicator> {
  final ValueNotifier<int?> _currentPage = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_controllerListener);
    _controllerListener();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PageIndicator(
      key: const Key('page_indicator'),
      itemBuilder: widget.itemBuilder ?? _defaultBuilder,
      itemSize: widget.itemSize,
      itemCount: widget.itemCount,
      currentPage: _currentPage,
      fadeEdges: widget.fadeEdges,
      duration: widget.duration,
      curve: widget.curve,
    );
  }

  Widget _defaultBuilder(BuildContext context, int index, int? currentPage) =>
      FaabulPageIndicatorDot(
        key: ValueKey(index),
        size: widget.itemSize.width,
        isActive: index == currentPage,
        onTap: () => _handleTap(index),
      );

  void _controllerListener() {
    if (!mounted || !widget.controller.hasClients) return;
    final page =
        (widget.controller.page ?? widget.controller.initialPage).round();
    if (page != _currentPage.value) {
      _currentPage.value = page;
    }
  }

  void _handleTap(int index) {
    widget.controller.animateToPage(
      index,
      duration: widget.duration,
      curve: widget.curve,
    );
  }
}

/// Builds the indicator itself
class _PageIndicator extends StatefulWidget {
  /// The builder for the indicator items
  final FaabulDotIndicatorItemBuilder itemBuilder;

  /// The size of each indicator item. This must be constant for all items
  final Size itemSize;

  /// The total number of items in the PageView
  final int itemCount;

  /// The current page of the PageView
  final ValueNotifier<int?> currentPage;

  /// The total width of all indicators
  final double indicatorsWidth;

  /// Whether the edges of the indicator should fade out to indicate that there are more items
  final bool fadeEdges;

  /// The duration of the animation
  final Duration duration;

  /// The curve of the animation
  final Curve curve;

  _PageIndicator({
    super.key,
    required this.itemBuilder,
    required this.itemSize,
    required this.itemCount,
    required this.currentPage,
    required this.fadeEdges,
    required this.duration,
    required this.curve,
  }) : indicatorsWidth = itemSize.width * itemCount;

  @override
  State<_PageIndicator> createState() => __PageIndicatorState();
}

class __PageIndicatorState extends State<_PageIndicator> {
  late final _scrollController = ScrollController();

  int? _currentPage;
  bool _isStartHidden = false;
  bool _isEndHidden = false;

  @override
  void initState() {
    super.initState();
    widget.currentPage.addListener(_currentPageListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _currentPageListener());
  }

  @override
  void didUpdateWidget(covariant _PageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _currentPageListener());
  }

  @override
  void dispose() {
    widget.currentPage.removeListener(_currentPageListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.itemSize.height,
      child: LayoutBuilder(builder: (context, constraints) {
        assert(constraints.hasBoundedWidth,
            'FaabulPageIndicator has been given unbounded horizontal space. Please restrict the available width to a finite value, e.g. by wrapping it in a SizedBox widget.');
        final availableWidth = constraints.maxWidth;
        return _ShaderMaskWrapper(
          key: const Key('shader_mask'),
          enabled: widget.fadeEdges,
          start: _isStartHidden,
          end: _isEndHidden,
          child: ListView.builder(
            controller: _scrollController,
            itemBuilder: (context, index) =>
                widget.itemBuilder(context, index, _currentPage),
            itemCount: widget.itemCount,
            itemExtent: widget.itemSize.width,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: max(0, (availableWidth - widget.indicatorsWidth) / 2),
            ),
          ),
        );
      }),
    );
  }

  void _currentPageListener() {
    if (!mounted ||
        !_scrollController.hasClients ||
        widget.currentPage.value == null) return;
    final offsetStart = widget.currentPage.value! * widget.itemSize.width;
    final offsetEnd = offsetStart + widget.itemSize.width;
    final offsetCenter = (offsetStart + offsetEnd) / 2;
    final position = _scrollController.position;
    final halfViewport = position.viewportDimension / 2;
    // calculate the raw ideal scroll position so that the current page is centered
    final idealScroll = offsetCenter - (halfViewport);
    // clamp the scroll position to the bounds of the scrollable area
    final scroll =
        idealScroll.clamp(position.minScrollExtent, position.maxScrollExtent);

    // calculate if some indicators are hidden on the start or end
    final isLeftHidden = scroll > position.minScrollExtent;
    final isRightHidden = scroll < position.maxScrollExtent;
    if (_isStartHidden != isLeftHidden || _isEndHidden != isRightHidden) {
      setState(() {
        _isStartHidden = isLeftHidden;
        _isEndHidden = isRightHidden;
      });
    }

    // if the scroll position is different from the current position, scroll to it
    if (scroll != position.pixels) {
      // if the scroll is more than half the viewport away, jump to it, otherwise animate
      // we delay this post frame, otherwise the methods would silently fail for some reason
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if ((scroll - position.pixels).abs() > halfViewport) {
          _scrollController.jumpTo(scroll);
        } else {
          _scrollController.animateTo(
            scroll,
            duration: widget.duration,
            curve: widget.curve,
          );
        }
      });
    }
    if (_currentPage != widget.currentPage.value) {
      setState(() => _currentPage = widget.currentPage.value);
    }
  }
}

/// A wrapper that applies a shader mask to fade out the edges
class _ShaderMaskWrapper extends StatelessWidget {
  /// Whether the shader mask should be applied
  final bool enabled;

  /// Whether the shader mask should fade out the start
  final bool start;

  /// Whether the shader mask should fade out the end
  final bool end;

  /// The child widget
  final Widget child;
  _ShaderMaskWrapper({
    super.key,
    required this.enabled,
    required this.start,
    required this.end,
    required this.child,
  });

  late final ltrColors = [
    if (start) Colors.transparent,
    Colors.white,
    Colors.white,
    if (end) Colors.transparent,
  ];
  late final ltrStops = [
    0.0,
    if (start) 0.1,
    if (end) 0.9,
    1.0,
  ];
  late final rtlColors = [
    if (end) Colors.transparent,
    Colors.white,
    Colors.white,
    if (start) Colors.transparent,
  ];
  late final rtlStops = [
    0.0,
    if (end) 0.1,
    if (start) 0.9,
    1.0,
  ];

  @override
  Widget build(BuildContext context) {
    if (!enabled || (!start && !end)) return child;
    final textDirection = Directionality.of(context);
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: textDirection == TextDirection.ltr ? ltrColors : rtlColors,
          stops: textDirection == TextDirection.ltr ? ltrStops : rtlStops,
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}

/// The default dot indicator item
class FaabulPageIndicatorDot extends StatelessWidget {
  /// onTap callback
  final VoidCallback? onTap;

  /// The size of the dot
  ///
  /// Note that this must correspond to [FaabulPageIndicator.itemSize.width]
  final double size;

  /// Whether the dot should render as active
  ///
  /// This will be larger in size and if [decoration] is null, different in color
  final bool isActive;

  /// The duration of the animation
  ///
  /// Defaults to [Durations.medium3]
  final Duration duration;

  /// The curve of the animation
  ///
  /// Defaults to [Curves.easeInOut]
  final Curve curve;

  /// Box Decoration
  ///
  /// Defaults to [BoxShape.circle] and [ThemeData.colorScheme.onSurface] / [ThemeData.colorScheme.outlineVariant]
  final BoxDecoration? decoration;

  final double _inactiveDotSize;
  final double _activeDotSize;

  const FaabulPageIndicatorDot({
    required super.key,
    required this.size,
    this.onTap,
    this.isActive = false,
    this.duration = Durations.medium3,
    this.curve = Curves.easeInOut,
    this.decoration,
  })  : assert(size > 0),
        _inactiveDotSize = size * 0.5,
        _activeDotSize = size * 0.75;

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;
    late final boxDecoration = isActive
        ? BoxDecoration(shape: BoxShape.circle, color: colorScheme.onSurface)
        : BoxDecoration(
            shape: BoxShape.circle, color: colorScheme.outlineVariant);
    final dotSize = isActive ? _activeDotSize : _inactiveDotSize;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: AnimatedContainer(
            duration: duration,
            curve: curve,
            width: dotSize,
            height: dotSize,
            decoration: decoration ?? boxDecoration,
          ),
        ),
      ),
    );
  }
}

/// The builder callback for an individual dot item
typedef FaabulDotIndicatorItemBuilder = Widget Function(
  BuildContext context,
  int index,
  int? currentPage,
);
