import 'package:drift/drift.dart';

/// Tabla local de eventos de muestras (caché de Firestore).
@DataClassName('SampleEventRow')
class SampleEvents extends Table {
  TextColumn get id => text()();
  TextColumn get sampleId => text()();
  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime()();

  // La PK es id (una fila por evento), nunca sampleId: así se guarda el historial.
  @override
  Set<Column> get primaryKey => {id};
}
