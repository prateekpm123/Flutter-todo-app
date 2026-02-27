# Architecture & Implementation Guide

## Overview

This Task Management app follows a clean architecture pattern with clear separation of concerns. The architecture promotes testability, maintainability, and scalability.

## Architecture Layers

```
┌─────────────────────────────────────┐
│       Presentation Layer            │
│    (Screens & Widgets)              │
├─────────────────────────────────────┤
│       State Management Layer        │
│    (Provider Pattern)               │
├─────────────────────────────────────┤
│       Business Logic Layer          │
│    (Services)                       │
├─────────────────────────────────────┤
│       Data Layer                    │
│    (API, Cache, Secure Storage)     │
└─────────────────────────────────────┘
```

## Layer Breakdown

### 1. Presentation Layer (Screens & Widgets)

**Responsibility**: UI rendering and user interaction

**Components**:
- **Screens**: Full-page UI components
  - `LoginScreen`: User login interface
  - `RegisterScreen`: User registration interface
  - `HomeScreen`: Task list with filtering
  - `AddTaskScreen`: Create new tasks
  - `EditTaskScreen`: Modify existing tasks
  - `TaskDetailsScreen`: View task details

- **Widgets**: Reusable UI components
  - `TaskCard`: Individual task display with actions
  - `StatusSelector`: Status selection interface
  - `FilterChips`: Filter selection interface
  - `LoadingShimmer`: Animated loading placeholder
  - `EmptyState`: User-friendly empty state screen
  - `ErrorWidget`: Error display with retry

**Key Principles**:
- Screens only consume state from providers
- No direct service calls from UI
- All business logic delegated to providers
- Responsive and adaptive layouts

### 2. State Management Layer (Provider Pattern)

**Responsibility**: Application state management and reactive updates

**Providers**:
- `AuthProvider`: Manages authentication state
  - Login/Logout operations
  - User data persistence
  - Authentication status tracking

- `TaskProvider`: Manages task state
  - Task CRUD operations
  - Filtering and sorting
  - Error handling

**Why Provider Pattern**:
1. **Simplicity**: Easy to understand and implement
2. **Testability**: Providers can be easily mocked
3. **Performance**: Fine-grained reactivity without boilerplate
4. **Flexibility**: Works with any service setup

**State Management Flow**:
```
User Action in Screen
    ↓
Calls Provider Method
    ↓
Provider executes Business Logic (via Service)
    ↓
Provider updates internal State
    ↓
Provider notifies Listeners (Widgets)
    ↓
Widgets rebuild with new State
```

### 3. Business Logic Layer (Services)

**Responsibility**: Core business logic and data operations

**Services**:

#### ApiService
- Handles all API communication
- Manages HTTP requests using Dio
- Implements error handling and timeouts
- Provides endpoints for:
  - Authentication (Login, Register)
  - Task Management (CRUD operations)

**Key Features**:
```dart
- Centralized API configuration
- Request/response interceptors
- Error handling and parsing
- Timeout management
```

#### CacheService
- Manages local data persistence using Hive
- Implements caching strategy
- Provides fallback data when offline

**Key Features**:
```dart
- Task caching
- User data caching
- Cache invalidation
- Offline support
```

#### SecureStorageService
- Manages sensitive data storage
- Uses platform-native secure storage
- Handles user credentials securely

**Key Features**:
```dart
- Secure token storage
- Encrypted user data
- Platform-specific security
```

### 4. Data Layer

**Responsibility**: Data access and persistence

**Components**:
- **Models**: Data structures
  - `User`: User information
  - `Task`: Task details
  - `TaskStatus`: Task status enum
  - `FilterType`: Filter type enum

- **Data Sources**:
  - Remote: API via Dio
  - Local Cache: Hive database
  - Secure Storage: flutter_secure_storage

## Data Flow Patterns

### Authentication Flow
```
1. User enters credentials in LoginScreen
2. LoginScreen calls AuthProvider.login()
3. AuthProvider calls ApiService.login()
4. ApiService makes HTTP request
5. ApiService returns User object
6. AuthProvider saves user data via SecureStorageService
7. AuthProvider updates internal state
8. UI automatically rebuilds showing authenticated state
9. Navigation to HomeScreen
```

### Task Loading Flow
```
1. HomeScreen calls TaskProvider.fetchTasks()
2. TaskProvider attempts API call via ApiService
3. On success:
   - Receives task list from API
   - Caches tasks via CacheService
   - Updates internal state
   - Notifies listeners
4. On failure:
   - Loads cached tasks as fallback
   - Updates state with cached data
   - Shows error message
   - Provides retry option
```

### Task Creation Flow
```
1. User enters task details in AddTaskScreen
2. Form validation occurs
3. On valid submission:
   - Calls TaskProvider.createTask()
   - TaskProvider calls ApiService.createTask()
   - Task is created and returned
   - Task cached locally
   - UI updated with new task
   - Success notification shown
```

## State Management Patterns

### Provider Pattern Implementation

**ChangeNotifierProvider** for reactive state:
```dart
ChangeNotifierProvider(
  create: (context) => AuthProvider(
    apiService: context.read<ApiService>(),
    storageService: context.read<SecureStorageService>(),
  ),
)
```

**MultiProvider** for dependency injection:
```dart
MultiProvider(
  providers: [
    Provider<ApiService>(create: (_) => ApiService()),
    Provider<SecureStorageService>(create: (_) => SecureStorageService()),
    ChangeNotifierProvider(create: (_) => AuthProvider(...)),
    ChangeNotifierProvider(create: (_) => TaskProvider(...)),
  ],
  child: MyApp(),
)
```

