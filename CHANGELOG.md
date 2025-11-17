# Changelog

All notable changes to the flutter_bidi_text package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.1.1 - 2025-11-17

### Fixed
- Correctly pass BidiTextField keyboardType property to parent TextField in the constructor by using `super.keyboardType` directly instead of redundant parameter declaration

## 1.1.0 - 2025-10-18

### Added
- BidiRichText widget with automatic text direction detection for RichText with TextSpan support
- Comprehensive test suite for BidiRichText widget
- Support for nested TextSpan trees with automatic direction detection
- WidgetSpan support in BidiRichText (ignored in direction detection)
- Examples in demo app showcasing BidiRichText usage with styled text and icons
- Technical Background section in README explaining Unicode Bidirectional Algorithm
- Updated documentation with BidiRichText usage examples

## 1.0.2 - 2025-04-13

### Fixed
- Applied standard Dart formatting to source code files.

## 1.0.1 - 2025-04-12

### Fixed
- Removed deprecated `scribbleEnabled` parameter from BidiTextField and BidiTextFormField
- Improved compatibility with latest Flutter versions

## 1.0.0 - 2025-04-13

### Added
- Initial release of the package
- BidiText widget with automatic text direction detection
- BidiTextField widget with text direction detection and callbacks
- BidiTextFormField widget for form integration
- Configurable sample length for direction detection optimization
- Direction change callbacks for input widgets
- Comprehensive test suite for all widgets
- Documentation with examples
- Utility functions for text direction detection
