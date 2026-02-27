import 'package:flutter/material.dart';
import 'package:task_management/models/user.dart';
import 'package:task_management/providers/task_provider.dart';
import 'package:task_management/services/api_service.dart';
import 'package:task_management/services/cache_service.dart';
import 'package:task_management/services/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final SecureStorageService _storageService;
  final CacheService _cacheService;
  final TaskProvider _taskProvider;

  User? _currentUser;
  String? _error;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  AuthProvider({
    required ApiService apiService,
    required SecureStorageService storageService,
    required CacheService cacheService,
    required TaskProvider taskProvider,
  })  : _apiService = apiService,
        _storageService = storageService,
        _cacheService = cacheService,
        _taskProvider = taskProvider;

  // Getters
  User? get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _apiService.login(email, password);
      _currentUser = user;
      _isAuthenticated = true;

      // Save user data
      await _storageService.saveUserData(
        userId: user.id,
        email: user.email,
        name: user.name,
      );

      // Reset task provider for new user session
      _taskProvider.reset();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _apiService.register(name, email, password);
      _currentUser = user;
      _isAuthenticated = true;

      // Save user data
      await _storageService.saveUserData(
        userId: user.id,
        email: user.email,
        name: user.name,
      );

      // Reset task provider for new user session
      _taskProvider.reset();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check authentication status
  Future<void> checkAuthStatus() async {
    final userData = await _storageService.getUserData();
    if (userData['userId'] != null) {
      _currentUser = User(
        id: userData['userId']!,
        email: userData['email'] ?? '',
        name: userData['name'] ?? '',
      );
      _isAuthenticated = true;
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    await _storageService.clearAll();
    await _cacheService.clearCache();
    _taskProvider.reset();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
