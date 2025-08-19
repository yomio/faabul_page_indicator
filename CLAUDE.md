# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development
- **Run tests**: `flutter test`
- **Run single test file**: `flutter test test/faabul_page_indicator_test.dart`
- **Analyze code**: `flutter analyze`
- **Format code**: `dart format .`

### Example App
- **Run example**: `cd example && flutter run`
- **Build example for specific platform**: `cd example && flutter build [ios|android|web|macos|windows|linux]`

### Publishing
- **Dry run**: `flutter pub publish --dry-run`
- **Publish**: `flutter pub publish`

## Architecture

This is a Flutter package that provides a performant PageView dot indicator widget. The architecture consists of:

### Core Components

1. **FaabulPageIndicator** (`lib/faabul_page_indicator.dart:19-57`)
   - Main public API widget that users interact with
   - Manages state and listens to PageController changes
   - Delegates rendering to internal `_PageIndicator` widget

2. **_PageIndicator** (`lib/faabul_page_indicator.dart:116-258`)
   - Internal widget that handles the actual indicator rendering
   - Manages horizontal scrolling when indicators overflow available space
   - Calculates visibility of indicators and applies edge fading
   - Uses ListView.builder for performance with large item counts

3. **FaabulPageIndicatorDot** (`lib/faabul_page_indicator.dart:327-401`)
   - Default dot implementation with animation support
   - Supports hover, focused, and pressed states through Material InkWell
   - Customizable through decoration parameter

4. **_ShaderMaskWrapper** (`lib/faabul_page_indicator.dart:261-324`)
   - Applies gradient fade effect to edges when indicators overflow
   - Supports both LTR and RTL text directions

### Key Design Decisions

- **Performance**: Uses ListView.builder to only render visible dots, enabling support for unlimited pages
- **Overflow Handling**: Automatically scrolls active dot into view and fades edges to indicate more content
- **RTL Support**: Properly handles right-to-left locales throughout the widget
- **Customization**: Allows custom item builders while maintaining consistent sizing through itemSize parameter

## Testing Approach

The package uses widget tests to verify functionality. Tests cover:
- Correct number of dots rendering
- Active dot changes on page navigation
- Tap interaction for page navigation
- Edge fading behavior
- Edge cases (0 items, 1 item, very large item counts)
- Custom item builder functionality
- Initial page configuration

## Package Dependencies

- **flutter**: Core Flutter SDK (required)
- **flutter_lints**: ^2.0.0 (dev dependency for linting)
- Supports Dart SDK >=3.1.1 <4.0.0
- Compatible with Flutter >=1.17.0