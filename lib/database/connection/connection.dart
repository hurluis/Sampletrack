import 'package:drift/drift.dart';

import 'io.dart' if (dart.library.js_interop) 'web.dart' as driver;

/// Elige el driver según la plataforma: io.dart (móvil/escritorio) o web.dart.
QueryExecutor openConnection() => driver.openConnection();
