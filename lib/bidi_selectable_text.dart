import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bidi_text/helpers/bidi_helper.dart';

/// A selectable text widget that automatically detects and sets text direction
/// based on content.
///
/// `BidiSelectableText` wraps Flutter's standard [SelectableText] widget but
/// automatically determines whether the text should be displayed in
/// right-to-left (RTL) or left-to-right (LTR) direction based on the content
/// of the text itself.
///
/// This is particularly useful for applications that support multiple languages
/// with different text directions and need selectable read-only content (e.g.,
/// article bodies, user profiles, chat messages in read mode).
///
/// Use the primary constructor for plain strings and [BidiSelectableText.rich]
/// for styled [TextSpan] trees (mirrors [SelectableText.rich]).
///
/// Example:
///
/// ```dart
/// // Automatically selectable with LTR direction
/// BidiSelectableText('Hello world!')
///
/// // Automatically selectable with RTL direction
/// BidiSelectableText('مرحبا بالعالم!')
///
/// // Styled selectable text (mirrors SelectableText.rich):
/// BidiSelectableText.rich(
///   TextSpan(children: [
///     TextSpan(text: 'مرحبا ', style: TextStyle(fontWeight: FontWeight.bold)),
///     TextSpan(text: 'world'),
///   ]),
/// )
/// ```
class BidiSelectableText extends StatelessWidget {
  /// Creates a [BidiSelectableText] widget with a plain string.
  ///
  /// Direction is detected from [data] up to [sampleLength] characters.
  const BidiSelectableText(
    String this.data, {
    super.key,
    this.focusNode,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textScaler,
    this.showCursor = false,
    this.autofocus = false,
    this.minLines,
    this.maxLines,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.onTap,
    this.scrollPhysics,
    this.semanticsLabel,
    this.textHeightBehavior,
    this.textWidthBasis,
    this.onSelectionChanged,
    this.contextMenuBuilder,
    this.magnifierConfiguration,
    this.sampleLength = 50,
  }) : textSpan = null;

  /// Creates a [BidiSelectableText] widget with a [TextSpan] — a drop-in
  /// replacement for [SelectableText.rich].
  ///
  /// Direction is detected by extracting all text from the [TextSpan] tree
  /// (nested [TextSpan] children are traversed; [WidgetSpan] nodes are ignored).
  ///
  /// Example:
  /// ```dart
  /// BidiSelectableText.rich(
  ///   TextSpan(children: [
  ///     TextSpan(text: 'مرحبا '),
  ///     TextSpan(text: 'world', style: TextStyle(color: Colors.blue)),
  ///   ]),
  /// )
  /// ```
  const BidiSelectableText.rich(
    TextSpan this.textSpan, {
    super.key,
    this.focusNode,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textScaler,
    this.showCursor = false,
    this.autofocus = false,
    this.minLines,
    this.maxLines,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.onTap,
    this.scrollPhysics,
    this.semanticsLabel,
    this.textHeightBehavior,
    this.textWidthBasis,
    this.onSelectionChanged,
    this.contextMenuBuilder,
    this.magnifierConfiguration,
    this.sampleLength = 50,
  }) : data = null;

  /// The plain text string. Non-null only when using the primary constructor.
  final String? data;

  /// The [TextSpan] for rich text. Non-null only when using [BidiSelectableText.rich].
  final TextSpan? textSpan;

  /// {@macro flutter.widgets.editableText.focusNode}
  final FocusNode? focusNode;

  /// The text style to apply. If null, inherits from the ambient [DefaultTextStyle].
  final TextStyle? style;

  /// {@macro flutter.widgets.editableText.strutStyle}
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// {@macro flutter.widgets.editableText.textScaler}
  final TextScaler? textScaler;

  /// {@macro flutter.widgets.editableText.showCursor}
  final bool showCursor;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// The minimum number of lines to occupy. See [SelectableText.minLines].
  final int? minLines;

  /// The maximum number of lines. See [SelectableText.maxLines].
  final int? maxLines;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius? cursorRadius;

