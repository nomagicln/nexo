import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../data/db/app_database.dart';
import '../../../shared/providers.dart';

class WidgetWindowApp extends StatelessWidget {
  const WidgetWindowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: WidgetWindowScreen(),
    );
  }
}

class WidgetWindowScreen extends ConsumerWidget {
  const WidgetWindowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final pinnedTodos = ref.watch(_pinnedTodosProvider);
    final alwaysOnTop = ref.watch(_widgetAlwaysOnTopProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            _WidgetTitleBar(
              onTogglePin: () async {
                final cur = ref.read(_widgetAlwaysOnTopProvider);
                final next = !cur;
                ref.read(_widgetAlwaysOnTopProvider.notifier).state = next;
                await windowManager.setAlwaysOnTop(next);
              },
              onClose: () async {
                await windowManager.close();
              },
              pinned: alwaysOnTop,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: pinnedTodos.when(
                  data: (todos) {
                    if (todos.isEmpty) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context)!.pinnedTodosEmpty,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: todos.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final t = todos[i];
                        return Material(
                          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: t.isCompleted,
                                    onChanged: (v) async {
                                      final repo =
                                          ref.read(todoRepositoryProvider);
                                      final next = v ?? false;
                                      await repo.updateTodo(
                                        t.id,
                                        isCompleted: next,
                                        completedAt:
                                            next ? DateTime.now() : null,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w800),
                                        ),
                                        if (t.dueAt != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            _formatDue(t.dueAt!),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: cs.secondary,
                                                    fontWeight:
                                                        FontWeight.w700),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: AppLocalizations.of(context)!.unpin,
                                    onPressed: () async {
                                      final repo =
                                          ref.read(todoRepositoryProvider);
                                      await repo.updateTodo(t.id, pinned: false);
                                    },
                                    icon: const Icon(Icons.push_pin_outlined),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  error: (e, _) => Center(
                    child: Text('Failed to load: $e',
                        style: TextStyle(color: cs.error)),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WidgetTitleBar extends StatelessWidget {
  const _WidgetTitleBar({
    required this.onTogglePin,
    required this.onClose,
    required this.pinned,
  });

  final VoidCallback onTogglePin;
  final VoidCallback onClose;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context)!.appName,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          IconButton(
            tooltip: pinned
                ? AppLocalizations.of(context)!.unpinDisableAot
                : AppLocalizations.of(context)!.pinEnableAot,
            onPressed: onTogglePin,
            icon: Icon(pinned ? Icons.push_pin : Icons.push_pin_outlined),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.close,
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

final _pinnedTodosProvider = StreamProvider<List<Todo>>((ref) {
  final db = ref.watch(databaseProvider);
  final q = db.select(db.todos)..where((t) => t.pinned.equals(true));
  q.orderBy([
    (t) => OrderingTerm.asc(t.isCompleted),
    (t) => OrderingTerm.asc(t.dueAt),
    (t) => OrderingTerm.desc(t.updatedAt),
  ]);
  return q.watch();
});

final _widgetAlwaysOnTopProvider = StateProvider<bool>((ref) => true);

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

