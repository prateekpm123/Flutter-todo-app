# API Documentation

## Overview

The Task Management app currently uses mock API implementations for demonstration purposes. This document describes the API contracts and how to integrate with a real backend.

## Base Configuration

```dart
class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  
  late final Dio _dio;
  
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
}
```

## Authentication Endpoints

### User Login

**Endpoint**: `POST /auth/login`

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (Success - 200)**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "id": "user123",
    "email": "user@example.com",
    "name": "John Doe",
    "profilePicture": null
  }
}
```

**Response (Error - 401)**:
```json
{
  "success": false,
  "error": "Invalid credentials"
}
```

**Implementation in App**:
```dart
Future<User> login(String email, String password) async {
  try {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    
    return User.fromJson(response.data['data']);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

### User Registration

**Endpoint**: `POST /auth/register`

**Request Body**:
```json
{
  "name": "John Doe",
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (Success - 201)**:
```json
{
  "success": true,
  "message": "Registration successful",
  "data": {
    "id": "user123",
    "email": "user@example.com",
    "name": "John Doe",
    "profilePicture": null
  }
}
```

**Response (Error - 400)**:
```json
{
  "success": false,
  "error": "Email already exists"
}
```

## Task Endpoints

### Get All Tasks

**Endpoint**: `GET /tasks?userId={userId}`

**Query Parameters**:
- `userId` (required): The ID of the user

**Response (Success - 200)**:
```json
{
  "success": true,
  "message": "Tasks retrieved successfully",
  "data": [
    {
      "id": "task1",
      "title": "Complete project",
      "description": "Finish the Flutter app",
      "status": "in_progress",
      "dueDate": "2026-03-15T00:00:00Z",
      "createdAt": "2026-02-27T10:30:00Z",
      "updatedAt": "2026-02-27T14:20:00Z",
      "userId": "user123"
    }
  ]
}
```

**Implementation in App**:
```dart
Future<List<Task>> getTasks(String userId) async {
  try {
    final response = await _dio.get(
      '/tasks',
      queryParameters: {'userId': userId},
    );
    
    final List<dynamic> data = response.data['data'];
    return data.map((task) => Task.fromJson(task)).toList();
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

### Create Task

**Endpoint**: `POST /tasks`

**Request Body**:
```json
{
  "title": "New Task",
  "description": "Task description",
  "status": "pending",
  "dueDate": "2026-03-15T00:00:00Z",
  "userId": "user123"
}
```

**Response (Success - 201)**:
```json
{
  "success": true,
  "message": "Task created successfully",
  "data": {
    "id": "task123",
    "title": "New Task",
    "description": "Task description",
    "status": "pending",
    "dueDate": "2026-03-15T00:00:00Z",
    "createdAt": "2026-02-27T10:30:00Z",
    "updatedAt": null,
    "userId": "user123"
  }
}
```

**Implementation in App**:
```dart
Future<Task> createTask(
  String userId,
  String title,
  String description,
  DateTime dueDate,
) async {
  try {
    final response = await _dio.post(
      '/tasks',
      data: {
        'title': title,
        'description': description,
        'status': 'pending',
        'dueDate': dueDate.toIso8601String(),
        'userId': userId,
      },
    );
    
    return Task.fromJson(response.data['data']);
  } catch (e) {
    throw Exception('Failed to create task: $e');
  }
}
```

### Update Task

**Endpoint**: `PUT /tasks/{taskId}`

**URL Parameters**:
- `taskId` (required): The ID of the task to update

**Request Body**:
```json
{
  "title": "Updated Task",
  "description": "Updated description",
  "status": "completed",
  "dueDate": "2026-03-15T00:00:00Z"
}
```

**Response (Success - 200)**:
```json
{
  "success": true,
  "message": "Task updated successfully",
  "data": {
    "id": "task123",
    "title": "Updated Task",
    "description": "Updated description",
    "status": "completed",
    "dueDate": "2026-03-15T00:00:00Z",
    "createdAt": "2026-02-27T10:30:00Z",
    "updatedAt": "2026-02-27T15:00:00Z",
    "userId": "user123"
  }
}
```

**Implementation in App**:
```dart
Future<Task> updateTask(Task task) async {
  try {
    final response = await _dio.put(
      '/tasks/${task.id}',
      data: {
        'title': task.title,
        'description': task.description,
        'status': task.status.name,
        'dueDate': task.dueDate.toIso8601String(),
      },
    );
    
    return Task.fromJson(response.data['data']);
  } catch (e) {
    throw Exception('Failed to update task: $e');
  }
}
```

### Delete Task

**Endpoint**: `DELETE /tasks/{taskId}`

**URL Parameters**:
- `taskId` (required): The ID of the task to delete

**Response (Success - 204 No Content)**:
```
HTTP/1.1 204 No Content
```

**Response (Error - 404)**:
```json
{
  "success": false,
  "error": "Task not found"
}
```

**Implementation in App**:
```dart
Future<void> deleteTask(String taskId) async {
  try {
    await _dio.delete('/tasks/$taskId');
  } catch (e) {
    throw Exception('Failed to delete task: $e');
  }
}
```

## Data Models

### User Model

```json
{
  "id": "string",
  "email": "string",
  "name": "string",
  "profilePicture": "string or null"
}
```

**Validation Rules**:
- `id`: Non-empty string, unique
- `email`: Valid email format
- `name`: Non-empty string, 2-100 characters
- `profilePicture`: Optional URL string

### Task Model

```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "status": "pending|in_progress|completed|cancelled",
  "dueDate": "ISO8601 datetime string",
  "createdAt": "ISO8601 datetime string",
  "updatedAt": "ISO8601 datetime string or null",
  "userId": "string"
}
```

**Validation Rules**:
- `id`: Non-empty string, unique
- `title`: Non-empty string, 3-200 characters
- `description`: Non-empty string, 1-2000 characters
- `status`: One of: pending, in_progress, completed, cancelled
- `dueDate`: Must be today or later (validated on client)
- `createdAt`: ISO8601 datetime (server-generated)
- `updatedAt`: ISO8601 datetime or null (server-managed)
- `userId`: Must match authenticated user's ID

## Status Codes

| Code | Description | Action |
|------|-------------|--------|
| 200 | Success | Proceed normally |
| 201 | Created | Resource created successfully |
| 204 | No Content | Success with no response body |
| 400 | Bad Request | Fix request and retry |
| 401 | Unauthorized | Re-login required |
| 403 | Forbidden | Access denied |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Resource conflict (e.g., duplicate) |
| 500 | Server Error | Show error and retry |
| 503 | Service Unavailable | Show error and retry |

## Error Handling

All error responses follow this format:

```json
{
  "success": false,
  "error": "Error description",
  "message": "User-friendly error message"
}
```

## Request/Response Headers

### Request Headers
```
Content-Type: application/json
Authorization: Bearer {token} (when available)
```

### Response Headers
```
Content-Type: application/json
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1614332400
```

## Rate Limiting

- **Limit**: 1000 requests per hour
- **Window**: Rolling 1-hour window
- **Headers**: X-RateLimit-* in response

## Authentication

Token-based authentication using JWT:

1. **Login** → Receive access token
2. **Store** token securely in SecureStorage
3. **Include** token in Authorization header for protected endpoints
4. **Refresh** token when expired
5. **Logout** → Clear token

## Pagination (Future Enhancement)

```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

## Mock Implementation Reference

Current mock implementation in `ApiService`:

```dart
// Simulates 1-second API delay
await Future.delayed(const Duration(seconds: 1));

// Validates input
if (email.isEmpty || password.isEmpty) {
  throw Exception('Email and password are required');
}

// Returns mock response
return User(
  id: '1',
  email: email,
  name: email.split('@')[0],
);
```

## Integration with Real API

To integrate with a real backend:

1. **Update baseUrl**:
   ```dart
   static const String baseUrl = 'https://your-api.com';
   ```

2. **Replace mock implementations** with actual API calls:
   ```dart
   final response = await _dio.post('/auth/login', data: {...});
   return User.fromJson(response.data['data']);
   ```

3. **Add authentication interceptor**:
   ```dart
   _dio.interceptors.add(InterceptorsWrapper(
     onRequest: (options, handler) {
       final token = await _storageService.getToken();
       options.headers['Authorization'] = 'Bearer $token';
       return handler.next(options);
     },
   ));
   ```

4. **Handle token refresh**:
   ```dart
   if (e.response?.statusCode == 401) {
     // Refresh token and retry
   }
   ```

## Example: Complete Integration

```dart
class ApiService {
  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error']);
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
```

---

**API Version**: 1.0
**Last Updated**: February 2026
