import 'package:dio/dio.dart';
import 'package:task_management/models/enums.dart';
import 'package:task_management/models/task.dart';
import 'package:task_management/models/user.dart';

class ApiService {
  late final Dio _dio;
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
      ),
    );
  }

  // Auth endpoints
  Future<User> login(String email, String password) async {
    try {
      // Mock implementation - replace with real API
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      return User(
        id: '1',
        email: email,
        name: email.split('@')[0],
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<User> register(String name, String email, String password) async {
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('All fields are required');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      return User(
        id: '1',
        email: email,
        name: name,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  // Task endpoints
  Future<List<Task>> getTasks(String userId) async {
    try {
      final response = await _dio.get(
        '/todos',
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((task) => Task.fromJson({
          'id': task['id'].toString(),
          'title': task['title'] ?? '',
          'description': 'Task description',
          'status': 'pending',
          'dueDate': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
          'userId': userId,
        })).toList();
      }
      throw Exception('Failed to fetch tasks');
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Future<Task> createTask(String userId, String title, String description, DateTime dueDate) async {
    try {
      if (title.isEmpty) {
        throw Exception('Title is required');
      }

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      return Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        status: TaskStatus.pending,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        userId: userId,
      );
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      if (task.title.isEmpty) {
        throw Exception('Title is required');
      }

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      return task.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Helper methods
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout. Please try again.';
    } else if (error.type == DioExceptionType.badResponse) {
      return 'Error: ${error.response?.statusCode}';
    }
    return 'An error occurred. Please try again.';
  }
}
