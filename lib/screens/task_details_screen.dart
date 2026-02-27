import 'package:flutter/material.dart' hide DateUtils;
// import 'package:flutter/material.dart';
import 'package:task_management/models/task.dart';
import 'package:task_management/theme/app_theme.dart';
import 'package:task_management/utils/utils.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;

  const TaskDetailsScreen({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = isDark
        ? StatusUtils.getDarkStatusColor(task.status)
        : StatusUtils.getStatusColor(task.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed('/edit-task', arguments: task);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              task.title,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    StatusUtils.getStatusIcon(task.status),
                    size: 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task.status.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Description section
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            // Dates section
            Text(
              'Dates',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildDateInfo(
              context,
              'Due Date',
              DateUtils.formatDate(task.dueDate),
              Icons.calendar_today,
              statusColor,
            ),
            const SizedBox(height: 12),
            _buildDateInfo(
              context,
              'Created',
              DateUtils.formatDateTime(task.createdAt),
              Icons.access_time,
              AppTheme.textSecondaryColor,
            ),
            if (task.updatedAt != null) ...[
              const SizedBox(height: 12),
              _buildDateInfo(
                context,
                'Last Updated',
                DateUtils.formatDateTime(task.updatedAt!),
                Icons.update,
                AppTheme.textSecondaryColor,
              ),
            ],
            const SizedBox(height: 24),
            // Due date status
            _buildStatusBox(
              context,
              DateUtils.formatDaysUntilDue(task.dueDate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBox(BuildContext context, String status) {
    final isDue = status.contains('Overdue');
    final backgroundColor = isDue ? AppTheme.errorColor.withOpacity(0.1) : AppTheme.successColor.withOpacity(0.1);
    final textColor = isDue ? AppTheme.errorColor : AppTheme.successColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
