import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bidi_text/helpers/bidi_helper.dart';

/// A text widget that automatically detects and sets text direction based on content.
///
/// `BidiText` extends Flutter's standard [Text] widget but automatically determines
/// whether the text should be displayed in right-to-left (RTL) or left-to-right (LTR)
/// direction based on the content of the text itself.
///
/// This is particularly useful for applications that support multiple languages with
/// different text directions, as it eliminates the need to manually specify direction.
///
/// Example:
///
/// ```dart
/// BidiText('Hello world!')  // Will display in LTR direction
/// BidiText('مرحبا بالعالم!')  // Will display in RTL direction
/// BidiText('Hello مرحبا')  // Direction will be determined by content analysis
/// ```
///
/// Note: While a [textDirection] parameter can be provided, it will be ignored in favor
/// of the automatically detected direction.
class BidiText extends Text {
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
  });

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
  TextDirection? get textDirection => _getTextDirection(data!);

  TextDirection? _getTextDirection(String text) {
    final sampleSize = sampleLength ?? text.length;
    final sample = text.substring(0, math.min(sampleSize, text.length));
    return BidiHelper.estimateDirectionOfText(sample);
  }
}
