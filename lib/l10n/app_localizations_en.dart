// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nexo';

  @override
  String get inbox => 'Inbox';

  @override
  String get today => 'Today';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get labels => 'Labels';

  @override
  String get todos => 'Todos';

  @override
  String get newTodo => 'New';

  @override
  String get openWidgetWindow => 'Open widget window';

  @override
  String get searchHint => 'Search…';

  @override
  String get filterOpen => 'Open';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterDueToday => 'Due today';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get priorityAny => 'Priority: any';

  @override
  String get priorityLow => 'low';

  @override
  String get priorityNormal => 'normal';

  @override
  String get priorityHigh => 'high';

  @override
  String get priorityUrgent => 'urgent';

  @override
  String get noTodosYet => 'No todos yet. Create your first one.';

  @override
  String get details => 'Details';

  @override
  String get selectTodoHint => 'Select a todo from the list.';

  @override
  String get noDetails => 'No details.';

  @override
  String get attachments => 'Attachments';

  @override
  String get noAttachments => 'No attachments.';

  @override
  String get attach => 'Attach';

  @override
  String get complete => 'Complete';

  @override
  String get reopen => 'Reopen';

  @override
  String get delete => 'Delete';

  @override
  String get pin => 'Pin';

  @override
  String get edit => 'Edit';

  @override
  String get remove => 'Remove';

  @override
  String failedLoadTodos(Object error) {
    return 'Failed to load todos: $error';
  }

  @override
  String failedLoadDetails(Object error) {
    return 'Failed to load details: $error';
  }

  @override
  String failedLoadAttachments(Object error) {
    return 'Failed to load attachments: $error';
  }

  @override
  String get newTodoTitle => 'New todo';

  @override
  String get editTodoTitle => 'Edit todo';

  @override
  String get close => 'Close';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleHint => 'What do you need to do?';

  @override
  String get detailsLabel => 'Details';

  @override
  String get detailsHint => 'Notes, context, checklist…';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get priorityShort => 'priority';

  @override
  String get criticalLabel => 'Critical';

  @override
  String get criticalShort => 'critical';

  @override
  String get importantLabel => 'Important';

  @override
  String get importantShort => 'important';

  @override
  String get pinnedLabel => 'Pinned';

  @override
  String get dueLabel => 'Due';

  @override
  String get dueShort => 'due';

  @override
  String get atLabel => 'At';

  @override
  String get atShort => 'at';

  @override
  String get none => 'None';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get save => 'Save';

  @override
  String get pinnedTodosEmpty => 'No pinned todos.';

  @override
  String get unpin => 'Unpin';

  @override
  String get unpinDisableAot => 'Unpin (disable always-on-top)';

  @override
  String get pinEnableAot => 'Pin (always-on-top)';
}
