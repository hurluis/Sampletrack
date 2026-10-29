import 'package:drift/drift.dart';

@DataClassName('SampleEventRow')
class SampleEventsTable extends Table {
    TextColumn get sampleId => text()();
    TextColumn get event => note()();
    DateTimeColumn get createdAt => dateTime()();

    BoolColumn get pendingSync => boolean()
        .withDefault(const Constant(true))();

    @override
    Set<Column> get primaryKey => { sampleId };
}
