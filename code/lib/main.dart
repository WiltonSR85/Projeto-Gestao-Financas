import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'views/screens/login_page.dart';
import 'views/screens/home_shell.dart';
import 'views/screens/chat_page.dart';
import 'views/screens/register_page.dart';
import 'views/theme/app_theme.dart';
import 'views/screens/profile_page.dart';
import 'views/screens/accounts/accounts_page.dart';
import 'views/screens/accounts/account_detail_page.dart';

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      routes: {
        '/': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const HomeShell(),
        '/chat': (_) => const ChatPage(),
        '/profile': (_) => const ProfilePage(),
        '/accounts': (_) => const AccountsPage(),
        '/accountDetail': (_) =>
            AccountDetailPage(contaId: 0, color: Colors.orange),
      },
      initialRoute: '/',
    );
  }
}