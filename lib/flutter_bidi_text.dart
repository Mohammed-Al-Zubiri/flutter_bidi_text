/// Flutter package for text widgets with automatic bidirectional text direction detection
///
/// This package provides three main widgets:
/// * [BidiText] - A Text widget with automatic direction detection
/// * [BidiTextField] - A TextField with automatic direction detection
/// * [BidiTextFormField] - A TextFormField with automatic direction detection
///
/// It also exports utility functions for direction detection that can be used separately.
library flutter_bidi_text;

// Reexport the main widget classes
export 'package:flutter_bidi_text/bidi_text.dart';
export 'package:flutter_bidi_text/bidi_text_field.dart';
export 'package:flutter_bidi_text/bidi_text_form_field.dart';

// Reexport utility functions for direction detection
export 'package:flutter_bidi_text/helpers/bidi_helper.dart' show BidiHelper;
