import 'package:flutter/material.dart';
import 'package:flutter_bidi_text/bidi_text_form_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BidiTextFormField Widget Tests', () {
    testWidgets('Form validation works', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      String? formValue;
      bool formSubmitted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  BidiTextFormField(
                    initialValue: 'Hello world',
                    validator: (value) {
                      return value!.contains('@') ? 'No @ allowed' : null;
                    },
                    onSaved: (value) {
                      formValue = value;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        formSubmitted = true;
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Initial state - form should be valid
      expect(find.text('No @ allowed'), findsNothing);

      // Enter invalid input
      await tester.enterText(find.byType(TextField), 'invalid@email.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Should show error and not submit
      expect(find.text('No @ allowed'), findsOneWidget);
      expect(formSubmitted, false);

      // Enter valid input
      await tester.enterText(find.byType(TextField), 'valid text');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Should submit successfully
      expect(find.text('No @ allowed'), findsNothing);
      expect(formSubmitted, true);
      expect(formValue, 'valid text');
    });

    testWidgets('Direction detection works', (WidgetTester tester) async {
      TextDirection? detectedDirection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiTextFormField(
              initialValue: 'مرحبا بالعالم',
              onDirectionChanged: (direction) {
                detectedDirection = direction;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(detectedDirection, TextDirection.rtl);

      // Change to LTR
      await tester.enterText(find.byType(TextField), 'Hello world');
      await tester.pumpAndSettle();
      expect(detectedDirection, TextDirection.ltr);
    });

    testWidgets('Controller provided externally works',
        (WidgetTester tester) async {
      final controller = TextEditingController(text: 'Initial text');
      String? formValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: BidiTextFormField(
                controller: controller,
                onSaved: (value) {
                  formValue = value;
                },
              ),
            ),
          ),
        ),
      );

      // Check if field has initial text from controller
      expect(find.text('Initial text'), findsOneWidget);

      // Change controller text
      controller.text = 'Updated text';
      await tester.pump();
      expect(find.text('Updated text'), findsOneWidget);

      // Form should save controller value
      final formState = Form.of(tester.element(find.byType(BidiTextFormField)));
      formState.save();
      expect(formValue, 'Updated text');
    });

    testWidgets('Reset form works', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: Column(
                children: [
                  BidiTextFormField(
                    initialValue: 'Initial text',
                  ),
                  ElevatedButton(
                    onPressed: () {
                      formKey.currentState!.reset();
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Change text
      await tester.enterText(find.byType(TextField), 'Changed text');
      await tester.pumpAndSettle();
      expect(find.text('Changed text'), findsOneWidget);

      // Reset form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Should revert to initial value
      expect(find.text('Initial text'), findsOneWidget);
    });

    testWidgets('Sample length affects direction detection',
        (WidgetTester tester) async {
      TextDirection detectedDirection = TextDirection.ltr;
      // RTL text at beginning, but mostly LTR text
      final String mixedText = 'مرحبا${' Hello world' * 10}';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiTextFormField(
              initialValue: mixedText,
              sampleLength: 5, // Only examine start of text (RTL region)
              onDirectionChanged: (direction) {
                detectedDirection = direction;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(detectedDirection, TextDirection.rtl);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiTextFormField(
              initialValue: mixedText,
              sampleLength: null, // Examine all text
              onDirectionChanged: (direction) {
                detectedDirection = direction;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('FormField state is updated properly',
        (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      late String formFieldValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: BidiTextFormField(
                initialValue: 'Initial value',
                onSaved: (value) {
                  formFieldValue = value!;
                },
              ),
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('Initial value'), findsOneWidget);

      // Change text
      await tester.enterText(find.byType(TextField), 'Updated value');
      await tester.pumpAndSettle();

      // Save form
      formKey.currentState!.save();
      expect(formFieldValue, 'Updated value');
    });

    testWidgets('onChanged callback is triggered', (WidgetTester tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiTextFormField(
              initialValue: 'Initial text',
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      // Change text
      await tester.enterText(find.byType(TextField), 'Changed text');
      await tester.pumpAndSettle();

      expect(changedValue, 'Changed text');
    });

    // Add more tests as needed for specific behaviors
  });
}
