import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample_track_shell/data/sample_seed.dart';
import 'package:sample_track_shell/widgets/sample_card.dart';

void main() {
  testWidgets('SampleCard muestra estado actual y progreso (variante G)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SampleCard(
            sample: sampleSeed[0],
            status: 'IN_ANALYSIS',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('M-1001'), findsOneWidget);
    expect(find.text('En análisis'), findsOneWidget);
    expect(find.text('Progreso: 60 %'), findsOneWidget);
  });
}
