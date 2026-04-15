import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AttachmentStore {
  Future<Directory> _attachmentsRoot() async {
    final dir = await getApplicationSupportDirectory();
    final root = Directory(p.join(dir.path, 'Nexo', 'attachments'));
    await root.create(recursive: true);
    return root;
  }

  Future<Directory> ensureTodoDir(String todoId) async {
    final root = await _attachmentsRoot();
    final todoDir = Directory(p.join(root.path, todoId));
    await todoDir.create(recursive: true);
    return todoDir;
  }

  Future<File> importFile({
    required String todoId,
    required File source,
  }) async {
    final dir = await ensureTodoDir(todoId);
    final base = p.basename(source.path);
    final targetPath = await _uniquePath(p.join(dir.path, base));
    return source.copy(targetPath);
  }

  Future<String> _uniquePath(String desiredPath) async {
    if (!await File(desiredPath).exists()) return desiredPath;
    final dir = p.dirname(desiredPath);
    final name = p.basenameWithoutExtension(desiredPath);
    final ext = p.extension(desiredPath);
    for (var i = 2; i < 9999; i++) {
      final candidate = p.join(dir, '$name ($i)$ext');
      if (!await File(candidate).exists()) return candidate;
    }
    throw StateError('Unable to find a unique filename for $desiredPath');
  }
}

