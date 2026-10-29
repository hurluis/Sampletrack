import 'package:drift/drift.dart';

import 'connection/connection.dart';
import 'sample_events_table.dart';

part 'app_database.g.dart';

/// Base de datos local (Drift). El código generado va en app_database.g.dart.
/// openConnection() elige SQLite nativo (Windows/Android) o WebAssembly (web).
@DriftDatabase(tables: [SampleEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
