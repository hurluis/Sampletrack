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

  /// Inserta el evento o lo actualiza si ya existe ese id.
  Future<void> saveEvent(SampleEvent event) {
    return db.into(db.sampleEvents).insertOnConflictUpdate(
          SampleEventsCompanion.insert(
            id: event.id,
            sampleId: event.sampleId,
            type: event.type,
            createdAt: event.createdAt,
          ),
        );
  }

  Future<void> saveEvents(List<SampleEvent> events) async {
    // ponytail: un upsert por evento; usar db.batch si el volumen crece
    for (final event in events) {
      await saveEvent(event);
    }
  }

  /// Todos los eventos, del más antiguo al más reciente.
  Future<List<SampleEvent>> getAllEvents() async {
    final rows = await (db.select(db.sampleEvents)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  /// Eventos de una muestra, del más antiguo al más reciente.
  Future<List<SampleEvent>> getEventsForSample(String sampleId) async {
    final rows = await (db.select(db.sampleEvents)
          ..where((t) => t.sampleId.equals(sampleId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_toDomain).toList();
  }
}
