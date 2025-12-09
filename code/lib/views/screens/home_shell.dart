import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'categories_page.dart';
import 'accounts/accounts_page.dart';
import 'chat_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  static const pages = [
    HomePage(),
    ChatPage(),
    CategoriesPage(),
    AccountsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.chat_outlined), label: 'Chat IA'),
          NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Categorias'),
          NavigationDestination(icon: Icon(Icons.account_balance_outlined), label: 'Contas'),
          NavigationDestination(icon: Icon(Icons.person_outlined), label: 'Perfil'),

        ],
        backgroundColor: Colors.black.withOpacity(0.25),
      ),
    );
  }
}