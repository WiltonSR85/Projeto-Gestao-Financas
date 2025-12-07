import 'package:flutter/material.dart';
import 'views/screens/login_page.dart';
import 'views/screens/home_shell.dart';
import 'views/screens/chat_page.dart';
import 'views/screens/register_page.dart';
import 'views/theme/app_theme.dart';
import 'views/screens/profile_page.dart';

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
        '/register': (context) => const RegisterPage(),
        '/home': (_) => const HomeShell(),
        '/chat': (_) => const ChatPage(),
        '/profile': (_) => const ProfilePage(),
      },
      initialRoute: '/',
    );
  }
}