import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bidi_text/bidi_text_field.dart';

export 'package:flutter/services.dart' show SmartDashesType, SmartQuotesType;

/// A [FormField] that contains a [BidiTextField].
///
/// This is a convenience widget that wraps a [BidiTextField] widget in a
/// [FormField] with automatic text direction detection based on content.
///
/// The text direction will automatically adjust based on the content being typed.
/// Use the [onDirectionChanged] callback to be notified when the text direction changes.
///
/// When implementing validators, remember that text may be in either RTL or LTR format
/// depending on content. Consider this when validating patterns or formatting.
///
/// For a documentation about the various parameters, see [TextField] and [BidiTextField].
///
/// {@tool snippet}
///
/// Creates a [BidiTextFormField] with an [InputDecoration] and validator function.
/// The field will automatically adjust text direction based on the content.

/// ```dart
/// BidiTextFormField(
///   decoration: const InputDecoration(
///     icon: Icon(Icons.person),
///     hintText: 'What do people call you?',
///     labelText: 'Name *',
///   ),
///   onDirectionChanged: (direction) {
///     print('Text direction changed to: $direction');
///   },
///   onSaved: (String? value) {
///     // This optional block of code can be used to run
///     // code when the user saves the form.
///   },
///   validator: (String? value) {
///     return (value != null && value.contains('@')) ? 'Do not use the @ char.' : null;
///   },
/// )
/// ```
/// {@end-tool}

class BidiTextFormField extends FormField<String> {
  /// Creates a [FormField] that contains a [BidiTextField].

  BidiTextFormField({
    super.key,
    this.groupId = EditableText,
    this.controller,
    String? initialValue,
    FocusNode? focusNode,
    super.forceErrorText,
    InputDecoration? decoration = const InputDecoration(),
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    bool? showCursor,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    this.onChanged,
    GestureTapCallback? onTap,
    bool onTapAlwaysCalled = false,
    TapRegionCallback? onTapOutside,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    super.onSaved,
    super.validator,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    bool? ignorePointers,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Color? cursorErrorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool? enableInteractiveSelection,
    TextSelectionControls? selectionControls,
    InputCounterWidgetBuilder? buildCounter,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    AutovalidateMode? autovalidateMode,
    ScrollController? scrollController,
    super.restorationId,
    bool enableIMEPersonalizedLearning = true,
    MouseCursor? mouseCursor,
    EditableTextContextMenuBuilder? contextMenuBuilder =
        _defaultContextMenuBuilder,
    SpellCheckConfiguration? spellCheckConfiguration,
    TextMagnifierConfiguration? magnifierConfiguration,
    UndoHistoryController? undoController,
    AppPrivateCommandCallback? onAppPrivateCommand,
    bool? cursorOpacityAnimates,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ContentInsertionConfiguration? contentInsertionConfiguration,
    WidgetStatesController? statesController,
    Clip clipBehavior = Clip.hardEdge,
    bool canRequestFocus = true,
    this.onDirectionChanged,
    this.sampleLength = 50,
  })  : assert(initialValue == null || controller == null),
        assert(obscuringCharacter.length == 1),
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
        super(
          initialValue:
              controller != null ? controller.text : (initialValue ?? ''),
          enabled: enabled ?? decoration?.enabled ?? true,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          builder: (FormFieldState<String> field) {
            final _BidiTextFormFieldState state =
                field as _BidiTextFormFieldState;
            final InputDecoration effectiveDecoration = (decoration ??
                    const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);
            void onChangedHandler(String value) {
              field.didChange(value);
              onChanged?.call(value);
            }

            return UnmanagedRestorationScope(
              bucket: field.bucket,
              child: BidiTextField(
                groupId: groupId,
                restorationId: restorationId,
                controller: state._effectiveController,
                focusNode: focusNode,
                decoration:
                    effectiveDecoration.copyWith(errorText: field.errorText),
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                style: style,
                strutStyle: strutStyle,
                textAlign: textAlign,
                textAlignVertical: textAlignVertical,
                textDirection: textDirection,
                textCapitalization: textCapitalization,
                autofocus: autofocus,
                statesController: statesController,
                readOnly: readOnly,
                showCursor: showCursor,
                obscuringCharacter: obscuringCharacter,
                obscureText: obscureText,
                autocorrect: autocorrect,
                smartDashesType: smartDashesType ??
                    (obscureText
                        ? SmartDashesType.disabled
                        : SmartDashesType.enabled),
                smartQuotesType: smartQuotesType ??
                    (obscureText
                        ? SmartQuotesType.disabled
                        : SmartQuotesType.enabled),
                enableSuggestions: enableSuggestions,
                maxLengthEnforcement: maxLengthEnforcement,
                maxLines: maxLines,
                minLines: minLines,
                expands: expands,
                maxLength: maxLength,
                onChanged: onChangedHandler,
                onTap: onTap,
                onTapAlwaysCalled: onTapAlwaysCalled,
                onTapOutside: onTapOutside,
                onEditingComplete: onEditingComplete,
                onSubmitted: onFieldSubmitted,
                inputFormatters: inputFormatters,
                enabled: enabled ?? decoration?.enabled ?? true,
                ignorePointers: ignorePointers,
                cursorWidth: cursorWidth,
                cursorHeight: cursorHeight,
                cursorRadius: cursorRadius,
                cursorColor: cursorColor,
                cursorErrorColor: cursorErrorColor,
                scrollPadding: scrollPadding,
                scrollPhysics: scrollPhysics,
                keyboardAppearance: keyboardAppearance,
                enableInteractiveSelection:
                    enableInteractiveSelection ?? (!obscureText || !readOnly),
                selectionControls: selectionControls,
                buildCounter: buildCounter,
                autofillHints: autofillHints,
                scrollController: scrollController,
                enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
                mouseCursor: mouseCursor,
                contextMenuBuilder: contextMenuBuilder,
                spellCheckConfiguration: spellCheckConfiguration,
                magnifierConfiguration: magnifierConfiguration,
                undoController: undoController,
                onAppPrivateCommand: onAppPrivateCommand,
                cursorOpacityAnimates: cursorOpacityAnimates,
                selectionHeightStyle: selectionHeightStyle,
                selectionWidthStyle: selectionWidthStyle,
                dragStartBehavior: dragStartBehavior,
                contentInsertionConfiguration: contentInsertionConfiguration,
                clipBehavior: clipBehavior,
                canRequestFocus: canRequestFocus,
                onDirectionChanged: onDirectionChanged,
                sampleLength: sampleLength,
              ),
            );
          },
        );

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController] and
  /// initialize its [TextEditingController.text] with [initialValue].
  final TextEditingController? controller;

  /// {@macro flutter.widgets.editableText.groupId}
  final Object groupId;

  /// Called when the user initiates a change to the TextField's value.
  ///
  /// This callback is called when the user has changed the text in the field,
  /// either by typing, pasting, or other text input gestures.
  final ValueChanged<String>? onChanged;

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
  FormFieldState<String> createState() => _BidiTextFormFieldState();
}

