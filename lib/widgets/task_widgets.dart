import 'package:flutter/material.dart' hide DateUtils;
// import 'package:flutter/material.dart';
import 'package:task_management/models/enums.dart';
import 'package:task_management/models/task.dart';
import 'package:task_management/theme/app_theme.dart';
import 'package:task_management/utils/utils.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(Task)? onTaskCompleted;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onTaskCompleted,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = isDark
        ? StatusUtils.getDarkStatusColor(widget.task.status)
        : StatusUtils.getStatusColor(widget.task.status);
    final isCompleted = widget.task.status == TaskStatus.completed;

    return ScaleTransition(
      scale: _animation,
      child: GestureDetector(
        onTap: _handlePress,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Completion Radio Button
                GestureDetector(
                  onTap: () {
                    if (widget.onTaskCompleted != null) {
                      final updatedTask = widget.task.copyWith(
                        status: isCompleted ? TaskStatus.pending : TaskStatus.completed,
                      );
                      widget.onTaskCompleted!(updatedTask);
                    }
                  },
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? AppTheme.successColor : AppTheme.borderColor,
                        width: 2,
                      ),
                      color: isCompleted 
                          ? AppTheme.successColor.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: AppTheme.successColor,
                            size: 24,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and actions
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.task.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    decoration: isCompleted 
                                        ? TextDecoration.lineThrough 
                                        : TextDecoration.none,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.task.description,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    decoration: isCompleted 
                                        ? TextDecoration.lineThrough 
                                        : TextDecoration.none,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                onTap: widget.onEdit,
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: widget.onDelete,
                                child: const Row(
                                  children: [
                                    Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Status badge and due date
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(0x1A),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  StatusUtils.getStatusIcon(widget.task.status),
                                  size: 14,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.task.status.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateUtils.formatDaysUntilDue(widget.task.dueDate),
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatusSelector extends StatelessWidget {
  final TaskStatus selectedStatus;
  final Function(TaskStatus) onStatusChanged;

  const StatusSelector({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = isDark
        ? StatusUtils.getDarkStatusColor(selectedStatus)
        : StatusUtils.getStatusColor(selectedStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<TaskStatus>(
            value: selectedStatus,
            isExpanded: true,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            items: TaskStatus.values.map((status) {
              final color = isDark
                  ? StatusUtils.getDarkStatusColor(status)
                  : StatusUtils.getStatusColor(status);
              return DropdownMenuItem(
                value: status,
                child: Row(
                  children: [
                    Icon(
                      StatusUtils.getStatusIcon(status),
                      size: 18,
                      color: color,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      status.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (TaskStatus? newStatus) {
              if (newStatus != null) {
                onStatusChanged(newStatus);
              }
            },
          ),
        ),
      ],
    );
  }
}

class FilterChips extends StatelessWidget {
  final FilterType selectedFilter;
  final Function(FilterType) onFilterChanged;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: FilterType.values.map((filter) {
          final isSelected = filter == selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(filter),
              backgroundColor: Colors.transparent,
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
