import 'package:drift/drift.dart';

/// Punto de inicio para la persistencia local del examen.
///
/// La shell no incluye Drift como dependencia. Este archivo compila sin Drift
/// para que la aplicacion inicial pueda ejecutarse. Durante el examen se debe
/// transformar esta clase en la base de datos requerida por el enunciado.

@DriftDatabase(tables: [SampleEvents])
class AppDatabase {
  // TODO: agregar la configuracion de persistencia local requerida.
  AppDatabase(): super(openConnection());

  @override
  int get schemaVersion => 1;

  // TODO: crear e incluir la estructura solicitada por el enunciado.
  // TODO: implementar las operaciones locales necesarias.
}
