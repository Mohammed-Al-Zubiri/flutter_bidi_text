// ignore_for_file: constant_identifier_names

import 'dart:ui';

/// A utility class that provides methods for detecting and estimating text directionality.
///
/// This class contains methods to analyze text content and determine whether it should be
/// displayed in right-to-left (RTL) or left-to-right (LTR) direction based on the characters
/// it contains.
class BidiHelper {
  /// Constant to define the threshold of RTL directionality.
  /// If the number of RTL words is above this percentage of the total number
  /// of strongly directional words, the text is considered RTL.
  static const double _RTL_DETECTION_THRESHOLD = 0.40;

  /// Character sets for identifying strong LTR and RTL characters.
  /// These patterns are simplified for performance and small code size.
  static const String _LTR_CHARS = r'A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02B8\u0300-\u0590'
      r'\u0800-\u1FFF\u2C00-\uFB1C\uFDFE-\uFE6F\uFEFD-\uFFFF';
  static const String _RTL_CHARS = r'\u0591-\u07FF\uFB1D-\uFDFD\uFE70-\uFEFC';

  /// Returns the input [text] with spaces instead of HTML tags or HTML escapes,
  /// which is helpful for text directionality estimation.
  ///
  /// Note: This function should not be used in other contexts.
  /// It does not deal well with many things: comments, script,
  /// elements, style elements, dir attribute,`>` in quoted attribute values,
  /// etc. But it does handle well enough the most common use cases.
  /// Since the worst that can happen as a result of these shortcomings is that
  /// the wrong directionality will be estimated, we have not invested in
  /// improving this.
  static String stripHtmlIfNeeded(String text) {
    // The regular expression is simplified for an HTML tag (opening or
    // closing) or an HTML escape. We might want to skip over such expressions
    // when estimating the text directionality.
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
  }

  /// Determines if the first character in [text] with strong directionality is
  /// RTL. If [isHtml] is true, the text is HTML or HTML-escaped.
  static bool startsWithRtl(String text, [bool isHtml = false]) {
    return RegExp('^[^$_LTR_CHARS]*[$_RTL_CHARS]').hasMatch(isHtml ? stripHtmlIfNeeded(text) : text);
  }

  /// Determines if the given [text] has any LTR characters in it.
  /// If [isHtml] is true, the text is HTML or HTML-escaped.
  static bool hasAnyLtr(String text, [bool isHtml = false]) {
    return RegExp(r'[' '$_LTR_CHARS' r']').hasMatch(isHtml ? stripHtmlIfNeeded(text) : text);
  }

  /// Estimates the directionality of [text] using the best known
  /// general-purpose method (using relative word counts). A
  /// null return value indicates completely neutral input.
  /// [isHtml] is true if [text] HTML or HTML-escaped.
  ///
  /// If the number of RTL words is above a certain percentage of the total
  /// number of strongly directional words, returns RTL.
  /// Otherwise, if any words are strongly or weakly LTR, returns LTR.
  /// Otherwise, returns null, which is used to mean `neutral`.
  /// Numbers and URLs are counted as weakly LTR.
  static TextDirection? estimateDirectionOfText(String text, {bool isHtml = false}) {
    text = isHtml ? stripHtmlIfNeeded(text) : text;
    var rtlCount = 0;
    var total = 0;
    var hasWeaklyLtr = false;
    // Split a string into 'words' for directionality estimation based on
    // relative word counts.
    for (var token in text.split(RegExp(r'\s+'))) {
      if (startsWithRtl(token)) {
        rtlCount++;
        total++;
      } else if (RegExp(r'^http://').hasMatch(token)) {
        // Checked if token looks like something that must always be LTR even in
        // RTL text, such as a URL.
        hasWeaklyLtr = true;
      } else if (hasAnyLtr(token)) {
        total++;
      } else if (RegExp(r'\d').hasMatch(token)) {
        // Checked if token contains any numerals.
        hasWeaklyLtr = true;
      }
    }

    if (total == 0) {
      return hasWeaklyLtr ? TextDirection.ltr : null;
    } else if (rtlCount > _RTL_DETECTION_THRESHOLD * total) {
      return TextDirection.rtl;
    } else {
      return TextDirection.ltr;
    }
  }

  /// Check the estimated directionality of [str], return true if the piece of
  /// text should be laid out in RTL direction. If [isHtml] is true, the string
  /// is HTML or HTML-escaped.
  static bool detectRtlDirectionality(String str, {bool isHtml = false}) =>
      estimateDirectionOfText(str, isHtml: isHtml) == TextDirection.rtl;
}
