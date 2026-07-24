import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_bidi_text/helpers/bidi_helper.dart';

/// A text widget that automatically detects and sets text direction based on content.
///
/// `BidiText` is a [StatelessWidget] that wraps Flutter's standard [Text] widget
/// and automatically determines whether the text should be displayed in
/// right-to-left (RTL) or left-to-right (LTR) direction based on its content.
///
/// Use the primary constructor for plain strings and [BidiText.rich] for styled
/// [InlineSpan] trees (mirrors [Text.rich]).
///
/// ## Breaking change (v2.0.0)
/// `BidiText` no longer extends [Text]. It extends [StatelessWidget] and builds
/// a [Text] internally. If your code relied on `bidiTextInstance is Text` type
/// checks, update them — all widget behaviour is identical.
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
class BidiText extends StatelessWidget {
  /// Creates a [BidiText] widget with a plain string.
  ///
  /// Direction is detected from [data] up to [sampleLength] characters.
  const BidiText(
    String this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.sampleLength = 50,
  }) : textSpan = null;

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
  const BidiText.rich(
    InlineSpan this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.sampleLength = 50,
  }) : data = null;

  /// The plain text string. Non-null only when using the primary constructor.
  final String? data;

  /// The [InlineSpan] for rich text. Non-null only when using [BidiText.rich].
  final InlineSpan? textSpan;

  /// The text style to apply. Defaults to ambient [DefaultTextStyle].
  final TextStyle? style;

  /// {@macro flutter.widgets.editableText.strutStyle}
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// Used to select a font when the same Unicode character can be rendered
  /// differently depending on the locale.
  final Locale? locale;

  /// Whether the text should break at soft line breaks.
  final bool? softWrap;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// {@macro flutter.painting.textPainter.textScaler}
  final TextScaler? textScaler;

  /// Maximum number of lines to show.
  final int? maxLines;

  /// An optional semantics label for this widget.
  final String? semanticsLabel;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// {@macro flutter.dart:ui.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

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

  TextDirection? get textDirection {
    if (textSpan != null) {
      final extracted = _extractFromSpan(textSpan!);
      if (extracted.isEmpty) return null;
      final sampleSize = sampleLength ?? extracted.length;
      final sample =
          extracted.substring(0, math.min(sampleSize, extracted.length));
      return BidiHelper.estimateDirectionOfText(sample);
    }
    final text = data!;
    if (text.isEmpty) return null;
    final sampleSize = sampleLength ?? text.length;
    final sample = text.substring(0, math.min(sampleSize, text.length));
    return BidiHelper.estimateDirectionOfText(sample);
  }

  /// Extracts plain text from an [InlineSpan] tree for direction detection.
  /// [WidgetSpan] nodes are skipped — they contain no text content.
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
      // WidgetSpan has no text — skip.
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final dir = textDirection;
    if (textSpan != null) {
      return Text.rich(
        textSpan!,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: dir,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }
    return Text(
      data!,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: dir,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
