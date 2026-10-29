import 'package:drift/drift.dart';

import 'io.dart' if (dart.library.js_interop) 'web.dart' as driver;

QueryExecutor openConnection() => driver.openConnection();
