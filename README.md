# faabul_page_indicator

![Sample image](https://raw.githubusercontent.com/yomio/faabul_color_picker/main/doc/sample.png)
faabul_page_indicator is developed and used by [Faabul Live Quizzes][faabul_link]


## Another dot indicator?

We have created this package since there was no existing package that would satisfy the following requirements:

- Support for custom "dot" builder
- Good UX for many pages use cases and a constrained space to display the indicator
- Support for both LTR and RTL locales
- Good performance 

## Usage

See [example](example/lib/main.dart) for a complete example.

Just pass the widget an existing controller and the number of pages that you have. This will display 
the default dot indicator:

```dart
late final _controller = PageController();

@override
Widget build(BuildContext context) {
    return Column(
        children: [
            Expanded(
                child: PageView.builder(
                    itemCount: 20,
                    itemBuilder: _buildPage,
                    controller: _controller,
                ),
            ),
            FaabulPageIndicator(
                itemCount: 20,
                controller: _controller,
            ),
        ],
    );
}
```

The indicator automatically handles overflow if there are too many dots to display and onTap navigation between the pages.

If you need different styling or functionality, you can pass a custom builder. You can either use the default `FaabulPageIndicatorDot` or pass any widget you like.

```dart
FaabulPageIndicator(
    itemCount: 20,
    itemSize: Size(30, 30),
    controller: _controller,
    itemBuilder: (BuildContext context, int index, int? currentPage) =>
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
            onTap: () => _controller.jumpToPage(index),
        ),
)
```
![Sample image](https://raw.githubusercontent.com/yomio/faabul_color_picker/main/doc/custom1.png)

You can also pass any widget, making each "dot" unique:

![Sample image](https://raw.githubusercontent.com/yomio/faabul_color_picker/main/doc/custom2.png)

When using custom builders, make sure the rendered dot size corresponds to the itemSize property.

## Performance

FaabulPageIndicator is optimized for performance. It uses a `ListView.builder` internally to display the dots. This means that only the visible dots are rendered and the indicator can handle a large number of pages without any performance degradation.

Internally the indicator only does work when the actual page (as integer) is changed in the `PageController`.


[faabul_link]: https://faabul.com
