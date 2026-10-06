import 'package:flutter/material.dart';
import 'screens/todo_list_screen.dart';

void main() {
  runApp(const TodoApp());
}

/// Root Application (tương đương App.tsx / index.js trong React Native)
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRM393 - Todo List Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const TodoListScreen(),
    );
  }
}
