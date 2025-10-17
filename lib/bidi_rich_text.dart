import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bidi_text/helpers/bidi_helper.dart';

/// A rich text widget that automatically detects and sets text direction based on content.
///
/// `BidiRichText` extends Flutter's standard [RichText] widget but automatically determines
/// whether the text should be displayed in right-to-left (RTL) or left-to-right (LTR)
/// direction based on the content of the text within the [TextSpan] tree.
///
/// This is particularly useful for applications that support multiple languages with
/// different text directions, as it eliminates the need to manually specify direction.
///
/// The widget analyzes the text content from all [TextSpan] nodes in the tree to
/// determine the overall directionality.
///
/// Example:
///
/// ```dart
/// BidiRichText(
///   text: TextSpan(
///     text: 'Hello ',
///     style: TextStyle(color: Colors.black),
///     children: [
///       TextSpan(
///         text: 'world!',
///         style: TextStyle(fontWeight: FontWeight.bold),
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ```dart
/// BidiRichText(
///   text: TextSpan(
///     text: 'مرحبا ',
///     style: TextStyle(color: Colors.black),
///     children: [
///       TextSpan(
///         text: 'بالعالم!',
///         style: TextStyle(fontWeight: FontWeight.bold),
///       ),
///     ],
///   ),
/// )
/// ```
///
/// Note: While a [textDirection] parameter can be provided, it will be ignored in favor
/// of the automatically detected direction.
class BidiRichText extends RichText {
  BidiRichText({
    required super.text,
    super.key,
    super.textAlign = TextAlign.start,
    super.softWrap = true,
    super.overflow = TextOverflow.clip,
    super.textScaler = TextScaler.noScaling,
    super.maxLines,
    super.locale,
    super.strutStyle,
    super.textWidthBasis = TextWidthBasis.parent,
    super.textHeightBehavior,
    super.selectionRegistrar,
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
  TextDirection get textDirection => _getTextDirection(text);

  /// Determines the text direction based on the content of the TextSpan.
  TextDirection _getTextDirection(InlineSpan span) {
    final text = extractTextFromSpan(span);

    if (text.isEmpty) {
      // Default to LTR for empty text
      return TextDirection.ltr;
    }

    final sampleSize = sampleLength ?? text.length;
    final sample = text.substring(0, math.min(sampleSize, text.length));
    final direction = BidiHelper.estimateDirectionOfText(sample);

    // If direction is null (neutral), default to LTR
    return direction ?? TextDirection.ltr;
  }

  /// Extracts all text content from a TextSpan tree recursively.
  ///
  /// This method traverses the entire [TextSpan] tree and concatenates all text
  /// content found in the nodes.
  @visibleForTesting
  static String extractTextFromSpan(InlineSpan span) {
    final buffer = StringBuffer();

    // Iterative approach using a stack
    final List<InlineSpan> stack = [span];
    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (current is TextSpan) {
        if (current.text != null) {
          buffer.write(current.text);
        }
        if (current.children != null && current.children!.isNotEmpty) {
          // Add children to stack in reverse order to maintain original order
          for (int i = current.children!.length - 1; i >= 0; i--) {
            stack.add(current.children![i]);
          }
        }
      }
      // WidgetSpan doesn't contain text, so we skip it
    }
    return buffer.toString();
  }
}
