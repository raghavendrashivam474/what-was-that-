import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'discovery_database.g.dart';

@DataClassName('DiscoveryEntry')
class Discoveries extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get explanation => text()();
  TextColumn get confidence => text()();
  BoolColumn get identifiable => boolean().withDefault(const Constant(true))();
  TextColumn get imagePath => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Discoveries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(e ?? driftDatabase(name: 'what_was_that_db'));

  @override
  int get schemaVersion => 1;
}
