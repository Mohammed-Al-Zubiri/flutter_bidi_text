import 'package:flutter/material.dart';
// Import the entire package to test exports
import 'package:flutter_bidi_text/flutter_bidi_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Package Exports', () {
    test('Widget classes are exported correctly', () {
      // Verify we can instantiate each widget class
      const bidiText = BidiText('Test');
      expect(bidiText, isA<BidiText>());

      const bidiTextField = BidiTextField();
      expect(bidiTextField, isA<BidiTextField>());

      final bidiTextFormField = BidiTextFormField();
      expect(bidiTextFormField, isA<BidiTextFormField>());
    });

    test('Helper functions are exported correctly', () {
      // Verify we can call the exported functions
      final direction1 = BidiHelper.estimateDirectionOfText('Hello world');
      expect(direction1, equals(TextDirection.ltr));

      final direction2 = BidiHelper.estimateDirectionOfText('مرحبا بالعالم');
      expect(direction2, equals(TextDirection.rtl));

      final isRtl = BidiHelper.detectRtlDirectionality('مرحبا');
      expect(isRtl, isTrue);
    });
  });

  group('Package Usage Example', () {
    testWidgets('Example usage works correctly', (WidgetTester tester) async {
      // Simple usage example that should work with proper exports
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Basic BidiText
                const BidiText('Hello مرحبا'),

                // Simple BidiTextField
                const BidiTextField(
                  decoration: InputDecoration(
                    hintText: 'Enter text',
                  ),
                ),

                // Form with BidiTextFormField
                Form(
                  child: BidiTextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Input',
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify widgets rendered without errors
      expect(find.text('Hello مرحبا'), findsOneWidget);
      expect(find.byType(BidiTextField),
          findsExactly(2)); // The other one is composed in BidiTextFormField
      expect(find.byType(BidiTextFormField), findsOneWidget);
    });
  });
}
