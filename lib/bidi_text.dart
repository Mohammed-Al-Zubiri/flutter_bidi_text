import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_bidi_text/helpers/bidi_helper.dart';

/// A text widget that automatically detects and sets text direction based on content.
///
/// `BidiText` extends Flutter's standard [Text] widget but automatically determines
/// whether the text should be displayed in right-to-left (RTL) or left-to-right (LTR)
/// direction based on the content of the text itself.
///
/// Use the primary constructor for plain strings and [BidiText.rich] for styled
/// [InlineSpan] trees (mirrors [Text.rich]).
///
/// Example:
///
/// ```dart
/// BidiText('Hello world!')  // Will display in LTR direction
/// BidiText('مرحبا بالعالم!')  // Will display in RTL direction
/// BidiText('Hello مرحبا')  // Direction will be determined by content analysis
///
/// // Styled text (mirrors Text.rich):
/// BidiText.rich(
///   TextSpan(children: [
///     TextSpan(text: 'Hello ', style: TextStyle(fontWeight: FontWeight.bold)),
///     TextSpan(text: 'مرحبا'),
///   ]),
/// )
/// ```
///
/// Note: While a [textDirection] parameter can be provided, it will be ignored in
/// favour of the automatically detected direction.
class BidiText extends Text {
  /// Creates a [BidiText] widget with a plain string.
  ///
  /// Direction is detected from [data] up to [sampleLength] characters.
  const BidiText(
    super.data, {
    super.key,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.locale,
    super.softWrap,
    super.overflow,
    super.textScaler,
    super.maxLines,
    super.semanticsLabel,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
    this.sampleLength = 50,
  }) : _richSpan = null;

  /// Creates a [BidiText] widget with an [InlineSpan] — a drop-in replacement
  /// for [Text.rich].
  ///
  /// Direction is detected by extracting all text from the [InlineSpan] tree
  /// (including nested [TextSpan] children; [WidgetSpan] nodes are ignored).
  ///
  /// Example:
  /// ```dart
  /// BidiText.rich(
  ///   TextSpan(children: [
  ///     TextSpan(text: 'مرحبا '),
  ///     TextSpan(text: 'world', style: TextStyle(fontWeight: FontWeight.bold)),
  ///   ]),
  /// )
  /// ```
  // ignore: use_super_parameters
  const BidiText.rich(
    InlineSpan richSpan, {
    super.key,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.locale,
    super.softWrap,
    super.overflow,
    super.textScaler,
    super.maxLines,
    super.semanticsLabel,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
    this.sampleLength = 50,
  })  : _richSpan = richSpan,
        super.rich(richSpan);

  /// Stores the [InlineSpan] for [BidiText.rich] so direction can be detected
  /// from the span tree. Null when the primary string constructor is used.
  final InlineSpan? _richSpan;

  /// Maximum number of characters to sample for direction detection.
  ///
  /// If null, the entire text will be analyzed.
  /// If specified, only up to this many characters from the beginning of the text
  /// will be used to determine directionality.
  ///
  /// Default is 50 characters, which provides a good balance between performance
  /// and accuracy for most text.
  final int? sampleLength;

  @override
  TextDirection? get textDirection {
    // For BidiText.rich, detect direction from the stored InlineSpan.
    if (_richSpan != null) {
      final extracted = _extractFromSpan(_richSpan!);
      if (extracted.isEmpty) return null;
      final sampleSize = sampleLength ?? extracted.length;
      final sample =
          extracted.substring(0, math.min(sampleSize, extracted.length));
      return BidiHelper.estimateDirectionOfText(sample);
    }
    return _getTextDirection(data!);
  }

  /// Extracts plain text from an [InlineSpan] tree for direction detection.
  /// [WidgetSpan] nodes are skipped as they contain no text content.
  static String _extractFromSpan(InlineSpan span) {
    final buffer = StringBuffer();
    final stack = <InlineSpan>[span];
    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (current is TextSpan) {
        if (current.text != null) buffer.write(current.text);
        if (current.children != null) {
          for (int i = current.children!.length - 1; i >= 0; i--) {
            stack.add(current.children![i]);
          }
        }
      }
      // WidgetSpan contains no text — skip.
    }
    return buffer.toString();
  }

  TextDirection? _getTextDirection(String text) {
    final sampleSize = sampleLength ?? text.length;
    final sample = text.substring(0, math.min(sampleSize, text.length));
    return BidiHelper.estimateDirectionOfText(sample);
  }
}
