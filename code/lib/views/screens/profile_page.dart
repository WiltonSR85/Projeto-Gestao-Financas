import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final bool hideScaffold;

  const ProfilePage({
    super.key,
    this.hideScaffold = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Text(
        'Perfil (em construção)',
        style: TextStyle(
          color: Colors.white70,
        ),
      ),
    );

    if (hideScaffold) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: content,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Perfil"),
      ),
      body: content,
    );
  }
}