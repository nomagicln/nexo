import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Todos extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get title => text()();
  TextColumn get details => text().withDefault(const Constant(''))();

  IntColumn get priority => integer().withDefault(const Constant(1))(); // 0..3
  IntColumn get criticalLevel =>
      integer().withDefault(const Constant(0))(); // 0..3
  IntColumn get importantLevel =>
      integer().withDefault(const Constant(0))(); // 0..3

  DateTimeColumn get dueAt => dateTime().nullable()();
  DateTimeColumn get atAt => dateTime().nullable()();

  TextColumn get categoryId => text().nullable()();

  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  BoolColumn get pinned => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Labels extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get name => text()();
  IntColumn get colorArgb => integer().nullable()(); // optional UI hint

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get name => text()();
  IntColumn get colorArgb => integer().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class TodoLabels extends Table {
  TextColumn get todoId => text()();
  TextColumn get labelId => text()();

  @override
  Set<Column> get primaryKey => {todoId, labelId};
}

class Attachments extends Table {
  TextColumn get id => text()(); // uuid
  TextColumn get todoId => text()();
  TextColumn get filename => text()();
  TextColumn get mime => text().nullable()();
  IntColumn get size => integer().nullable()();

  TextColumn get storedPath => text()(); // path in app data dir
  TextColumn get originalPath => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Todos, Labels, Categories, TodoLabels, Attachments])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement('CREATE INDEX idx_todos_dueAt ON todos(due_at)');
          await customStatement('CREATE INDEX idx_todos_atAt ON todos(at_at)');
          await customStatement(
              'CREATE INDEX idx_todos_completed ON todos(is_completed)');
          await customStatement('CREATE INDEX idx_todos_pinned ON todos(pinned)');
          await customStatement(
              'CREATE INDEX idx_todos_category ON todos(category_id)');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final dbDir = Directory(p.join(dir.path, 'Nexo'));
    await dbDir.create(recursive: true);
    final file = File(p.join(dbDir.path, 'nexo.sqlite'));
    return driftDatabase(name: file.path);
  });
}

