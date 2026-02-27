import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_management/models/task.dart';

class CacheService {
  static const String _tasksBoxName = 'tasks';
  static const String _userBoxName = 'user';

  Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(_tasksBoxName);
    await Hive.openBox(_userBoxName);
  }

  // Task caching
  Future<void> cacheTasks(List<Task> tasks) async {
    final box = Hive.box(_tasksBoxName);
    await box.clear();
    for (var task in tasks) {
      await box.put(task.id, task.toJson());
    }
  }

  Future<List<Task>> getCachedTasks() async {
    final box = Hive.box(_tasksBoxName);
    final tasks = <Task>[];
    for (var value in box.values) {
      if (value is Map) {
        tasks.add(Task.fromJson(Map<String, dynamic>.from(value)));
      }
    }
    return tasks;
  }

  Future<void> cacheTask(Task task) async {
    final box = Hive.box(_tasksBoxName);
    await box.put(task.id, task.toJson());
  }

  Future<void> removeTask(String taskId) async {
    final box = Hive.box(_tasksBoxName);
    await box.delete(taskId);
  }

  Future<void> clearTasks() async {
    final box = Hive.box(_tasksBoxName);
    await box.clear();
  }

  // User caching
  Future<void> cacheUserId(String userId) async {
    final box = Hive.box(_userBoxName);
    await box.put('userId', userId);
  }

  Future<String?> getCachedUserId() async {
    final box = Hive.box(_userBoxName);
    return box.get('userId') as String?;
  }

  Future<void> clearCache() async {
    await clearTasks();
    final box = Hive.box(_userBoxName);
    await box.clear();
  }
}
