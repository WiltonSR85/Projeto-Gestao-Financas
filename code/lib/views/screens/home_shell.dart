import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'categories_page.dart';
import 'tools_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  static const pages = [
    HomePage(),
    ProfilePage(),
    CategoriesPage(),
    ToolsPage(),
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
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
          NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Categorias'),
          NavigationDestination(icon: Icon(Icons.build_outlined), label: 'Ferramentas'),
        ],
        backgroundColor: Colors.black.withOpacity(0.25),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70, left: 300),
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed('/chat'),
          tooltip: 'Chat IA',
          child: const Icon(Icons.chat_bubble_outline),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}