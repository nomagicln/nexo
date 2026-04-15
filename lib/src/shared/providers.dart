import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/attachments/attachment_store.dart';
import '../data/db/app_database.dart';
import '../data/todos/todo_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository(ref.watch(databaseProvider));
});

final attachmentStoreProvider = Provider<AttachmentStore>((ref) {
  return AttachmentStore();
});

