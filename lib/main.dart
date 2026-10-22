import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase.initializeApp() warning: $e');
  }
  runApp(const TodoApp());
}


/// Root Application (PRM393 - Todo Planner với Firebase & Google Sign-In)
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRM393 - Todo List Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEAF0F8),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E75AD),
          surface: const Color(0xFFEAF0F8),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // AuthGate tự động điều hướng: LoginScreen nếu chưa đăng nhập, TodoListScreen nếu đã lưu Session
      home: const AuthGate(),
    );
  }
}
