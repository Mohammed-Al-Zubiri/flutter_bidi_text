import 'package:flutter/material.dart';
import 'package:flutter_bidi_text/bidi_selectable_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BidiSelectableText Widget Tests', () {
    testWidgets('LTR plain text is detected as LTR',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiSelectableText('Hello world'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The inner SelectableText should receive TextDirection.ltr.
      final st = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(st.textDirection, TextDirection.ltr);
    });

    testWidgets('RTL plain text is detected as RTL',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiSelectableText('مرحبا بالعالم'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final st = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(st.textDirection, TextDirection.rtl);
    });

    testWidgets('Empty string returns null direction',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiSelectableText(''),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final st = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(st.textDirection, isNull);
    });

    testWidgets('sampleLength limits analysis to first N characters',
        (WidgetTester tester) async {
      // RTL word at start, then lots of LTR
      const String mixed = 'مرحبا Hello Hello Hello Hello Hello';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiSelectableText(mixed, sampleLength: 5),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final st = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(st.textDirection, TextDirection.rtl);
    });
  });

  group('BidiSelectableText.rich Widget Tests', () {
    testWidgets('LTR TextSpan detected as LTR', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiSelectableText.rich(
              TextSpan(children: [
                TextSpan(text: 'Hello '),
                TextSpan(text: 'world'),
              ]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final st = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(st.textDirection, TextDirection.ltr);
    });

    testWidgets('RTL TextSpan detected as RTL', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiSelectableText.rich(
              TextSpan(children: [
                TextSpan(text: 'مرحبا '),
                TextSpan(text: 'بالعالم'),
              ]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final st = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(st.textDirection, TextDirection.rtl);
    });

    testWidgets('Empty TextSpan returns null direction',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiSelectableText.rich(TextSpan(text: '')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final st = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(st.textDirection, isNull);
    });

    testWidgets('Nested TextSpan children are traversed correctly',
        (WidgetTester tester) async {
      // RTL text is in a nested child
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiSelectableText.rich(
              TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: '',
                    children: [
                      TextSpan(text: 'مرحبا بالعالم'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final st = tester.widget<SelectableText>(find.byType(SelectableText));
      expect(st.textDirection, TextDirection.rtl);
    });
  });
}
