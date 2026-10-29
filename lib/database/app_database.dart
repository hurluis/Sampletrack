import 'package:drift/drift.dart';

import 'connection/connection.dart';
import 'sample_events_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [SampleEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;
}
