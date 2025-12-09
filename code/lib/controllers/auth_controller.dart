import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class AuthController {
  AuthController._();
  static final AuthController instance = AuthController._();

  String _hash(String pwd) => sha256.convert(utf8.encode(pwd)).toString();

  /// Registra usuário e retorna id; lança Exception('email_exists') se email já cadastrado
  Future<int> register({required String nome, required String email, required String senha}) async {
    final nEmail = email.trim().toLowerCase();
    final nNome = nome.trim();
    final db = DatabaseHelper();
    final exists = await db.getUsuarioByEmail(nEmail);
    if (exists != null) {
      print('[AuthController] register: email already exists -> $nEmail');
      throw Exception('email_exists');
    }

    final row = <String, Object?>{
      'nome': nNome,
      'email': nEmail,
      'senha': _hash(senha), // armazena hash, nunca plain
      'data_criacao': DateTime.now().toIso8601String(),
    };

    try {
      final id = await db.insertUsuario(row);
      final all = await db.getAllUsuarios();
      print('[AuthController] user inserted id=$id allUsers=$all');
      return id;
    } on DatabaseException catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('unique') || msg.contains('constraint')) {
        print('[AuthController] register DatabaseException unique constraint -> $e');
        throw Exception('email_exists');
      }
      print('[AuthController] register DatabaseException -> $e');
      rethrow;
    } catch (e) {
      print('[AuthController] register error -> $e');
      rethrow;
    }
  }

  Future<void> saveUsuarioLogadoId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('usuario_id', id);
  }

  Future<int> getUsuarioLogadoId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('usuario_id') ?? 0;
  }

  /// Tenta fazer login; retorna User se sucesso, null caso credenciais inválidas
  Future<User?> login(String email, String senha) async {
    final nEmail = email.trim().toLowerCase();
    final db = DatabaseHelper();
    final userMap = await db.getUsuarioByEmail(nEmail);
    print('[AuthController] login: userMap=$userMap');

    if (userMap == null) {
      print('[AuthController] login: usuário não encontrado -> $nEmail');
      return null;
    }

    final hashed = _hash(senha);
    final stored = userMap['senha'] as String?;
    print('[AuthController] login: hashedInput=$hashed stored=$stored');

    if (stored == null || stored != hashed) {
      print('[AuthController] login: senha inválida para $nEmail');
      return null;
    }
    // sucesso: persiste sessão mínima
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', nEmail);
    await prefs.setString('user_nome', (userMap['nome'] as String?) ?? '');
    await prefs.setInt('usuario_id', userMap['id_usuario'] as int);
    print('[AuthController] login: sucesso -> $nEmail');
    return User.fromMap(userMap);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_nome');
    print('[AuthController] logout');
  }
}