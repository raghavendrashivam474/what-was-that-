// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_database.dart';

// ignore_for_file: type=lint
class $DiscoveriesTable extends Discoveries
    with TableInfo<$DiscoveriesTable, DiscoveryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiscoveriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _explanationMeta =
      const VerificationMeta('explanation');
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
      'explanation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
      'confidence', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _identifiableMeta =
      const VerificationMeta('identifiable');
  @override
  late final GeneratedColumn<bool> identifiable = GeneratedColumn<bool>(
      'identifiable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("identifiable" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        explanation,
        confidence,
        identifiable,
        imagePath,
        createdAt,
        latitude,
        longitude
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'discoveries';
  @override
  VerificationContext validateIntegrity(Insertable<DiscoveryEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
          _explanationMeta,
          explanation.isAcceptableOrUnknown(
              data['explanation']!, _explanationMeta));
    } else if (isInserting) {
      context.missing(_explanationMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('identifiable')) {
      context.handle(
          _identifiableMeta,
          identifiable.isAcceptableOrUnknown(
              data['identifiable']!, _identifiableMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiscoveryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiscoveryEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      explanation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}explanation'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}confidence'])!,
      identifiable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}identifiable'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
    );
  }

  @override
  $DiscoveriesTable createAlias(String alias) {
    return $DiscoveriesTable(attachedDatabase, alias);
  }
}

class DiscoveryEntry extends DataClass implements Insertable<DiscoveryEntry> {
  final String id;
  final String title;
  final String explanation;
  final String confidence;
  final bool identifiable;
  final String imagePath;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  const DiscoveryEntry(
      {required this.id,
      required this.title,
      required this.explanation,
      required this.confidence,
      required this.identifiable,
      required this.imagePath,
      required this.createdAt,
      this.latitude,
      this.longitude});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['explanation'] = Variable<String>(explanation);
    map['confidence'] = Variable<String>(confidence);
    map['identifiable'] = Variable<bool>(identifiable);
    map['image_path'] = Variable<String>(imagePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    return map;
  }

  DiscoveriesCompanion toCompanion(bool nullToAbsent) {
    return DiscoveriesCompanion(
      id: Value(id),
      title: Value(title),
      explanation: Value(explanation),
      confidence: Value(confidence),
      identifiable: Value(identifiable),
      imagePath: Value(imagePath),
      createdAt: Value(createdAt),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
    );
  }

  factory DiscoveryEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiscoveryEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      explanation: serializer.fromJson<String>(json['explanation']),
      confidence: serializer.fromJson<String>(json['confidence']),
      identifiable: serializer.fromJson<bool>(json['identifiable']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'explanation': serializer.toJson<String>(explanation),
      'confidence': serializer.toJson<String>(confidence),
      'identifiable': serializer.toJson<bool>(identifiable),
      'imagePath': serializer.toJson<String>(imagePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
    };
  }

