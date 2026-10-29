import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/sample_event.dart';

class SampleEventLocalDatasource {
  SampleEventLocalDatasource(this.db);

  final AppDatabase db;

  SampleEvent _toDomain(SampleEventRow row) {
    return SampleEvent(
      id: row.id,
      sampleId: row.sampleId,
      type: row.type,
      createdAt: row.createdAt,
    );
  }

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

  Future<void> saveEvents(List<SampleEvent> events) async {
    for (final event in events) {
      await saveEvent(event);
    }
  }

  Future<List<SampleEvent>> getAllEvents() async {
    final rows = await db.select(db.sampleEvents).get();
    return rows.map(_toDomain).toList();
  }

  Future<List<SampleEvent>> getEventsForSample(String sampleId) async {
    final rows = await (db.select(db.sampleEvents)
          ..where((t) => t.sampleId.equals(sampleId)))
        .get();
    return rows.map(_toDomain).toList();
  }
}