class _BidiTextFormFieldState extends FormFieldState<String> {
  RestorableTextEditingController? _controller;

  TextEditingController get _effectiveController =>
      _bidiTextFormField.controller ?? _controller!.value;

  BidiTextFormField get _bidiTextFormField => super.widget as BidiTextFormField;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    super.restoreState(oldBucket, initialRestore);
    if (_controller != null) {
      _registerController();
    }
    // Make sure to update the internal [FormFieldState] value to sync up with
    // text editing controller value.
    setValue(_effectiveController.text);
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  void initState() {
    super.initState();
    if (_bidiTextFormField.controller == null) {
      _createLocalController(widget.initialValue != null
          ? TextEditingValue(text: widget.initialValue!)
          : null);
    } else {
      _bidiTextFormField.controller!.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(BidiTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_bidiTextFormField.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _bidiTextFormField.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null &&
          _bidiTextFormField.controller == null) {
        _createLocalController(oldWidget.controller!.value);
      }

      if (_bidiTextFormField.controller != null) {
        setValue(_bidiTextFormField.controller!.text);
        if (oldWidget.controller == null) {
          unregisterFromRestoration(_controller!);
          _controller!.dispose();
          _controller = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _bidiTextFormField.controller?.removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChange(String? value) {
    super.didChange(value);

    if (_effectiveController.text != value) {
      _effectiveController.text = value ?? '';
    }
  }

  @override
  void reset() {
    // Set the controller value before calling super.reset() to let
    // _handleControllerChanged suppress the change.
    _effectiveController.text = widget.initialValue ?? '';
    super.reset();
    _bidiTextFormField.onChanged?.call(_effectiveController.text);
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController.text != value) {
      didChange(_effectiveController.text);
    }
  }
}
