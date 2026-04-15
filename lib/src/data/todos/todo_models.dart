enum TodoPriority {
  low,
  normal,
  high,
  urgent;

  static TodoPriority fromDb(int value) =>
      TodoPriority.values[value.clamp(0, TodoPriority.values.length - 1)];
}

