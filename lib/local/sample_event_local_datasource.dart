import 'package:sample_track_shell/database/app_database.dart';
import 'package:sample_track_shell/models/sample_event.dart';

class SampleEventLocalDatasource {
    final AppDatabase db;

    SampleEventLocalDatasource(this.db);

    SampleEvent _toDomain(SampleEventRow row) {
       // TODO 
    }
}
