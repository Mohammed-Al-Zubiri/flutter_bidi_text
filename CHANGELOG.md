# Changelog

All notable changes to the flutter_bidi_text package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 2.0.0 - 2026-07-24

### BREAKING CHANGES

All four `Bidi*` widgets now extend `StatelessWidget` or `StatefulWidget` instead
of their Flutter counterparts (`Text`, `RichText`, `TextField`). All **behaviour
and constructor APIs are identical** — only the Dart type hierarchy changed.

If your code uses `is`/`as` type checks on these widgets, update them:

| Old (broken) | Fix |
|---|---|
| `widget is Text` | `widget is BidiText` |
| `widget is RichText` | `widget is BidiRichText` |
| `widget is TextField` | `widget is BidiTextField` |

### Added
- `BidiSelectableText` widget — selectable text with auto direction detection,
  mirroring `SelectableText` and `SelectableText.rich`
- `BidiText.rich(InlineSpan)` named constructor — drop-in for `Text.rich`
- pub.dev `topics` field for improved discoverability:
  `bidi`, `rtl`, `text`, `internationalization`, `multilingual`

### Fixed
- **Critical**: 8 constructor parameters in `BidiTextField` were silently
  dropped and never forwarded to the inner `TextField`:
  `groupId`, `undoController`, `statesController`, `ignorePointers`,
  `cursorOpacityAnimates`, `cursorErrorColor`, `onTapAlwaysCalled`,
  `contentInsertionConfiguration`
- `canRequestFocus` (deprecated Flutter 3.27) replaced by
  `stylusHandwritingEnabled` in `BidiTextField` and `BidiTextFormField`
- HTTPS URLs (`https://`) now correctly detected as weakly LTR (was `http://` only)
- `_LTR_CHARS` / `_RTL_CHARS` regex strings now use proper Dart Unicode escapes
  instead of fragile double-escaped raw strings
- `onDirectionChanged` doc comment corrected: callback always receives a
  non-null `TextDirection` (falls back to `Directionality.of(context)`)
- README callback type signature fixed: `(TextDirection direction)` not `(TextDirection? direction)`
- Example app: deprecated `primarySwatch` replaced with `ColorScheme.fromSeed`
- `BidiText` and `BidiRichText` no longer import `package:flutter/material.dart`
  (proactive step ahead of Flutter's Material decoupling initiative)

### Changed
- `flutter_lints` upgraded from `^5.0.0` to `^6.0.0`
- All `Bidi*` widgets now use composition instead of inheritance
- `BidiHelper` RegExp patterns are now pre-compiled as `static final` fields,
  improving performance for repeated direction detection calls

---

## 1.1.2 - 2025-11-25

### Changed
- Optimized `BidiHelper` class by pre-compiling RegExp patterns as static final
  fields, improving performance during text direction detection

### Fixed
- Updated URL detection pattern to recognize both HTTP and HTTPS URLs as LTR content

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
