import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowra/widgets/celebration_dialog.dart';

void main() {
  testWidgets('showCelebrationDialog displays title, subtitle and dismisses',
      (tester) async {
    bool confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCelebrationDialog(
                  context: context,
                  title: 'Outstanding Focus!',
                  subtitle: 'You completed your study session without quitting.',
                  durationMinutes: 45,
                  blockedAttempts: 4,
                  onConfirm: () => confirmed = true,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Outstanding Focus!'), findsOneWidget);
    expect(
      find.text('You completed your study session without quitting.'),
      findsOneWidget,
    );
    expect(find.text('45m'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Distractions Blocked'), findsOneWidget);

    await tester.tap(find.text('Awesome!'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });
}
