import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bidi_text/helpers/bidi_helper.dart';

/// A text field widget that automatically detects and sets text direction based on content.
///
/// `BidiTextField` extends Flutter's standard [TextField] widget but automatically determines
/// whether the text should be displayed in right-to-left (RTL) or left-to-right (LTR)
/// direction based on the content of the text itself.
///
/// This is particularly useful for applications that support multiple languages with
/// different text directions, as it eliminates the need to manually specify direction.
///
/// Example:
///
/// ```dart
/// BidiTextField(
///   decoration: InputDecoration(hintText: 'Enter text'),
///   onDirectionChanged: (direction) {
///     print('Text direction changed to: $direction');
///   },
/// )
/// ```
class BidiTextField extends TextField {
  const BidiTextField({
    super.key,
    super.groupId = EditableText,
    super.controller,
    super.focusNode,
    super.undoController,
    super.decoration = const InputDecoration(),
    TextInputType? keyboardType,
    super.textInputAction,
    super.textCapitalization = TextCapitalization.none,
    super.style,
    super.strutStyle,
    super.textAlign = TextAlign.start,
    super.textAlignVertical,
    super.textDirection,
    super.readOnly = false,
    super.showCursor,
    super.autofocus = false,
    super.statesController,
    super.obscuringCharacter = '•',
    super.obscureText = false,
    super.autocorrect = true,
    super.smartDashesType,
    super.smartQuotesType,
    super.enableSuggestions = true,
    super.maxLines = 1,
    super.minLines,
    super.expands = false,
    super.maxLength,
    super.maxLengthEnforcement,
    super.onChanged,
    super.onEditingComplete,
    super.onSubmitted,
    super.onAppPrivateCommand,
    super.inputFormatters,
    super.enabled,
    super.ignorePointers,
    super.cursorWidth = 2.0,
    super.cursorHeight,
    super.cursorRadius,
    super.cursorOpacityAnimates,
    super.cursorColor,
    super.cursorErrorColor,
    super.selectionHeightStyle = ui.BoxHeightStyle.tight,
    super.selectionWidthStyle = ui.BoxWidthStyle.tight,
    super.keyboardAppearance,
    super.scrollPadding = const EdgeInsets.all(20.0),
    super.dragStartBehavior = DragStartBehavior.start,
    super.enableInteractiveSelection,
    super.selectionControls,
    super.onTap,
    super.onTapAlwaysCalled = false,
    super.onTapOutside,
    super.mouseCursor,
    super.buildCounter,
    super.scrollController,
    super.scrollPhysics,
    super.autofillHints = const <String>[],
    super.contentInsertionConfiguration,
    super.clipBehavior = Clip.hardEdge,
    super.restorationId,
    super.enableIMEPersonalizedLearning = true,
    super.contextMenuBuilder = _defaultContextMenuBuilder,
    super.canRequestFocus = true,
    super.spellCheckConfiguration,
    super.magnifierConfiguration,
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
        // Assert the following instead of setting it directly to avoid surprising the user by silently changing the value they set.
        assert(
          !identical(textInputAction, TextInputAction.newline) ||
              maxLines == 1 ||
              !identical(keyboardType, TextInputType.text),
          'Use keyboardType TextInputType.multiline when using TextInputAction.newline on a multiline TextField.',
        );

  /// Maximum number of characters to sample for direction detection.
  ///
  /// If null, the entire text will be analyzed.
  /// If specified, only up to this many characters from the beginning of the text
  /// will be used to determine directionality.
  ///
  /// Default is 50 characters, which provides a good balance between performance
  /// and accuracy for most text.
  final int? sampleLength;

  /// Callback that is called when the text direction changes
  ///
  /// This callback is triggered when the text direction is automatically
  /// detected based on the content and changes from LTR to RTL or vice versa.
  ///
  /// The callback receives the new text direction, or `null` if the field is empty.
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
  String _previousSample = ''; // Store previous sample for comparison
  bool _initialDirectionSet = false; // Track initial direction setup

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    // Listen for changes to update direction and alignment
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
      // Only dispose the controller if we created it
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

      // Only update direction if the relevant portion of text has changed
      if (currentSample != _previousSample) {
        _previousSample = currentSample;
        _updateTextDirection(text);
      }
    });
  }

  void _updateTextDirection(String text) {
    final sampleSize = widget.sampleLength ?? text.length;
    final sample = text.substring(0, math.min(sampleSize, text.length));
    final newDirection = _getTextDirection(sample);

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

  TextDirection? _getTextDirection(String text) {
    return BidiHelper.estimateDirectionOfText(text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: widget.key,
      controller: _controller,
      focusNode: widget.focusNode,
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
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorColor: widget.cursorColor,
      selectionHeightStyle: widget.selectionHeightStyle,
      selectionWidthStyle: widget.selectionWidthStyle,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      dragStartBehavior: widget.dragStartBehavior,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectionControls: widget.selectionControls,
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
      mouseCursor: widget.mouseCursor,
      buildCounter: widget.buildCounter,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      clipBehavior: widget.clipBehavior,
      restorationId: widget.restorationId,
      enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
      contextMenuBuilder: widget.contextMenuBuilder,
      canRequestFocus: widget.canRequestFocus,
      spellCheckConfiguration: widget.spellCheckConfiguration,
      magnifierConfiguration: widget.magnifierConfiguration,
    );
  }
}
