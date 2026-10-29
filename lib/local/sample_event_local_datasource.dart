import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/sample_event.dart';

/// Única capa que conoce Drift: guarda y lee los eventos en la base local.
class SampleEventLocalDatasource {
  SampleEventLocalDatasource(this.db);

  final AppDatabase db;

  // Fila de Drift -> modelo de dominio.
  SampleEvent _toDomain(SampleEventRow row) {
    return SampleEvent(
      id: row.id,
      sampleId: row.sampleId,
      type: row.type,
      createdAt: row.createdAt,
    );
  }

  /// Upsert: inserta el evento o lo actualiza si ya existe ese id.
  Future<void> saveEvent(SampleEvent event) async {
    await db.into(db.sampleEvents).insertOnConflictUpdate(
          SampleEventsCompanion.insert(
            id: event.id,
            sampleId: event.sampleId,
            type: event.type,
            createdAt: event.createdAt,
          ),
        );
  }

  /// Guarda en la caché local los eventos traídos de Firestore.
  Future<void> saveEvents(List<SampleEvent> events) async {
    for (final event in events) {
      await saveEvent(event);
    }
  }

  Future<List<SampleEvent>> getAllEvents() async {
    final rows = await db.select(db.sampleEvents).get();
    return rows.map(_toDomain).toList();
  }

  /// Solo los eventos de una muestra (consulta por sampleId, como movieId).
  Future<List<SampleEvent>> getEventsForSample(String sampleId) async {
    final rows = await (db.select(db.sampleEvents)
          ..where((t) => t.sampleId.equals(sampleId)))
        .get();
    return rows.map(_toDomain).toList();
  }
}
