import 'package:flutter_test/flutter_test.dart';
import 'package:sample_track_shell/data/sample_seed.dart';
import 'package:sample_track_shell/models/sample.dart';
import 'package:sample_track_shell/models/sample_event.dart';
import 'package:sample_track_shell/models/sample_status.dart';

SampleEvent makeEvent(String sampleId, String type, int minute) {
  return SampleEvent(
    id: '$sampleId-$type',
    sampleId: sampleId,
    type: type,
    createdAt: DateTime(2026, 10, 28, 10, minute),
  );
}

List<String> ids(List<Sample> samples) {
  final List<String> result = [];
  for (int i = 0; i < samples.length; i++) {
    result.add(samples[i].id);
  }
  return result;
}

void main() {
  test('sin eventos: estado "Sin eventos" y 0 %', () {
    expect(currentStatus([]), isNull);
    expect(statusLabel(null), 'Sin eventos');
    expect(progressPercent(null), 0);
  });

  test('el estado actual es el evento más reciente aunque llegue desordenado', () {
    final events = [
      makeEvent('M-1001', 'PREPARED', 2),
      makeEvent('M-1001', 'RECEIVED', 1),
    ];
    expect(currentStatus(events), 'PREPARED');
    expect(sortByDate(events)[0].type, 'RECEIVED');
  });

  test('los eventos se filtran por sampleId', () {
    final events = [
      makeEvent('M-1001', 'RECEIVED', 1),
      makeEvent('M-1002', 'RECEIVED', 2),
    ];
    expect(eventsOfSample(events, 'M-1002').length, 1);
  });

  test('no se permite saltar estados', () {
    expect(validateTransition(null, 'RECEIVED'), isNull);
    expect(validateTransition(null, 'PREPARED'), isNotNull);
    expect(validateTransition('RECEIVED', 'IN_ANALYSIS'), isNotNull);
    expect(validateTransition('PREPARED', 'IN_ANALYSIS'), isNull);
    expect(validateTransition('VALIDATED', 'ARCHIVED'), isNull);
  });

  test('ARCHIVED ya no admite más eventos', () {
    expect(nextEventType('ARCHIVED'), isNull);
    expect(validateTransition('ARCHIVED', 'ARCHIVED'), isNotNull);
  });

  test('variante G: porcentaje de progreso por estado', () {
    expect(progressPercent('RECEIVED'), 20);
    expect(progressPercent('PREPARED'), 40);
    expect(progressPercent('IN_ANALYSIS'), 60);
    expect(progressPercent('VALIDATED'), 80);
    expect(progressPercent('ARCHIVED'), 100);
  });

  test('variante G: resumen por estado y pendientes por prioridad', () {
    final events = [
      makeEvent('M-1001', 'RECEIVED', 1),
      makeEvent('M-1001', 'PREPARED', 2),
      makeEvent('M-1001', 'IN_ANALYSIS', 3),
      makeEvent('M-1002', 'RECEIVED', 1),
      makeEvent('M-1002', 'PREPARED', 2),
      makeEvent('M-1002', 'IN_ANALYSIS', 3),
      makeEvent('M-1003', 'RECEIVED', 1),
      makeEvent('M-1005', 'RECEIVED', 1),
      makeEvent('M-1005', 'PREPARED', 2),
      makeEvent('M-1005', 'IN_ANALYSIS', 3),
    ];
    final statuses = statusBySample(sampleSeed, events);

    final summary = summaryByStatus(statuses);
    expect(summary['Sin eventos'], 1); // M-1004
    expect(summary['Recibida'], 1); // M-1003
    expect(summary['En análisis'], 3);
    expect(summary['Archivada'], 0);

    // Urgente (M-1005), Alta (M-1001), Normal (M-1002)
    expect(ids(pendingValidation(sampleSeed, statuses)),
        ['M-1005', 'M-1001', 'M-1002']);
  });
}
