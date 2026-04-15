import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../../features/todos/domain/todo_filter.dart';

class TodoRepository {
  TodoRepository(this.db);
  final AppDatabase db;

  Stream<List<Todo>> watchTodos(TodoFilterState filter) {
    final q = db.select(db.todos);
    q.where((t) {
      Expression<bool> expr = const Constant(true);

      switch (filter.status) {
        case TodoStatusFilter.open:
          expr = expr & t.isCompleted.equals(false);
          break;
        case TodoStatusFilter.completed:
          expr = expr & t.isCompleted.equals(true);
          break;
        case TodoStatusFilter.all:
          break;
      }

      if (filter.priorities != null && filter.priorities!.isNotEmpty) {
        expr = expr &
            t.priority.isIn(filter.priorities!.toList(growable: false));
      }

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));

      switch (filter.due) {
        case TodoDueFilter.any:
          break;
        case TodoDueFilter.noDueDate:
          expr = expr & t.dueAt.isNull();
          break;
        case TodoDueFilter.dueToday:
          expr = expr &
              t.dueAt.isBiggerOrEqualValue(todayStart) &
              t.dueAt.isSmallerThanValue(tomorrowStart);
          break;
        case TodoDueFilter.overdue:
          expr = expr &
              t.dueAt.isNotNull() &
              t.dueAt.isSmallerThanValue(todayStart);
          break;
      }

      final query = filter.query.trim();
      if (query.isNotEmpty) {
        final like = '%${query.replaceAll('%', '\\%').replaceAll('_', '\\_')}%';
        expr = expr &
            (t.title.like(like, escapeChar: '\\') |
                t.details.like(like, escapeChar: '\\'));
      }

      return expr;
    });

    q.orderBy([
      (t) => OrderingTerm.desc(t.pinned),
      (t) => OrderingTerm.asc(t.isCompleted),
      (t) => OrderingTerm.asc(t.dueAt),
      (t) => OrderingTerm.desc(t.updatedAt),
    ]);

    return q.watch();
  }

  Stream<List<Todo>> watchAllTodos() => watchTodos(const TodoFilterState());

  Future<Todo?> getById(String id) {
    return (db.select(db.todos)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<String> create({
    required String title,
    String details = '',
    int priority = 1,
    int criticalLevel = 0,
    int importantLevel = 0,
    DateTime? dueAt,
    DateTime? atAt,
    String? categoryId,
    bool pinned = false,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    await db.into(db.todos).insert(
          TodosCompanion.insert(
            id: id,
            title: title,
            details: Value(details),
            priority: Value(priority),
            criticalLevel: Value(criticalLevel),
            importantLevel: Value(importantLevel),
            dueAt: Value(dueAt),
            atAt: Value(atAt),
            categoryId: Value(categoryId),
            pinned: Value(pinned),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return id;
  }

  Future<void> updateTodo(
    String id, {
    String? title,
    String? details,
    int? priority,
    int? criticalLevel,
    int? importantLevel,
    DateTime? dueAt,
    DateTime? atAt,
    String? categoryId,
    bool? pinned,
    bool? isCompleted,
    DateTime? completedAt,
  }) async {
    final now = DateTime.now();
    await (db.update(db.todos)..where((t) => t.id.equals(id))).write(
      TodosCompanion(
        title: title == null ? const Value.absent() : Value(title),
        details: details == null ? const Value.absent() : Value(details),
        priority: priority == null ? const Value.absent() : Value(priority),
        criticalLevel:
            criticalLevel == null ? const Value.absent() : Value(criticalLevel),
        importantLevel: importantLevel == null
            ? const Value.absent()
            : Value(importantLevel),
        dueAt: dueAt == null ? const Value.absent() : Value(dueAt),
        atAt: atAt == null ? const Value.absent() : Value(atAt),
        categoryId:
            categoryId == null ? const Value.absent() : Value(categoryId),
        pinned: pinned == null ? const Value.absent() : Value(pinned),
        isCompleted:
            isCompleted == null ? const Value.absent() : Value(isCompleted),
        completedAt:
            completedAt == null ? const Value.absent() : Value(completedAt),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> deleteTodo(String id) async {
    await (db.delete(db.todos)..where((t) => t.id.equals(id))).go();
    await (db.delete(db.todoLabels)..where((tl) => tl.todoId.equals(id))).go();
    await (db.delete(db.attachments)..where((a) => a.todoId.equals(id))).go();
  }

  Stream<List<Attachment>> watchAttachments(String todoId) {
    final q = db.select(db.attachments)..where((a) => a.todoId.equals(todoId));
    q.orderBy([(a) => OrderingTerm.desc(a.createdAt)]);
    return q.watch();
  }

  Future<void> addAttachment({
    required String todoId,
    required String filename,
    required String storedPath,
    String? originalPath,
    String? mime,
    int? size,
  }) async {
    final id = const Uuid().v4();
    await db.into(db.attachments).insert(
          AttachmentsCompanion.insert(
            id: id,
            todoId: todoId,
            filename: filename,
            storedPath: storedPath,
            originalPath: Value(originalPath),
            mime: Value(mime),
            size: Value(size),
          ),
        );
  }

  Future<void> deleteAttachment(String id) async {
    await (db.delete(db.attachments)..where((a) => a.id.equals(id))).go();
  }
}

