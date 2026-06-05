import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:narco/features/token_creation/presentation/widgets/status_badge.dart';

void main() {
  group('StatusBadge', () {
    Future<void> pumpBadge(WidgetTester tester, String status) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: StatusBadge(status: status)),
          ),
        ),
      );
    }

    testWidgets('affiche le statut en majuscules', (tester) async {
      await pumpBadge(tester, 'actif');
      expect(find.text('ACTIF'), findsOneWidget);
    });

    testWidgets('gère le statut transféré', (tester) async {
      await pumpBadge(tester, 'transféré');
      expect(find.text('TRANSFÉRÉ'), findsOneWidget);
    });
  });
}
