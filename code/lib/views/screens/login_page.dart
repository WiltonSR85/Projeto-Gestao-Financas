import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            children: [
              const SizedBox(height: 18),
              // Logo
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.account_balance, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 18),
              Text(
                'Cash',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Gerencie seus gastos',
                style: TextStyle(color: Colors.white.withOpacity(0.75)),
              ),
              const SizedBox(height: 28),

              // Card with form
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.95))),
                    const SizedBox(height: 16),
                    const Text('Email', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'seu@email.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Senha', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Entrar button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: null,
                          elevation: 8,
                          shadowColor: Colors.black,
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          elevation: MaterialStateProperty.all(0),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [const Color(0xFFF97316), const Color(0xFFFFA552)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            constraints: const BoxConstraints(minHeight: 48),
                            child: const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(foregroundColor: Colors.white70),
                        child: const Text('Não tem conta? Crie agora', style: TextStyle(decoration: TextDecoration.underline)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              Text('Seus dados estão seguros e criptografados', style: TextStyle(color: Colors.white.withOpacity(0.6))),
            ],
          ),
        ),
      ),
    );
  }
}