  /// The color of the cursor. Defaults to the theme's [ThemeData.colorScheme].
  final Color? cursorColor;

  /// Controls how tall the selection highlight boxes are. See [SelectableText].
  final ui.BoxHeightStyle selectionHeightStyle;

  /// Controls how wide the selection highlight boxes are. See [SelectableText].
  final ui.BoxWidthStyle selectionWidthStyle;

  /// {@macro flutter.widgets.editableText.enableInteractiveSelection}
  final bool enableInteractiveSelection;

  /// Optional delegate for building the text selection controls.
  final TextSelectionControls? selectionControls;

  /// Called when the user taps on the text.
  final GestureTapCallback? onTap;

  /// {@macro flutter.widgets.editableText.scrollPhysics}
  final ScrollPhysics? scrollPhysics;

  /// An optional semantics label for this widget. See [SelectableText.semanticsLabel].
  final String? semanticsLabel;

  /// {@macro flutter.dart:ui.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// Called when the user changes the selection (including cursor position).
  final SelectionChangedCallback? onSelectionChanged;

  /// Builds the text selection context menu. Defaults to the platform adaptive
  /// toolbar.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// {@macro flutter.widgets.magnifier.TextMagnifierConfiguration.intro}
  final TextMagnifierConfiguration? magnifierConfiguration;

  /// Maximum number of characters to sample for direction detection.
  ///
  /// If null, the entire text will be analyzed.
  /// If specified, only up to this many characters from the beginning of the
  /// text will be used to determine directionality.
  ///
  /// Default is 50 characters, which provides a good balance between
  /// performance and accuracy for most text.
  final int? sampleLength;

  TextDirection? _detectDirection() {
    final String textContent;
    if (textSpan != null) {
      textContent = _extractFromSpan(textSpan!);
    } else {
      textContent = data!;
    }
    if (textContent.isEmpty) return null;
    final sampleSize = sampleLength ?? textContent.length;
    final sample =
        textContent.substring(0, math.min(sampleSize, textContent.length));
    return BidiHelper.estimateDirectionOfText(sample);
  }

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
    final TextDirection? direction = _detectDirection();

    if (textSpan != null) {
      return SelectableText.rich(
        textSpan!,
        key: key,
        focusNode: focusNode,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: direction,
        textScaler: textScaler,
        showCursor: showCursor,
        autofocus: autofocus,
        minLines: minLines,
        maxLines: maxLines,
        cursorWidth: cursorWidth,
        cursorHeight: cursorHeight,
        cursorRadius: cursorRadius,
        cursorColor: cursorColor,
        selectionHeightStyle: selectionHeightStyle,
        selectionWidthStyle: selectionWidthStyle,
        enableInteractiveSelection: enableInteractiveSelection,
        selectionControls: selectionControls,
        onTap: onTap,
        scrollPhysics: scrollPhysics,
        semanticsLabel: semanticsLabel,
        textHeightBehavior: textHeightBehavior,
        textWidthBasis: textWidthBasis,
        onSelectionChanged: onSelectionChanged,
        contextMenuBuilder: contextMenuBuilder,
        magnifierConfiguration: magnifierConfiguration,
      );
    }

    return SelectableText(
      data!,
      key: key,
      focusNode: focusNode,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: direction,
      textScaler: textScaler,
      showCursor: showCursor,
      autofocus: autofocus,
      minLines: minLines,
      maxLines: maxLines,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      selectionHeightStyle: selectionHeightStyle,
      selectionWidthStyle: selectionWidthStyle,
      enableInteractiveSelection: enableInteractiveSelection,
      selectionControls: selectionControls,
      onTap: onTap,
      scrollPhysics: scrollPhysics,
      semanticsLabel: semanticsLabel,
      textHeightBehavior: textHeightBehavior,
      textWidthBasis: textWidthBasis,
      onSelectionChanged: onSelectionChanged,
      contextMenuBuilder: contextMenuBuilder,
      magnifierConfiguration: magnifierConfiguration,
    );
  }
}
