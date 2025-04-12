import 'package:flutter/material.dart';
import 'package:flutter_bidi_text/bidi_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BidiText Widget Tests', () {
    testWidgets('LTR text detection', (WidgetTester tester) async {
      // Build the widget with English text (LTR)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiText('Hello world'),
          ),
        ),
      );

      // Find the widget
      final textFinder = find.byType(BidiText);
      expect(textFinder, findsOneWidget);

      // Check the text direction
      final BidiText bidiText = tester.widget(textFinder);
      expect(bidiText.textDirection, TextDirection.ltr);
    });

    testWidgets('RTL text detection', (WidgetTester tester) async {
      // Build the widget with Arabic text (RTL)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiText('مرحبا بالعالم'),
          ),
        ),
      );

      // Find the widget
      final textFinder = find.byType(BidiText);
      expect(textFinder, findsOneWidget);

      // Check the text direction
      final BidiText bidiText = tester.widget(textFinder);
      expect(bidiText.textDirection, TextDirection.rtl);
    });

    testWidgets('Mixed content with dominant LTR', (WidgetTester tester) async {
      // Build the widget with mixed text (more English than Arabic)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiText('Hello world with some مرحبا text'),
          ),
        ),
      );

      // Find the widget
      final textFinder = find.byType(BidiText);
      expect(textFinder, findsOneWidget);

      // Check the text direction
      final BidiText bidiText = tester.widget(textFinder);
      expect(bidiText.textDirection, TextDirection.ltr);
    });

    testWidgets('Mixed content with dominant RTL', (WidgetTester tester) async {
      // Build the widget with mixed text (more Arabic than English)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiText('مرحبا بالعالم مع بعض hello text'),
          ),
        ),
      );

      // Find the widget
      final textFinder = find.byType(BidiText);
      expect(textFinder, findsOneWidget);

      // Check the text direction
      final BidiText bidiText = tester.widget(textFinder);
      expect(bidiText.textDirection, TextDirection.rtl);
    });

    testWidgets('Empty text handling', (WidgetTester tester) async {
      // Build the widget with empty text
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiText(''),
          ),
        ),
      );

      // Find the widget
      final textFinder = find.byType(BidiText);
      expect(textFinder, findsOneWidget);

      // Check the text direction - should be null for empty text
      final BidiText bidiText = tester.widget(textFinder);
      expect(bidiText.textDirection, null);
    });

    testWidgets('Sample length limiting works', (WidgetTester tester) async {
      // Long string with RTL at the beginning and LTR later
      final String longText =
          'مرحبا بالعالم${' Hello world' * 20}'; // RTL at start, then lots of LTR

      // First test with small sample length (should detect RTL)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiText(
              longText,
              sampleLength: 10, // Only sample first 10 chars (only RTL content)
            ),
          ),
        ),
      );

      BidiText bidiText = tester.widget(find.byType(BidiText));
      expect(bidiText.textDirection, TextDirection.rtl);

      // Now test with larger sample that includes the English text
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiText(
              longText,
              sampleLength:
                  200, // Sample enough to include plenty of LTR content
            ),
          ),
        ),
      );

      bidiText = tester.widget(find.byType(BidiText));
      expect(bidiText.textDirection, TextDirection.ltr);
    });

    testWidgets('Null sampleLength uses full text',
        (WidgetTester tester) async {
      // Text with LTR dominant when considering the whole string
      final String mixedText =
          'مرحبا${' Hello world' * 5}'; // Small RTL at start, then lots of LTR

      // Test with null sampleLength - should use all text and detect LTR
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiText(
              mixedText,
              sampleLength: null, // Use all text for detection
            ),
          ),
        ),
      );

      final BidiText bidiText = tester.widget(find.byType(BidiText));
      expect(bidiText.textDirection, TextDirection.ltr);
    });
  });
}
