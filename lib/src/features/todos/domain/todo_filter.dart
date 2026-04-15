enum TodoStatusFilter { open, completed, all }

enum TodoDueFilter { any, dueToday, overdue, noDueDate }

class TodoFilterState {
  const TodoFilterState({
    this.status = TodoStatusFilter.open,
    this.due = TodoDueFilter.any,
    this.priorities,
    this.query = '',
  });

  final TodoStatusFilter status;
  final TodoDueFilter due;
  final Set<int>? priorities; // 0..3; null means any
  final String query;

  TodoFilterState copyWith({
    TodoStatusFilter? status,
    TodoDueFilter? due,
    Set<int>? priorities,
    String? query,
  }) {
    return TodoFilterState(
      status: status ?? this.status,
      due: due ?? this.due,
      priorities: priorities ?? this.priorities,
      query: query ?? this.query,
    );
  }
}

