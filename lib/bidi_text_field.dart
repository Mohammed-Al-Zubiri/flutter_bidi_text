import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bidi_text/helpers/bidi_helper.dart';

/// A text field widget that automatically detects and sets text direction based on content.
///
/// `BidiTextField` is a [StatefulWidget] that wraps Flutter's standard [TextField]
/// and automatically determines whether the text should be displayed in
/// right-to-left (RTL) or left-to-right (LTR) direction based on its content.
///
/// This is particularly useful for applications that support multiple languages
/// with different text directions, as it eliminates the need to manually specify
/// direction.
///
/// ## Breaking change (v2.0.0)
/// `BidiTextField` no longer extends [TextField]. It extends [StatefulWidget]
/// and builds a [TextField] internally. If your code relied on
/// `bidiTextFieldInstance is TextField` type checks, update them —
/// all widget behaviour is identical.
///
/// Example:
///
/// ```dart
/// BidiTextField(
///   decoration: InputDecoration(hintText: 'Enter text'),
///   onDirectionChanged: (TextDirection direction) {
///     print('Text direction changed to: $direction');
///   },
/// )
/// ```
class BidiTextField extends StatefulWidget {
  const BidiTextField({
    super.key,
    this.groupId = EditableText,
    this.controller,
    this.focusNode,
    this.undoController,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.statesController,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.ignorePointers,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.cursorColor,
    this.cursorErrorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection,
    this.selectionControls,
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.mouseCursor,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.contentInsertionConfiguration,
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    this.stylusHandwritingEnabled = true,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.sampleLength = 50,
    this.onDirectionChanged,
  })  : assert(obscuringCharacter.length == 1),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
          (maxLines == null) || (minLines == null) || (maxLines >= minLines),
          "minLines can't be greater than maxLines",
        ),
        assert(
          !expands || (maxLines == null && minLines == null),
          'minLines and maxLines must be null when expands is true.',
        ),
        assert(!obscureText || maxLines == 1,
            'Obscured fields cannot be multiline.'),
        assert(maxLength == null ||
            maxLength == TextField.noMaxLength ||
            maxLength > 0),
        assert(
          !identical(textInputAction, TextInputAction.newline) ||
              maxLines == 1 ||
              !identical(keyboardType, TextInputType.text),
          'Use keyboardType TextInputType.multiline when using TextInputAction.newline on a multiline TextField.',
        );

  // ── Identity / focus ────────────────────────────────────────────────────────
  final Object groupId;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final UndoHistoryController? undoController;

  // ── Decoration / appearance ──────────────────────────────────────────────────
  final InputDecoration? decoration;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;

  // ── Input behaviour ──────────────────────────────────────────────────────────
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final bool? showCursor;
  final bool autofocus;
  final WidgetStatesController? statesController;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;

  // ── Line limits ──────────────────────────────────────────────────────────────
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;

  // ── Callbacks ────────────────────────────────────────────────────────────────
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final AppPrivateCommandCallback? onAppPrivateCommand;

  // ── Formatters ───────────────────────────────────────────────────────────────
  final List<TextInputFormatter>? inputFormatters;

  // ── Enable / pointer ─────────────────────────────────────────────────────────
  final bool? enabled;
  final bool? ignorePointers;

  // ── Cursor ───────────────────────────────────────────────────────────────────
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final bool? cursorOpacityAnimates;
  final Color? cursorColor;
  final Color? cursorErrorColor;

  // ── Selection styling ────────────────────────────────────────────────────────
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;

  // ── Keyboard / scroll ────────────────────────────────────────────────────────
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final DragStartBehavior dragStartBehavior;
  final bool? enableInteractiveSelection;
  final TextSelectionControls? selectionControls;

  // ── Tap ──────────────────────────────────────────────────────────────────────
  final GestureTapCallback? onTap;
  final bool onTapAlwaysCalled;
  final TapRegionCallback? onTapOutside;

  // ── Mouse / accessibility ────────────────────────────────────────────────────
  final MouseCursor? mouseCursor;
  final InputCounterWidgetBuilder? buildCounter;

  // ── Scroll ───────────────────────────────────────────────────────────────────
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;

  // ── Autofill / content insertion ─────────────────────────────────────────────
  final Iterable<String>? autofillHints;
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  // ── Clip / restoration ───────────────────────────────────────────────────────
  final Clip clipBehavior;
  final String? restorationId;

  // ── Platform-specific ────────────────────────────────────────────────────────
  final bool enableIMEPersonalizedLearning;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final bool stylusHandwritingEnabled;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final TextMagnifierConfiguration? magnifierConfiguration;

  // ── Bidi-specific ────────────────────────────────────────────────────────────

  /// Maximum number of characters to sample for direction detection.
  ///
  /// If null, the entire text will be analyzed.
  /// If specified, only up to this many characters from the beginning of the
  /// text will be used to determine directionality.
  ///
  /// Default is 50 characters, which provides a good balance between
  /// performance and accuracy for most text.
  final int? sampleLength;

  /// Callback that is called when the text direction changes.
  ///
  /// This callback is triggered when the text direction is automatically
  /// detected based on the content and changes from LTR to RTL or vice versa.
  ///
  /// The callback always receives a non-null [TextDirection]. When the field is
  /// empty or the content is directionally neutral, the ambient
  /// [Directionality.of] value is used as the fallback direction.
  final ValueChanged<TextDirection>? onDirectionChanged;

  static Widget _defaultContextMenuBuilder(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  @override
  State<BidiTextField> createState() => _BidiTextFieldState();
}

