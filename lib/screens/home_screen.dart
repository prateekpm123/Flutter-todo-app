import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:provider/provider.dart';
import 'package:task_management/models/task.dart';
import 'package:task_management/providers/auth_provider.dart';
import 'package:task_management/providers/task_provider.dart';
import 'package:task_management/theme/app_theme.dart';
import 'package:task_management/widgets/custom_widgets.dart';
import 'package:task_management/widgets/task_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  void _loadTasks() {
    final authProvider = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();
    if (authProvider.currentUser != null) {
      taskProvider.fetchTasks(authProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    Navigator.of(context).pushNamed('/add-task');
  }

  void _handleTaskEdit(Task task) {
    Navigator.of(context).pushNamed('/edit-task', arguments: task);
  }

  void _handleTaskDelete(String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(taskId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<AuthProvider>().logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Logout', style: TextStyle(color: AppTheme.errorColor)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          const SizedBox(height: 16),
          Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              return FilterChips(
                selectedFilter: taskProvider.currentFilter,
                onFilterChanged: (filter) {
                  taskProvider.setFilter(filter);
                },
              );
            },
          ),
          const SizedBox(height: 16),
          // Task list
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, _) {
                // Loading state
                if (taskProvider.isLoading && taskProvider.allTasks.isEmpty) {
                  return const TaskShimmerList();
                }

                // Error state
                if (taskProvider.error != null && taskProvider.tasks.isEmpty) {
                  return ErrorWidget(
                    error: taskProvider.error ?? 'Failed to load tasks',
                    onRetry: _loadTasks,
                  );
                }

                // Empty state
                if (taskProvider.isEmpty) {
                  return EmptyState(
                    icon: Icons.task_outlined,
                    title: 'No Tasks Yet',
                    subtitle: 'Create your first task to get started',
                    onAction: _showAddTaskDialog,
                    actionLabel: 'Create Task',
                  );
                }

                // Task list with pull-to-refresh
                return RefreshIndicator(
                  onRefresh: () async {
                    _loadTasks();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskProvider.tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () {
                          _handleTaskEdit(task);
                        },
                        onEdit: () {
                          _handleTaskEdit(task);
                        },
                        onDelete: () {
                          Navigator.pop(context);
                          _handleTaskDelete(task.id);
                        },
                        onTaskCompleted: (updatedTask) {
                          context.read<TaskProvider>().updateTask(updatedTask);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
