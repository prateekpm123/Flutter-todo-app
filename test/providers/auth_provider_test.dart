import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task_management/models/user.dart';
import 'package:task_management/providers/auth_provider.dart';
import 'package:task_management/providers/task_provider.dart';
import 'package:task_management/services/api_service.dart';
import 'package:task_management/services/cache_service.dart';
import 'package:task_management/services/secure_storage_service.dart';

class MockApiService extends Mock implements ApiService {}
class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockCacheService extends Mock implements CacheService {}
class MockTaskProvider extends Mock implements TaskProvider {}

void main() {
  group('AuthProvider', () {
    late AuthProvider authProvider;
    late MockApiService mockApiService;
    late MockSecureStorageService mockStorageService;
    late MockCacheService mockCacheService;
    late MockTaskProvider mockTaskProvider;

    setUp(() {
      mockApiService = MockApiService();
      mockStorageService = MockSecureStorageService();
      mockCacheService = MockCacheService();
      mockTaskProvider = MockTaskProvider();
      authProvider = AuthProvider(
        apiService: mockApiService,
        storageService: mockStorageService,
        cacheService: mockCacheService,
        taskProvider: mockTaskProvider,
      );
    });

    test('initial state is not authenticated', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, null);
      expect(authProvider.error, null);
    });

    test('login sets current user and authenticated status', () async {
      final testUser = User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
      );

      when(mockApiService.login('test@example.com', 'password123'))
          .thenAnswer((_) async => testUser);
      when(mockStorageService.saveUserData(
        userId: '1',
        email: 'test@example.com',
        name: 'Test User',
      )).thenAnswer((_) async => Future.value());
      when(mockTaskProvider.reset()).thenAnswer((_) => Future.value());

      final result = await authProvider.login('test@example.com', 'password123');

      expect(result, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser, testUser);
      expect(authProvider.error, null);
      verify(mockTaskProvider.reset()).called(1);
    });

    test('login handles errors gracefully', () async {
      when(mockApiService.login('test@example.com', ''))
          .thenThrow(Exception('Invalid credentials'));

      final result = await authProvider.login('test@example.com', '');

      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, null);
      expect(authProvider.error, isNotNull);
    });

    test('logout clears user data', () async {
      final testUser = User(
        id: '1',
        email: 'test@example.com',
        name: 'Test User',
      );

      // Set up authenticated state
      when(mockApiService.login('test@example.com', 'password123'))
          .thenAnswer((_) async => testUser);
      when(mockStorageService.saveUserData(
        userId: '1',
        email: 'test@example.com',
        name: 'Test User',
      )).thenAnswer((_) async => Future.value());
      when(mockTaskProvider.reset()).thenAnswer((_) => Future.value());

      when(mockStorageService.clearAll())
          .thenAnswer((_) async => Future.value());
      when(mockCacheService.clearCache())
          .thenAnswer((_) async => Future.value());

      await authProvider.login('test@example.com', 'password123');
      await authProvider.logout();

      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, null);
      verify(mockTaskProvider.reset()).called(2); // Called in both login and logout
    });
  });
}
