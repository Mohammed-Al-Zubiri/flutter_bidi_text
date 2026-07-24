import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bidi_text/helpers/bidi_helper.dart';

/// A rich text widget that automatically detects and sets text direction based
/// on content.
///
/// `BidiRichText` wraps Flutter's standard [RichText] widget and automatically
/// determines whether text should be displayed in right-to-left (RTL) or
/// left-to-right (LTR) direction by analysing the content of the [TextSpan]
/// tree.
///
/// ## Breaking change (v2.0.0)
/// `BidiRichText` no longer extends [RichText]. It extends [StatelessWidget]
/// and builds a [RichText] internally. If your code relied on
/// `bidiRichTextInstance is RichText` type checks, update them — all widget
/// behaviour is identical.
///
/// Example:
///
/// ```dart
/// BidiRichText(
///   text: TextSpan(
///     text: 'Hello ',
///     style: TextStyle(color: Colors.black),
///     children: [
///       TextSpan(text: 'world!', style: TextStyle(fontWeight: FontWeight.bold)),
///     ],
///   ),
/// )
/// ```
class BidiRichText extends StatelessWidget {
  /// Creates a [BidiRichText] widget.
  ///
  /// Direction is detected from up to [sampleLength] characters extracted
  /// from the [text] span tree.
  const BidiRichText({
    required this.text,
    super.key,
    this.textAlign = TextAlign.start,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textScaler = TextScaler.noScaling,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
    this.selectionRegistrar,
    this.selectionColor,
    this.sampleLength = 50,
  });

  /// The text to display, as an [InlineSpan] (typically a [TextSpan]).
  final InlineSpan text;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// Whether the text should break at soft line breaks.
  final bool softWrap;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// {@macro flutter.painting.textPainter.textScaler}
  final TextScaler textScaler;

  /// Maximum number of lines to show.
  final int? maxLines;

  /// Used to select a font when the same Unicode character can be rendered
  /// differently depending on the locale.
  final Locale? locale;

  /// {@macro flutter.widgets.editableText.strutStyle}
  final StrutStyle? strutStyle;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis textWidthBasis;

  /// {@macro flutter.dart:ui.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

  /// The [SelectionRegistrar] this rich text is subscribed to.
  final SelectionRegistrar? selectionRegistrar;

  /// The color to use when painting the selection.
  final Color? selectionColor;

  /// Maximum number of characters to sample for direction detection.
  ///
  /// If null, the entire text will be analyzed.
  /// If specified, only up to this many characters from the beginning of the
  /// text will be used to determine directionality.
  ///
  /// Default is 50 characters, which provides a good balance between
  /// performance and accuracy for most text.
  final int? sampleLength;

  /// Determines text direction from the [InlineSpan] tree.
  ///
  /// Defaults to [TextDirection.ltr] when the text is empty or neutral.
  TextDirection get textDirection {
    final extracted = extractTextFromSpan(text);
    if (extracted.isEmpty) return TextDirection.ltr;
    final sampleSize = sampleLength ?? extracted.length;
    final sample = extracted.substring(0, math.min(sampleSize, extracted.length));
    return BidiHelper.estimateDirectionOfText(sample) ?? TextDirection.ltr;
  }

  /// Extracts all text content from a [InlineSpan] tree.
  ///
  /// Traverses the entire tree and concatenates text from all [TextSpan] nodes.
  /// [WidgetSpan] nodes are skipped as they contain no text content.
  @visibleForTesting
  static String extractTextFromSpan(InlineSpan span) {
    final buffer = StringBuffer();
    final List<InlineSpan> stack = [span];
    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (current is TextSpan) {
        if (current.text != null) buffer.write(current.text);
        if (current.children != null && current.children!.isNotEmpty) {
          for (int i = current.children!.length - 1; i >= 0; i--) {
            stack.add(current.children![i]);
          }
        }
      }
      // WidgetSpan has no text — skip.
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: text,
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionRegistrar: selectionRegistrar,
      selectionColor: selectionColor,
    );
  }
}