**Consumer** for reactive UI updates:
```dart
Consumer<TaskProvider>(
  builder: (context, taskProvider, _) {
    return ListView.builder(
      itemCount: taskProvider.tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(task: taskProvider.tasks[index]);
      },
    );
  },
)
```

## Error Handling Strategy

### Multi-Level Error Handling

1. **Service Level**: ApiService handles network errors
   ```dart
   try {
     final response = await _dio.get('/tasks');
   } on DioException catch (e) {
     throw _handleError(e);
   }
   ```

2. **Provider Level**: Catches service errors and updates state
   ```dart
   try {
     final tasks = await _apiService.getTasks();
     _tasks = tasks;
   } catch (e) {
     _error = e.toString();
   }
   ```

3. **UI Level**: Displays error states with retry options
   ```dart
   if (taskProvider.error != null) {
     return ErrorWidget(
       error: taskProvider.error!,
       onRetry: _loadTasks,
     );
   }
   ```

### Fallback Strategy

- **Cache Fallback**: If API fails, load cached data
- **Graceful Degradation**: Show cached data with error notification
- **Offline Support**: Full functionality with cached data when offline

## Testing Strategy

### Unit Testing Approach

**Test Structure**:
```dart
void main() {
  group('AuthProvider', () {
    late AuthProvider authProvider;
    late MockApiService mockApiService;
    late MockSecureStorageService mockStorageService;

    setUp(() {
      // Initialize mocks and provider
    });

    test('login sets current user', () async {
      // Arrange
      final testUser = User(id: '1', email: 'test@example.com', name: 'Test');
      when(mockApiService.login(...)).thenAnswer((_) async => testUser);

      // Act
      final result = await authProvider.login(...);

      // Assert
      expect(result, true);
      expect(authProvider.currentUser, testUser);
    });
  });
}
```

### Testing Best Practices

1. **Mock External Dependencies**: API, Storage
2. **Test Provider Logic**: State changes, method calls
3. **Test Error Cases**: Network failures, invalid input
4. **Test UI Interactions**: Button clicks, form submission

## Performance Optimizations

### 1. State Management Optimization
- **Selective Listeners**: Use `Consumer` only where needed
- **Efficient Rebuilds**: Provider prevents unnecessary rebuilds
- **Lazy Loading**: Load data only when needed

### 2. Network Optimization
- **Caching Strategy**: Cache API responses locally
- **Timeout Configuration**: 10-second timeout for all requests
- **Error Retry**: Automatic retry on network failures

### 3. UI Optimization
- **Widget Reusability**: Common widgets throughout app
- **Lazy Loading Lists**: ListView with incremental loading
- **Shimmer Loading**: Smooth loading experience
- **Image Optimization**: Platform-specific assets

### 4. Local Storage Optimization
- **Hive Database**: Fast, efficient NoSQL storage
- **Selective Caching**: Cache important data only
- **Cache Expiration**: Implement TTL for cache (optional)

## Security Implementation

### 1. Secure Storage
```dart
class SecureStorageService {
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(...),  // Encrypted with RSA
    iOptions: IOSOptions(...),      // Stored in Keychain
  );
}
```

### 2. Input Validation
```dart
class ValidationUtils {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
```

### 3. Error Safety
- No sensitive data in error messages
- Logs don't contain passwords or tokens
- Safe error descriptions for users

## Navigation Architecture

### Named Route Navigation
```dart
// Define routes in onGenerateRoute
Route<dynamic> _buildRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case '/home':
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    // ... other routes
  }
}

// Navigate with arguments
Navigator.pushNamed(context, '/edit-task', arguments: task);
```

### Navigation Flow
```
SplashScreen (Check Auth)
    ├── Login/Register (Not Authenticated)
    │   ├── LoginScreen
    │   └── RegisterScreen
    └── Home (Authenticated)
        ├── HomeScreen
        ├── AddTaskScreen
        ├── EditTaskScreen
        └── TaskDetailsScreen
```

## Folder Structure Benefits

1. **Feature-Based Organization**: Easy to locate and maintain code
2. **Separation of Concerns**: Clear responsibility for each layer
3. **Scalability**: Easy to add new features without affecting existing code
4. **Testability**: Each component can be tested independently
5. **Reusability**: Common widgets and utilities shared across app

## Best Practices Followed

✅ **DRY (Don't Repeat Yourself)**: Common widgets and utilities
✅ **SOLID Principles**: Single responsibility, dependency injection
✅ **Clean Code**: Clear naming, proper comments, consistent formatting
✅ **Error Handling**: Comprehensive error management at all levels
✅ **Performance**: Optimized state management and caching
✅ **Security**: Secure storage, input validation
✅ **Testing**: Unit tests for critical components
✅ **Documentation**: Code comments and architecture documentation

## Future Improvements

1. **GraphQL**: Replace REST API with GraphQL for better efficiency
2. **Bloc Pattern**: Migrate to Bloc for more complex state management
3. **Dependency Injection**: Use GetIt or similar for better DI
4. **Repository Pattern**: Add repository layer for data abstraction
5. **API Versioning**: Support multiple API versions
6. **Advanced Caching**: Implement cache expiration and invalidation
7. **Offline-First**: Full offline capability with sync when online
8. **WebSocket**: Real-time updates using WebSocket

---

**Architecture Version**: 1.0
**Last Updated**: February 2026
