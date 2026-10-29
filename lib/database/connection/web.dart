import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Web: SQLite en WebAssembly.
/// Requiere web/sqlite3.wasm y web/drift_worker.js junto a index.html.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'sample_track',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
