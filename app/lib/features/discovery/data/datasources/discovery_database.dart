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
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Discoveries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e])
      : super(e ?? driftDatabase(name: 'what_was_that_db'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // Schema v1 -> v2: Add nullable latitude and longitude columns
            await m.addColumn(discoveries, discoveries.latitude);
            await m.addColumn(discoveries, discoveries.longitude);
          }
        },
      );
}