  DiscoveryEntry copyWith(
          {String? id,
          String? title,
          String? explanation,
          String? confidence,
          bool? identifiable,
          String? imagePath,
          DateTime? createdAt,
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent()}) =>
      DiscoveryEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        explanation: explanation ?? this.explanation,
        confidence: confidence ?? this.confidence,
        identifiable: identifiable ?? this.identifiable,
        imagePath: imagePath ?? this.imagePath,
        createdAt: createdAt ?? this.createdAt,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
      );
  DiscoveryEntry copyWithCompanion(DiscoveriesCompanion data) {
    return DiscoveryEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      explanation:
          data.explanation.present ? data.explanation.value : this.explanation,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      identifiable: data.identifiable.present
          ? data.identifiable.value
          : this.identifiable,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveryEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('explanation: $explanation, ')
          ..write('confidence: $confidence, ')
          ..write('identifiable: $identifiable, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, explanation, confidence,
      identifiable, imagePath, createdAt, latitude, longitude);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiscoveryEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.explanation == this.explanation &&
          other.confidence == this.confidence &&
          other.identifiable == this.identifiable &&
          other.imagePath == this.imagePath &&
          other.createdAt == this.createdAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class DiscoveriesCompanion extends UpdateCompanion<DiscoveryEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> explanation;
  final Value<String> confidence;
  final Value<bool> identifiable;
  final Value<String> imagePath;
  final Value<DateTime> createdAt;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> rowid;
  const DiscoveriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.explanation = const Value.absent(),
    this.confidence = const Value.absent(),
    this.identifiable = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiscoveriesCompanion.insert({
    required String id,
    required String title,
    required String explanation,
    required String confidence,
    this.identifiable = const Value.absent(),
    required String imagePath,
    required DateTime createdAt,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        explanation = Value(explanation),
        confidence = Value(confidence),
        imagePath = Value(imagePath),
        createdAt = Value(createdAt);
  static Insertable<DiscoveryEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? explanation,
    Expression<String>? confidence,
    Expression<bool>? identifiable,
    Expression<String>? imagePath,
    Expression<DateTime>? createdAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (explanation != null) 'explanation': explanation,
      if (confidence != null) 'confidence': confidence,
      if (identifiable != null) 'identifiable': identifiable,
      if (imagePath != null) 'image_path': imagePath,
      if (createdAt != null) 'created_at': createdAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiscoveriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? explanation,
      Value<String>? confidence,
      Value<bool>? identifiable,
      Value<String>? imagePath,
      Value<DateTime>? createdAt,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<int>? rowid}) {
    return DiscoveriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      explanation: explanation ?? this.explanation,
      confidence: confidence ?? this.confidence,
      identifiable: identifiable ?? this.identifiable,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (identifiable.present) {
      map['identifiable'] = Variable<bool>(identifiable.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('explanation: $explanation, ')
          ..write('confidence: $confidence, ')
          ..write('identifiable: $identifiable, ')
          ..write('imagePath: $imagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DiscoveriesTable discoveries = $DiscoveriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [discoveries];
}

typedef $$DiscoveriesTableCreateCompanionBuilder = DiscoveriesCompanion
    Function({
  required String id,
  required String title,
  required String explanation,
  required String confidence,
  Value<bool> identifiable,
  required String imagePath,
  required DateTime createdAt,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int> rowid,
});
typedef $$DiscoveriesTableUpdateCompanionBuilder = DiscoveriesCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> explanation,
  Value<String> confidence,
  Value<bool> identifiable,
  Value<String> imagePath,
  Value<DateTime> createdAt,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int> rowid,
});

class $$DiscoveriesTableFilterComposer
    extends Composer<_$AppDatabase, $DiscoveriesTable> {
  $$DiscoveriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get identifiable => $composableBuilder(
      column: $table.identifiable, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));
}

class $$DiscoveriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiscoveriesTable> {
  $$DiscoveriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get identifiable => $composableBuilder(
      column: $table.identifiable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));
}

class $$DiscoveriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiscoveriesTable> {
  $$DiscoveriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => column);

  GeneratedColumn<String> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<bool> get identifiable => $composableBuilder(
      column: $table.identifiable, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);
}

class $$DiscoveriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DiscoveriesTable,
    DiscoveryEntry,
    $$DiscoveriesTableFilterComposer,
    $$DiscoveriesTableOrderingComposer,
    $$DiscoveriesTableAnnotationComposer,
    $$DiscoveriesTableCreateCompanionBuilder,
    $$DiscoveriesTableUpdateCompanionBuilder,
    (
      DiscoveryEntry,
      BaseReferences<_$AppDatabase, $DiscoveriesTable, DiscoveryEntry>
    ),
    DiscoveryEntry,
    PrefetchHooks Function()> {
  $$DiscoveriesTableTableManager(_$AppDatabase db, $DiscoveriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiscoveriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiscoveriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiscoveriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> explanation = const Value.absent(),
            Value<String> confidence = const Value.absent(),
            Value<bool> identifiable = const Value.absent(),
            Value<String> imagePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiscoveriesCompanion(
            id: id,
            title: title,
            explanation: explanation,
            confidence: confidence,
            identifiable: identifiable,
            imagePath: imagePath,
            createdAt: createdAt,
            latitude: latitude,
            longitude: longitude,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String explanation,
            required String confidence,
            Value<bool> identifiable = const Value.absent(),
            required String imagePath,
            required DateTime createdAt,
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiscoveriesCompanion.insert(
            id: id,
            title: title,
            explanation: explanation,
            confidence: confidence,
            identifiable: identifiable,
            imagePath: imagePath,
            createdAt: createdAt,
            latitude: latitude,
            longitude: longitude,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DiscoveriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DiscoveriesTable,
    DiscoveryEntry,
    $$DiscoveriesTableFilterComposer,
    $$DiscoveriesTableOrderingComposer,
    $$DiscoveriesTableAnnotationComposer,
    $$DiscoveriesTableCreateCompanionBuilder,
    $$DiscoveriesTableUpdateCompanionBuilder,
    (
      DiscoveryEntry,
      BaseReferences<_$AppDatabase, $DiscoveriesTable, DiscoveryEntry>
    ),
    DiscoveryEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DiscoveriesTableTableManager get discoveries =>
      $$DiscoveriesTableTableManager(_db, _db.discoveries);
}
