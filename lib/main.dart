import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/providers/auth_provider.dart';
import 'package:task_management/providers/task_provider.dart';
import 'package:task_management/screens/add_task_screen.dart';
import 'package:task_management/screens/edit_task_screen.dart';
import 'package:task_management/screens/home_screen.dart';
import 'package:task_management/screens/login_screen.dart';
import 'package:task_management/screens/register_screen.dart';
import 'package:task_management/screens/splash_screen.dart';
import 'package:task_management/screens/task_details_screen.dart';
import 'package:task_management/services/api_service.dart';
import 'package:task_management/services/cache_service.dart';
import 'package:task_management/services/secure_storage_service.dart';
import 'package:task_management/theme/app_theme.dart';
import 'package:task_management/models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize cache service
  final cacheService = CacheService();
  await cacheService.initHive();
  
  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<SecureStorageService>(create: (_) => SecureStorageService()),
        Provider<CacheService>(create: (_) => cacheService),
        
        // State Management
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            apiService: context.read<ApiService>(),
            storageService: context.read<SecureStorageService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TaskProvider(
            apiService: context.read<ApiService>(),
            cacheService: context.read<CacheService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        return _buildRoute(settings);
      },
    );
  }

  Route<dynamic> _buildRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/add-task':
        return MaterialPageRoute(builder: (_) => const AddTaskScreen());
      case '/edit-task':
        final task = settings.arguments as Task;
        return MaterialPageRoute(
          builder: (_) => EditTaskScreen(task: task),
        );
      case '/task-details':
        final task = settings.arguments as Task;
        return MaterialPageRoute(
          builder: (_) => TaskDetailsScreen(task: task),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
