import 'package:flutter/material.dart';
import 'package:flutter_bidi_text/bidi_rich_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BidiRichText Widget Tests', () {
    testWidgets('LTR text detection with simple TextSpan',
        (WidgetTester tester) async {
      // Build the widget with English text (LTR)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiRichText(
              text: const TextSpan(
                text: 'Hello world',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      );

      // Find the widget
      final finder = find.byType(BidiRichText);
      expect(finder, findsOneWidget);

      // Check the text direction
      final BidiRichText richTextWidget = tester.widget(finder);
      expect(richTextWidget.textDirection, TextDirection.ltr);
    });

    testWidgets('RTL text detection with simple TextSpan',
        (WidgetTester tester) async {
      // Build the widget with Arabic text (RTL)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiRichText(
              text: const TextSpan(
                text: 'مرحبا بالعالم',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      );

      // Find the widget
      final finder = find.byType(BidiRichText);
      expect(finder, findsOneWidget);

      // Check the text direction
      final BidiRichText bidiRichText = tester.widget(finder);
      expect(bidiRichText.textDirection, TextDirection.rtl);
    });

    testWidgets('Mixed content with dominant LTR in nested TextSpans',
        (WidgetTester tester) async {
      // Build the widget with mixed text (more English than Arabic)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiRichText(
              text: const TextSpan(
                text: 'Hello world with some ',
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: 'مرحبا',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' text'),
                ],
              ),
            ),
          ),
        ),
      );

      // Find the widget
      final richTextFinder = find.byType(BidiRichText);
      expect(richTextFinder, findsOneWidget);

      // Check the text direction
      final BidiRichText bidiRichText = tester.widget(richTextFinder);
      expect(bidiRichText.textDirection, TextDirection.ltr);
    });

    testWidgets('Mixed content with dominant RTL in nested TextSpans',
        (WidgetTester tester) async {
      // Build the widget with mixed text (more Arabic than English)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiRichText(
              text: const TextSpan(
                text: 'مرحبا بالعالم هذا نص طويل ',
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: 'with some English',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' في النهاية'),
                ],
              ),
            ),
          ),
        ),
      );

      // Find the widget
      final richTextFinder = find.byType(BidiRichText);
      expect(richTextFinder, findsOneWidget);

      // Check the text direction
      final BidiRichText bidiRichText = tester.widget(richTextFinder);
      expect(bidiRichText.textDirection, TextDirection.rtl);
    });

    testWidgets('Deeply nested TextSpans with LTR content',
        (WidgetTester tester) async {
      // Build the widget with deeply nested TextSpans
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiRichText(
              text: const TextSpan(
                text: 'First level ',
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: 'second level ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: 'third level',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Find the widget
      final richTextFinder = find.byType(BidiRichText);
      expect(richTextFinder, findsOneWidget);

      // Check the text direction
      final BidiRichText bidiRichText = tester.widget(richTextFinder);
      expect(bidiRichText.textDirection, TextDirection.ltr);
    });

    testWidgets('Deeply nested TextSpans with RTL content',
        (WidgetTester tester) async {
      // Build the widget with deeply nested TextSpans
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiRichText(
              text: const TextSpan(
                text: 'المستوى الأول ',
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: 'المستوى الثاني ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: 'المستوى الثالث',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Find the widget
      final richTextFinder = find.byType(BidiRichText);
      expect(richTextFinder, findsOneWidget);

      // Check the text direction
      final BidiRichText bidiRichText = tester.widget(richTextFinder);
      expect(bidiRichText.textDirection, TextDirection.rtl);
    });

    testWidgets('Empty TextSpan defaults to LTR', (WidgetTester tester) async {
      // Build the widget with empty text
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiRichText(
              text: const TextSpan(
                text: '',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      );

      // Find the widget
      final finder = find.byType(BidiRichText);
      expect(finder, findsOneWidget);

      // Check the text direction defaults to LTR
      final BidiRichText bidiRichText = tester.widget(finder);
      expect(bidiRichText.textDirection, TextDirection.ltr);
    });

    testWidgets('TextSpan with only children (no root text)',
        (WidgetTester tester) async {
      // Build the widget with TextSpan that has no text, only children
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiRichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(text: 'Hello '),
                  TextSpan(
                    text: 'world',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Find the widget
      final richTextFinder = find.byType(BidiRichText);
      expect(richTextFinder, findsOneWidget);

      // Check the text direction
      final BidiRichText bidiRichText = tester.widget(richTextFinder);
      expect(bidiRichText.textDirection, TextDirection.ltr);
    });

    testWidgets('TextSpan with WidgetSpan mixed in',
        (WidgetTester tester) async {
      // Build the widget with TextSpan containing WidgetSpan
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiRichText(
              text: const TextSpan(
                text: 'Hello ',
                style: TextStyle(color: Colors.black),
                children: [
                  WidgetSpan(
                    child: Icon(Icons.star, size: 16),
                  ),
                  TextSpan(text: ' world'),
                ],
              ),
            ),
          ),
        ),
      );

      // Find the widget
      final finder = find.byType(BidiRichText);
      expect(finder, findsOneWidget);

      // Check the text direction (WidgetSpan should be ignored in direction detection)
      final BidiRichText bidiRichText = tester.widget(finder);
      expect(bidiRichText.textDirection, TextDirection.ltr);
    });

    testWidgets('Sample length parameter affects detection',
        (WidgetTester tester) async {
      // Build the widget with a long mixed text but limited sample length
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiRichText(
              text: const TextSpan(
                text:
                    'Hello world this is a very long English text that goes on and on مرحبا بالعالم',
                style: TextStyle(color: Colors.black),
              ),
              sampleLength: 20, // Only sample first 20 characters
            ),
          ),
        ),
      );

      // Find the widget
      final finder = find.byType(BidiRichText);
      expect(finder, findsOneWidget);

      // Check the text direction (should be LTR based on first 20 chars)
      final BidiRichText bidiRichText = tester.widget(finder);
      expect(bidiRichText.textDirection, TextDirection.ltr);
    });

    testWidgets('Custom text styling properties are preserved',
        (WidgetTester tester) async {
      // Build the widget with custom properties
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiRichText(
              text: const TextSpan(
                text: 'Hello world',
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      // Find the widget
      final finder = find.byType(BidiRichText);
      expect(finder, findsOneWidget);

      // Verify custom properties are set
      final BidiRichText bidiRichText = tester.widget(finder);
      expect(bidiRichText.textAlign, TextAlign.center);
      expect(bidiRichText.maxLines, 2);
      expect(bidiRichText.overflow, TextOverflow.ellipsis);
    });
  });

  group('BidiRichText Text Extraction Tests', () {
    test('Extract text from simple TextSpan', () {
      const span = TextSpan(text: 'Hello world');
      final text = BidiRichText.extractTextFromSpan(span);
      expect(text, 'Hello world');
    });

    test('Extract text from nested TextSpans', () {
      const span = TextSpan(
        text: 'First ',
        children: [
          TextSpan(text: 'second '),
          TextSpan(text: 'third'),
        ],
      );
      final text = BidiRichText.extractTextFromSpan(span);
      expect(text, 'First second third');
    });

    test('Extract text from deeply nested TextSpans', () {
      const span = TextSpan(
        text: 'Level 1 ',
        children: [
          TextSpan(
            text: 'Level 2 ',
            children: [
              TextSpan(text: 'Level 3'),
            ],
          ),
        ],
      );
      final text = BidiRichText.extractTextFromSpan(span);
      expect(text, 'Level 1 Level 2 Level 3');
    });

    test('Extract text ignoring WidgetSpan', () {
      const span = TextSpan(
        text: 'Before ',
        children: [
          WidgetSpan(child: Icon(Icons.star)),
          TextSpan(text: 'After'),
        ],
      );
      final text = BidiRichText.extractTextFromSpan(span);
      expect(text, 'Before After');
    });

    test('Extract from TextSpan with only children', () {
      const span = TextSpan(
        children: [
          TextSpan(text: 'Child 1 '),
          TextSpan(text: 'Child 2'),
        ],
      );
      final text = BidiRichText.extractTextFromSpan(span);
      expect(text, 'Child 1 Child 2');
    });

    test('Extract from empty TextSpan', () {
      const span = TextSpan(text: '');
      final text = BidiRichText.extractTextFromSpan(span);
      expect(text, '');
    });
  });
}
