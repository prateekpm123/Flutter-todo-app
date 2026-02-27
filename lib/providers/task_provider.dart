import 'package:flutter/material.dart';
import 'package:task_management/models/enums.dart';
import 'package:task_management/models/task.dart';
import 'package:task_management/services/api_service.dart';
import 'package:task_management/services/cache_service.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _apiService;
  final CacheService _cacheService;

  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  String? _error;
  bool _isLoading = false;
  FilterType _currentFilter = FilterType.all;
  Task? _selectedTask;

  TaskProvider({
    required ApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  // Getters
  List<Task> get tasks => _filteredTasks;
  List<Task> get allTasks => _tasks;
  String? get error => _error;
  bool get isLoading => _isLoading;
  FilterType get currentFilter => _currentFilter;
  Task? get selectedTask => _selectedTask;

  bool get isEmpty => _filteredTasks.isEmpty;

  // Fetch tasks
  Future<void> fetchTasks(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to load from cache first
      final cachedTasks = await _cacheService.getCachedTasks();
      if (cachedTasks.isNotEmpty) {
        _tasks = cachedTasks;
        _applyFilter();
      }

      // Fetch from API
      final apiTasks = await _apiService.getTasks(userId);
      _tasks = apiTasks;
      await _cacheService.cacheTasks(_tasks);
      _applyFilter();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      
      // Fallback to cache on error
      final cachedTasks = await _cacheService.getCachedTasks();
      if (cachedTasks.isNotEmpty) {
        _tasks = cachedTasks;
        _applyFilter();
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  // Create task
  Future<void> createTask(
    String userId,
    String title,
    String description,
    DateTime dueDate,
  ) async {
    _error = null;

    try {
      final newTask = await _apiService.createTask(
        userId,
        title,
        description,
        dueDate,
      );

      _tasks.add(newTask);
      await _cacheService.cacheTask(newTask);
      _applyFilter();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update task
  Future<void> updateTask(Task updatedTask) async {
    _error = null;

    try {
      final task = await _apiService.updateTask(updatedTask);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        await _cacheService.cacheTask(task);
        _applyFilter();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    _error = null;

    try {
      await _apiService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      await _cacheService.removeTask(taskId);
      _applyFilter();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Filter tasks
  void setFilter(FilterType filter) {
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    switch (_currentFilter) {
      case FilterType.all:
        _filteredTasks = _tasks;
        break;
      case FilterType.pending:
        _filteredTasks = _tasks.where((t) => t.status == TaskStatus.pending).toList();
        break;
      case FilterType.inProgress:
        _filteredTasks = _tasks.where((t) => t.status == TaskStatus.inProgress).toList();
        break;
      case FilterType.completed:
        _filteredTasks = _tasks.where((t) => t.status == TaskStatus.completed).toList();
        break;
    }
    // Sort by due date
    _filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  void selectTask(Task task) {
    _selectedTask = task;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
