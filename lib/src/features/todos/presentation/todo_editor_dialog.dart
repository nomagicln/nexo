import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../data/db/app_database.dart';
import '../../../shared/providers.dart';

class TodoEditorDialog extends ConsumerStatefulWidget {
  const TodoEditorDialog({super.key, this.editing});

  final Todo? editing;

  @override
  ConsumerState<TodoEditorDialog> createState() => _TodoEditorDialogState();
}

class _TodoEditorDialogState extends ConsumerState<TodoEditorDialog> {
  late final TextEditingController _title;
  late final TextEditingController _details;

  int _priority = 1;
  int _critical = 0;
  int _important = 0;
  DateTime? _dueAt;
  DateTime? _atAt;
  bool _pinned = false;

  @override
  void initState() {
    super.initState();
    final t = widget.editing;
    _title = TextEditingController(text: t?.title ?? '');
    _details = TextEditingController(text: t?.details ?? '');
    _priority = t?.priority ?? 1;
    _critical = t?.criticalLevel ?? 0;
    _important = t?.importantLevel ?? 0;
    _dueAt = t?.dueAt;
    _atAt = t?.atAt;
    _pinned = t?.pinned ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final editing = widget.editing != null;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    editing ? l10n.editTodoTitle : l10n.newTodoTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: l10n.close,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _title,
                autofocus: !editing,
                decoration: InputDecoration(
                  labelText: l10n.titleLabel,
                  hintText: l10n.titleHint,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _details,
                minLines: 3,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: l10n.detailsLabel,
                  hintText: l10n.detailsHint,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _Segment(
                    label: l10n.priorityLabel,
                    child: DropdownButton<int>(
                      value: _priority,
                      items: [
                        DropdownMenuItem(
                            value: 0, child: Text(l10n.priorityLow)),
                        DropdownMenuItem(
                            value: 1, child: Text(l10n.priorityNormal)),
                        DropdownMenuItem(
                            value: 2, child: Text(l10n.priorityHigh)),
                        DropdownMenuItem(
                            value: 3, child: Text(l10n.priorityUrgent)),
                      ],
                      onChanged: (v) => setState(() => _priority = v ?? 1),
                    ),
                  ),
                  _LevelChip(
                    label: l10n.criticalLabel,
                    value: _critical,
                    onChanged: (v) => setState(() => _critical = v),
                  ),
                  _LevelChip(
                    label: l10n.importantLabel,
                    value: _important,
                    onChanged: (v) => setState(() => _important = v),
                  ),
                  FilterChip(
                    selected: _pinned,
                    onSelected: (v) => setState(() => _pinned = v),
                    label: Text(l10n.pinnedLabel),
                    avatar: const Icon(Icons.push_pin, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _DateField(
                    label: l10n.dueLabel,
                    value: _dueAt,
                    onPick: () async {
                      final picked = await _pickDateTime(context, _dueAt);
                      if (picked != null) setState(() => _dueAt = picked);
                    },
                    onClear: () => setState(() => _dueAt = null),
                  ),
                  _DateField(
                    label: l10n.atLabel,
                    value: _atAt,
                    onPick: () async {
                      final picked = await _pickDateTime(context, _atAt);
                      if (picked != null) setState(() => _atAt = picked);
                    },
                    onClear: () => setState(() => _atAt = null),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _title.text.trim().isEmpty
                        ? null
                        : () async {
                            final repo = ref.read(todoRepositoryProvider);
                            final title = _title.text.trim();
                            final details = _details.text.trim();

                            if (editing) {
                              await repo.updateTodo(
                                widget.editing!.id,
                                title: title,
                                details: details,
                                priority: _priority,
                                criticalLevel: _critical,
                                importantLevel: _important,
                                dueAt: _dueAt,
                                atAt: _atAt,
                                pinned: _pinned,
                              );
                              if (context.mounted) {
                                Navigator.of(context).pop(widget.editing!.id);
                              }
                              return;
                            }

                            final id = await repo.create(
                              title: title,
                              details: details,
                              priority: _priority,
                              criticalLevel: _critical,
                              importantLevel: _important,
                              dueAt: _dueAt,
                              atAt: _atAt,
                              pinned: _pinned,
                            );
                            if (context.mounted) Navigator.of(context).pop(id);
                          },
                    child: Text(editing ? l10n.save : l10n.create),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        child,
      ],
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: label,
      onSelected: onChanged,
      itemBuilder: (context) => List.generate(
        4,
        (i) => PopupMenuItem(
          value: i,
          child: Text('$label: $i'),
        ),
      ),
      child: Chip(
        label: Text('$label: $value'),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = value == null
        ? 'None'
        : '${value!.year.toString().padLeft(4, '0')}-'
            '${value!.month.toString().padLeft(2, '0')}-'
            '${value!.day.toString().padLeft(2, '0')} '
            '${value!.hour.toString().padLeft(2, '0')}:'
            '${value!.minute.toString().padLeft(2, '0')}';
    return OutlinedButton(
      onPressed: onPick,
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.onSurface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(value == null ? Icons.event_outlined : Icons.event),
          const SizedBox(width: 8),
          Text('$label: $text'),
          if (value != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onClear,
              child: const Icon(Icons.close, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

Future<DateTime?> _pickDateTime(BuildContext context, DateTime? initial) async {
  final now = DateTime.now();
  final init = initial ?? now;
  final date = await showDatePicker(
    context: context,
    initialDate: DateTime(init.year, init.month, init.day),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (!context.mounted) return null;
  if (date == null) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(init),
  );
  if (!context.mounted) return null;
  final t = time ?? TimeOfDay.fromDateTime(init);
  return DateTime(date.year, date.month, date.day, t.hour, t.minute);
}

