import 'package:flutter/material.dart';
import 'views/screens/login_page.dart';
import 'views/screens/home_shell.dart';
import 'views/screens/chat_page.dart';
import 'views/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routes: {
        '/': (_) => const LoginPage(),
        '/home': (_) => const HomeShell(),
        '/chat': (_) => const ChatPage(),
      },
      initialRoute: '/',
    );
  }
}