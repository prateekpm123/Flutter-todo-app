enum TaskStatus {
  pending('Pending'),
  inProgress('In Progress'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;

  const TaskStatus(this.label);

  factory TaskStatus.fromString(String value) {
    return values.firstWhere(
      (e) => e.name == value,
      orElse: () => TaskStatus.pending,
    );
  }
}

enum FilterType {
  all('All'),
  pending('Pending'),
  inProgress('In Progress'),
  completed('Completed');

  final String label;

  const FilterType(this.label);
}
