import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../../../l10n/app_localizations.dart';

import '../../../data/db/app_database.dart';
import '../../../shared/providers.dart';
import '../domain/todo_filter.dart';
import 'todo_editor_dialog.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

import '../../../app/window_args.dart';

class TodosShellScreen extends ConsumerWidget {
  const TodosShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final filter = ref.watch(_todoFilterProvider);
    final todosAsync = ref.watch(_todosProvider(filter));
    final selectedId = ref.watch(_selectedTodoIdProvider);
    final selectedTodoAsync = ref.watch(_selectedTodoProvider);
    final attachmentsAsync = ref.watch(_attachmentsProvider);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            minWidth: 76,
            labelType: NavigationRailLabelType.all,
            selectedIndex: 0,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.inbox_outlined),
                selectedIcon: Icon(Icons.inbox),
                label: Text(l10n.inbox),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.today_outlined),
                selectedIcon: Icon(Icons.today),
                label: Text(l10n.today),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.upcoming_outlined),
                selectedIcon: Icon(Icons.upcoming),
                label: Text(l10n.upcoming),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.sell_outlined),
                selectedIcon: Icon(Icons.sell),
                label: Text(l10n.labels),
              ),
            ],
          ),
          VerticalDivider(width: 1, color: cs.outlineVariant),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.appName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: l10n.openWidgetWindow,
                        onPressed: () async {
                          final existing = await WindowController.getAll();
                          for (final c in existing) {
                            final a = NexoWindowArgs.decode(c.arguments);
                            if (a.type == NexoWindowType.widget) {
                              await c.show();
                              return;
                            }
                          }

                          final c = await WindowController.create(
                            WindowConfiguration(
                              hiddenAtLaunch: true,
                              arguments: const NexoWindowArgs(
                                type: NexoWindowType.widget,
                              ).encode(),
                            ),
                          );
                          await c.show();
                        },
                        icon: const Icon(Icons.push_pin_outlined),
                      ),
                      const SizedBox(width: 6),
                      FilledButton.icon(
                        onPressed: () async {
                          final createdId = await showDialog<String>(
                            context: context,
                            builder: (_) => const TodoEditorDialog(),
                          );
                          if (createdId != null) {
                            ref.read(_selectedTodoIdProvider.notifier).state =
                                createdId;
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: Text(l10n.newTodo),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.todos,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 8),
                                  _FilterBar(filter: filter),
                                  const SizedBox(height: 14),
                                  Expanded(
                                    child: todosAsync.when(
                                      data: (todos) {
                                        if (todos.isEmpty) {
                                          return Center(
                                            child: Text(
                                              l10n.noTodosYet,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                      color:
                                                          cs.onSurfaceVariant),
                                            ),
                                          );
                                        }
                                        return ListView.separated(
                                          itemCount: todos.length,
                                          separatorBuilder: (_, _) =>
                                              const SizedBox(height: 10),
                                          itemBuilder: (context, i) {
                                            final t = todos[i];
                                            return _TodoListTile(
                                              title: t.title,
                                              subtitle: t.details.isEmpty
                                                  ? l10n.noDetails
                                                  : t.details,
                                              trailing: Text(
                                                t.dueAt == null
                                                    ? ''
                                                    : _formatDue(t.dueAt!),
                                                style: TextStyle(
                                                  color: cs.secondary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              selected: t.id == selectedId,
                                              onTap: () {
                                                ref
                                                    .read(_selectedTodoIdProvider
                                                        .notifier)
                                                    .state = t.id;
                                              },
                                              onToggleComplete: (v) async {
                                                final repo = ref.read(
                                                    todoRepositoryProvider);
                                                await repo.updateTodo(
                                                  t.id,
                                                  isCompleted: v,
                                                  completedAt:
                                                      v ? DateTime.now() : null,
                                                );
                                              },
                                              checkboxValue: t.isCompleted,
                                            )
                                                .animate()
                                                .fadeIn(duration: 220.ms)
                                                .slideY(
                                                  begin: 0.06,
                                                  end: 0,
                                                  duration: 220.ms,
                                                  curve: Curves.easeOutCubic,
                                                );
                                          },
                                        );
                                      },
                                      error: (e, _) => Center(
                                        child: Text(
                                          l10n.failedLoadTodos(e.toString()),
                                          style: TextStyle(
                                              color: cs.error,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      loading: () => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: selectedTodoAsync.when(
                                data: (todo) {
                                  if (todo == null) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.details,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          l10n.selectTodoHint,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ],
                                    );
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            l10n.details,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w700),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () async {
                                              final repo = ref.read(
                                                  todoRepositoryProvider);
                                              await repo.updateTodo(
                                                todo.id,
                                                pinned: !todo.pinned,
                                              );
                                            },
                                            tooltip: l10n.pin,
                                            icon: Icon(todo.pinned
                                                ? Icons.push_pin
                                                : Icons.push_pin_outlined),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              final updatedId =
                                                  await showDialog<String>(
                                                context: context,
                                                builder: (_) => TodoEditorDialog(
                                                  editing: todo,
                                                ),
                                              );
                                              if (updatedId != null) {
                                                ref
                                                    .read(_selectedTodoIdProvider
                                                        .notifier)
                                                    .state = updatedId;
                                              }
                                            },
                                            tooltip: l10n.edit,
                                            icon: const Icon(Icons.edit),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        todo.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          Chip(
                                            label: Text(
                                                '${l10n.priorityShort}: ${_priorityLabel(todo.priority)}'),
                                          ),
                                          Chip(
                                            label: Text(
                                                '${l10n.criticalShort}: ${todo.criticalLevel}'),
                                          ),
                                          Chip(
                                            label: Text(
                                                '${l10n.importantShort}: ${todo.importantLevel}'),
                                          ),
                                          if (todo.dueAt != null)
                                            Chip(
                                              label: Text(
                                                  '${l10n.dueShort}: ${_formatDue(todo.dueAt!)}'),
                                            ),
                                          if (todo.atAt != null)
                                            Chip(
                                              label: Text(
                                                  '${l10n.atShort}: ${_formatDue(todo.atAt!)}'),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: cs.surfaceContainerHighest
                                                .withValues(alpha: 0.35),
                                          ),
                                          padding: const EdgeInsets.all(14),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  todo.details.isEmpty
                                                      ? l10n.noDetails
                                                      : todo.details,
                                                ),
                                                const SizedBox(height: 14),
                                                Text(
                                                  l10n.attachments,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w800),
                                                ),
                                                const SizedBox(height: 8),
                                                attachmentsAsync.when(
                                                  data: (items) {
                                                    if (items == null ||
                                                        items.isEmpty) {
                                                      return Text(
                                                        l10n.noAttachments,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                                color: cs
                                                                    .onSurfaceVariant),
                                                      );
                                                    }
                                                    return Column(
                                                      children: [
                                                        for (final a in items)
                                                          ListTile(
                                                            dense: true,
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            leading: const Icon(
                                                                Icons
                                                                    .attach_file),
                                                            title: Text(
                                                              a.filename,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            subtitle: Text(
                                                              a.mime ?? '',
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            trailing: IconButton(
                                                              tooltip: l10n.remove,
                                                              icon: Icon(
                                                                  Icons
                                                                      .close,
                                                                  color:
                                                                      cs.error),
                                                              onPressed:
                                                                  () async {
                                                                final repo = ref
                                                                    .read(
                                                                        todoRepositoryProvider);
                                                                await repo
                                                                    .deleteAttachment(
                                                                        a.id);
                                                              },
                                                            ),
                                                            onTap: () async {
                                                              await OpenFilex
                                                                  .open(a
                                                                      .storedPath);
                                                            },
                                                          ),
                                                      ],
                                                    );
                                                  },
                                                  error: (e, _) => Text(
                                                    l10n.failedLoadAttachments(
                                                        e.toString()),
                                                    style: TextStyle(
                                                        color: cs.error),
                                                  ),
                                                  loading: () => const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child:
                                                        LinearProgressIndicator(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () async {
                                              final result =
                                                  await FilePicker.platform
                                                      .pickFiles(
                                                allowMultiple: true,
                                              );
                                              if (result == null ||
                                                  result.files.isEmpty) {
                                                return;
                                              }

                                              final repo = ref.read(
                                                  todoRepositoryProvider);
                                              final store = ref.read(
                                                  attachmentStoreProvider);

                                              for (final f in result.files) {
                                                final path = f.path;
                                                if (path == null) continue;
                                                final src = File(path);
                                                final imported =
                                                    await store.importFile(
                                                  todoId: todo.id,
                                                  source: src,
                                                );
                                                await repo.addAttachment(
                                                  todoId: todo.id,
                                                  filename:
                                                      p.basename(imported.path),
                                                  storedPath: imported.path,
                                                  originalPath: path,
                                                  mime: null,
                                                  size: f.size,
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.attach_file),
                                            label: Text(l10n.attach),
                                          ),
                                          const SizedBox(width: 10),
                                          FilledButton.tonalIcon(
                                            onPressed: () async {
                                              final repo = ref.read(
                                                  todoRepositoryProvider);
                                              final next = !todo.isCompleted;
                                              await repo.updateTodo(
                                                todo.id,
                                                isCompleted: next,
                                                completedAt: next
                                                    ? DateTime.now()
                                                    : null,
                                              );
                                            },
                                            icon: Icon(todo.isCompleted
                                                ? Icons.replay
                                                : Icons.check),
                                            label: Text(todo.isCompleted
                                                ? l10n.reopen
                                                : l10n.complete),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () async {
                                              final repo = ref.read(
                                                  todoRepositoryProvider);
                                              await repo.deleteTodo(todo.id);
                                              ref
                                                  .read(_selectedTodoIdProvider
                                                      .notifier)
                                                  .state = null;
                                            },
                                            tooltip: l10n.delete,
                                            icon: Icon(Icons.delete_outline,
                                                color: cs.error),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                                error: (e, _) => Center(
                                  child: Text(
                                    l10n.failedLoadDetails(e.toString()),
                                    style: TextStyle(
                                        color: cs.error,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter});

  final TodoFilterState filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: TextField(
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (v) {
              ref.read(_todoFilterProvider.notifier).state =
                  filter.copyWith(query: v);
            },
          ),
        ),
        FilterChip(
          selected: filter.status == TodoStatusFilter.open,
          onSelected: (v) {
            ref.read(_todoFilterProvider.notifier).state =
                filter.copyWith(status: v ? TodoStatusFilter.open : TodoStatusFilter.all);
          },
          label: Text(l10n.filterOpen),
        ),
        FilterChip(
          selected: filter.status == TodoStatusFilter.completed,
          onSelected: (v) {
            ref.read(_todoFilterProvider.notifier).state =
                filter.copyWith(status: v ? TodoStatusFilter.completed : TodoStatusFilter.all);
          },
          label: Text(l10n.filterCompleted),
        ),
        FilterChip(
          selected: filter.due == TodoDueFilter.dueToday,
          onSelected: (v) {
            ref.read(_todoFilterProvider.notifier).state =
                filter.copyWith(due: v ? TodoDueFilter.dueToday : TodoDueFilter.any);
          },
          label: Text(l10n.filterDueToday),
        ),
        FilterChip(
          selected: filter.due == TodoDueFilter.overdue,
          onSelected: (v) {
            ref.read(_todoFilterProvider.notifier).state =
                filter.copyWith(due: v ? TodoDueFilter.overdue : TodoDueFilter.any);
          },
          label: Text(l10n.filterOverdue, style: TextStyle(color: cs.error)),
        ),
        PopupMenuButton<int>(
          tooltip: l10n.priorityLabel,
          itemBuilder: (context) => [
            PopupMenuItem(value: 0, child: Text(l10n.priorityLow)),
            PopupMenuItem(value: 1, child: Text(l10n.priorityNormal)),
            PopupMenuItem(value: 2, child: Text(l10n.priorityHigh)),
            PopupMenuItem(value: 3, child: Text(l10n.priorityUrgent)),
            const PopupMenuDivider(),
            PopupMenuItem(value: -1, child: Text(l10n.priorityAny)),
          ],
          onSelected: (v) {
            ref.read(_todoFilterProvider.notifier).state = filter.copyWith(
              priorities: v == -1 ? null : {v},
            );
          },
          child: Chip(
            avatar: const Icon(Icons.flag_outlined, size: 18),
            label: Text(
              filter.priorities == null
                  ? l10n.priorityAny
                  : '${l10n.priorityLabel}: ${_priorityLabel(filter.priorities!.first)}',
            ),
          ),
        ),
      ],
    );
  }
}

final _todoFilterProvider = StateProvider<TodoFilterState>(
  (ref) => const TodoFilterState(),
);

final _todosProvider = StreamProvider.family<List<Todo>, TodoFilterState>(
  (ref, filter) {
    final repo = ref.watch(todoRepositoryProvider);
    return repo.watchTodos(filter);
  },
);

final _selectedTodoIdProvider = StateProvider<String?>((ref) => null);

final _selectedTodoProvider = StreamProvider<Todo?>((ref) {
  final id = ref.watch(_selectedTodoIdProvider);
  if (id == null) {
    return Stream.value(null);
  }
  final db = ref.watch(databaseProvider);
  return (db.select(db.todos)..where((t) => t.id.equals(id))).watchSingleOrNull();
});

final _attachmentsProvider = StreamProvider<List<Attachment>?>((ref) {
  final selectedId = ref.watch(_selectedTodoIdProvider);
  if (selectedId == null) return Stream.value(null);
  final repo = ref.watch(todoRepositoryProvider);
  return repo.watchAttachments(selectedId);
});

String _formatDue(DateTime dueAt) {
  final now = DateTime.now();
  final dueDate = DateTime(dueAt.year, dueAt.month, dueAt.day);
  final today = DateTime(now.year, now.month, now.day);
  final diffDays = dueDate.difference(today).inDays;
  if (diffDays == 0) return 'Today';
  if (diffDays == 1) return 'Tomorrow';
  if (diffDays == -1) return 'Yesterday';
  if (diffDays > 1) return 'In $diffDays d';
  return '${-diffDays} d ago';
}

String _priorityLabel(int value) {
  switch (value) {
    case 0:
      return 'low';
    case 1:
      return 'normal';
    case 2:
      return 'high';
    case 3:
      return 'urgent';
    default:
      return 'normal';
  }
}

class _TodoListTile extends StatelessWidget {
  const _TodoListTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.selected,
    required this.onTap,
    required this.onToggleComplete,
    required this.checkboxValue,
  });

  final String title;
  final String subtitle;
  final Widget trailing;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggleComplete;
  final bool checkboxValue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected
                ? cs.primaryContainer.withValues(alpha: 0.55)
                : cs.surfaceContainerHighest.withValues(alpha: 0.35),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Checkbox(
                value: checkboxValue,
                onChanged: (v) => onToggleComplete(v ?? false),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

