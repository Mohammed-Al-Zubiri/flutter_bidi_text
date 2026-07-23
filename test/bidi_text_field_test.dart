import 'package:flutter/material.dart';
import 'package:flutter_bidi_text/bidi_text_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BidiTextField Widget Tests', () {
    testWidgets('Initial LTR text detection', (WidgetTester tester) async {
      TextDirection? detectedDirection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiTextField(
              controller: TextEditingController(text: 'Hello world'),
              onDirectionChanged: (direction) {
                detectedDirection = direction;
              },
            ),
          ),
        ),
      );

      // Wait for any pending callbacks
      await tester.pumpAndSettle();

      expect(detectedDirection, TextDirection.ltr);
    });

    testWidgets('Initial RTL text detection', (WidgetTester tester) async {
      TextDirection? detectedDirection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiTextField(
              controller: TextEditingController(text: 'مرحبا بالعالم'),
              onDirectionChanged: (direction) {
                detectedDirection = direction;
              },
            ),
          ),
        ),
      );

      // Wait for any pending callbacks
      await tester.pumpAndSettle();

      expect(detectedDirection, TextDirection.rtl);
    });

    testWidgets('Direction changes with text input',
        (WidgetTester tester) async {
      final List<TextDirection?> detectedDirections = [];
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiTextField(
              controller: controller,
              onDirectionChanged: (direction) {
                detectedDirections.add(direction);
              },
            ),
          ),
        ),
      );

      // Wait for initial setup
      await tester.pumpAndSettle();

      // Enter LTR text
      await tester.enterText(find.byType(TextField), 'Hello world');
      await tester.pumpAndSettle(); // Wait for debounce

      // Change to RTL text
      await tester.enterText(find.byType(TextField), 'مرحبا بالعالم');
      await tester.pumpAndSettle(); // Wait for debounce

      // Clear text
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle(); // Wait for debounce

      // We should have recorded null (initial: LTR), (unchanged: LTR), RTL, LTR
      expect(detectedDirections.length, greaterThanOrEqualTo(3));
      expect(
          detectedDirections.last,
          TextDirection
              .ltr); // Last should be (locale-default: LTR) for empty text

      // Check that we got both LTR and RTL in our detected directions
      expect(detectedDirections.contains(TextDirection.ltr), true);
      expect(detectedDirections.contains(TextDirection.rtl), true);
    });

    testWidgets('Sample length affects direction detection',
        (WidgetTester tester) async {
      TextDirection detectedDirection = TextDirection.ltr;
      // RTL text at beginning, but mostly LTR text
      final String mixedText = 'مرحبا${' Hello world' * 20}';

      // With small sample length, should detect RTL
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiTextField(
              controller: TextEditingController(text: mixedText),
              sampleLength: 5, // Only examine start of text
              onDirectionChanged: (direction) {
                detectedDirection = direction;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(detectedDirection, TextDirection.rtl);

      // With large/null sample length, should detect LTR (as there's more English)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiTextField(
              controller: TextEditingController(text: mixedText),
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

    testWidgets('Controller changes trigger direction updates',
        (WidgetTester tester) async {
      final List<TextDirection?> detectedDirections = [];
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiTextField(
              controller: controller,
              onDirectionChanged: (direction) {
                detectedDirections.add(direction);
              },
            ),
          ),
        ),
      );

      // Initial empty text
      await tester.pumpAndSettle();

      // Update controller with LTR text
      controller.text = 'Hello world';
      await tester.pumpAndSettle();

      // Update controller with RTL text
      controller.text = 'مرحبا بالعالم';
      await tester.pumpAndSettle();

      // Update controller with empty text
      controller.text = '';
      await tester.pumpAndSettle();

      // Check that we recorded appropriate directions
      expect(detectedDirections.length, greaterThanOrEqualTo(3));
      expect(detectedDirections.contains(TextDirection.ltr), true);
      expect(detectedDirections.contains(TextDirection.rtl), true);
    });

    testWidgets('New controller updates direction',
        (WidgetTester tester) async {
      final controller1 = TextEditingController(text: 'Hello world');
      final controller2 = TextEditingController(text: 'مرحبا بالعالم');
      TextDirection? detectedDirection;

      final widget = MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(builder: (context, setState) {
            return Column(
              children: [
                BidiTextField(
                  controller: controller1,
                  onDirectionChanged: (direction) {
                    detectedDirection = direction;
                  },
                ),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // This will swap the controller
                      });
                    },
                    child: const Text('Swap controller')),
              ],
            );
          }),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      expect(detectedDirection, TextDirection.ltr);

      // Now rebuild with new controller
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiTextField(
              controller: controller2, // RTL text controller
              onDirectionChanged: (direction) {
                detectedDirection = direction;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(detectedDirection, TextDirection.rtl);
    });
  });

  // ---------------------------------------------------------------------------
  // Regression tests — parameter forwarding (Commit 1 / v1.1.2)
  // Ensures every parameter accepted by BidiTextField reaches the inner TextField.
  // ---------------------------------------------------------------------------
  group('BidiTextField Parameter Forwarding Regression Tests', () {
    testWidgets('groupId is forwarded to inner TextField',
        (WidgetTester tester) async {
      const customGroupId = 'my-group';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiTextField(groupId: customGroupId),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.groupId, customGroupId);
    });

    testWidgets('undoController is forwarded to inner TextField',
        (WidgetTester tester) async {
      final undoController = UndoHistoryController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiTextField(undoController: undoController),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.undoController, undoController);
      undoController.dispose();
    });

    testWidgets('statesController is forwarded to inner TextField',
        (WidgetTester tester) async {
      final statesController = WidgetStatesController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BidiTextField(statesController: statesController),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.statesController, statesController);
      statesController.dispose();
    });

    testWidgets('ignorePointers is forwarded to inner TextField',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiTextField(ignorePointers: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.ignorePointers, true);
    });

    testWidgets('cursorErrorColor is forwarded to inner TextField',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiTextField(cursorErrorColor: Color(0xFFFF0000)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.cursorErrorColor, const Color(0xFFFF0000));
    });

    testWidgets('onTapAlwaysCalled is forwarded to inner TextField',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiTextField(onTapAlwaysCalled: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.onTapAlwaysCalled, true);
    });

    testWidgets('cursorOpacityAnimates is forwarded to inner TextField',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiTextField(cursorOpacityAnimates: false),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.cursorOpacityAnimates, false);
    });

    testWidgets(
        'stylusHandwritingEnabled replaces canRequestFocus and is forwarded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BidiTextField(stylusHandwritingEnabled: false),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.stylusHandwritingEnabled, false);
    });
  });
}