class _BidiTextFieldState extends State<BidiTextField> {
  late TextEditingController _controller;
  TextDirection? _textDirection;
  Timer? _debounceTimer;
  String _previousSample = '';
  bool _initialDirectionSet = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialDirectionSet) {
      if (_controller.text.isNotEmpty) {
        _updateTextDirection(_controller.text);
      }
      _initialDirectionSet = true;
    }
  }

  @override
  void didUpdateWidget(BidiTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onTextChanged);
      _controller = widget.controller ?? TextEditingController();
      _updateTextDirection(_controller.text);
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
      final text = _controller.text;
      final sampleSize = widget.sampleLength ?? text.length;
      final currentSample = text.isEmpty
          ? ''
          : text.substring(0, math.min(sampleSize, text.length));
      if (currentSample != _previousSample) {
        _previousSample = currentSample;
        _updateTextDirection(text);
      }
    });
  }

  void _updateTextDirection(String text) {
    final sampleSize = widget.sampleLength ?? text.length;
    final sample = text.substring(0, math.min(sampleSize, text.length));
    final newDirection = BidiHelper.estimateDirectionOfText(sample);

    if (_textDirection != newDirection) {
      setState(() {
        _textDirection = newDirection;
      });
      if (widget.onDirectionChanged == null) return;
      if (newDirection == null) {
        if (mounted) widget.onDirectionChanged!(Directionality.of(context));
      } else {
        widget.onDirectionChanged!(newDirection);
      }
      return;
    }

    if (widget.onDirectionChanged != null && newDirection == null) {
      if (mounted) widget.onDirectionChanged!(Directionality.of(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      groupId: widget.groupId,
      controller: _controller,
      focusNode: widget.focusNode,
      undoController: widget.undoController,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      textDirection: _textDirection,
      readOnly: widget.readOnly,
      showCursor: widget.showCursor,
      autofocus: widget.autofocus,
      statesController: widget.statesController,
      obscuringCharacter: widget.obscuringCharacter,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      onAppPrivateCommand: widget.onAppPrivateCommand,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      ignorePointers: widget.ignorePointers,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorOpacityAnimates: widget.cursorOpacityAnimates,
      cursorColor: widget.cursorColor,
      cursorErrorColor: widget.cursorErrorColor,
      selectionHeightStyle: widget.selectionHeightStyle,
      selectionWidthStyle: widget.selectionWidthStyle,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      dragStartBehavior: widget.dragStartBehavior,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectionControls: widget.selectionControls,
      onTap: widget.onTap,
      onTapAlwaysCalled: widget.onTapAlwaysCalled,
      onTapOutside: widget.onTapOutside,
      mouseCursor: widget.mouseCursor,
      buildCounter: widget.buildCounter,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      contentInsertionConfiguration: widget.contentInsertionConfiguration,
      clipBehavior: widget.clipBehavior,
      restorationId: widget.restorationId,
      enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
      contextMenuBuilder: widget.contextMenuBuilder,
      stylusHandwritingEnabled: widget.stylusHandwritingEnabled,
      spellCheckConfiguration: widget.spellCheckConfiguration,
      magnifierConfiguration: widget.magnifierConfiguration,
    );
  }
}
