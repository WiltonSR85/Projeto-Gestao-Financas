import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'financas.db');
    // DEBUG: path do DB para garantir que você está acessando o mesmo arquivo
    print('[DatabaseHelper] DB path: $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) {
        print('[DatabaseHelper] onOpen called');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('[DatabaseHelper] Creating DB schema');
    await db.execute('''
      CREATE TABLE usuario (
        id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        email TEXT UNIQUE,
        senha TEXT,
        data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    await db.execute('''
      CREATE TABLE conta (
        id_conta INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        tipo TEXT,
        saldo_inicial REAL,
        saldo_atual REAL DEFAULT 0.0,
        id_usuario INTEGER,
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE categoria (
        id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        tipo TEXT,
        icone TEXT,
        cor TEXT,
        id_usuario INTEGER,
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE transacao (
        id_transacao INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        valor REAL,
        data TEXT,
        descricao TEXT,
        recorrente INTEGER DEFAULT 0,
        id_conta INTEGER,
        id_categoria INTEGER,
        FOREIGN KEY (id_conta) REFERENCES conta(id_conta),
        FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
      );
    ''');

    await db.execute('''
      CREATE TABLE meta_financeira (
        id_meta INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        valor_alvo REAL,
        valor_atual REAL DEFAULT 0.0,
        prazo TEXT,
        id_usuario INTEGER,
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
      );
    ''');

    await db.execute('''
      CREATE TABLE sincronizacao (
        id_sync INTEGER PRIMARY KEY,
        tabela TEXT,
        id_registro INTEGER,
        operacao TEXT,
        status TEXT DEFAULT 'pendente',
        data_sync TEXT DEFAULT (DATE('now'))
      );
    ''');
    print('[DatabaseHelper] DB created');
  }

  // Inserção de usuário (DAO)
  Future<int> insertUsuario(Map<String, Object?> row) async {
    final db = await database;
    try {
      final id = await db.insert('usuario', row);
      print('[DatabaseHelper] insertUsuario id=$id row=$row');
      return id;
    } catch (e) {
      print('[DatabaseHelper] insertUsuario error: $e');
      rethrow;
    }
  }

  // Busca usuário por email (retorna Map ou null)
  Future<Map<String, Object?>?> getUsuarioByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'usuario',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    print('[DatabaseHelper] getUsuarioByEmail("$email") -> results=$results');
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // DEBUG: retorna todos os usuários
  Future<List<Map<String, Object?>>> getAllUsuarios() async {
    final db = await database;
    final res = await db.query('usuario');
    print('[DatabaseHelper] getAllUsuarios -> $res');
    return res;
  }

  // Inserção de conta (DAO)
  Future<int> insertConta(Map<String, Object?> row) async {
    final db = await database;
    try {
      final id = await db.insert('conta', row);
      print('[DatabaseHelper] insertConta id=$id row=$row');
      return id;
    } catch (e) {
      print('[DatabaseHelper] insertConta error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, Object?>>> getAllContas() async {
    final db = await database;
    final res = await db.query('conta');
    print('[DatabaseHelper] getAllContas -> $res');
    return res;
  }

  // Método de debug: apaga o arquivo do DB (use somente em desenvolvimento)
  Future<void> deleteDatabaseDebug() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'financas.db');
    print('[DatabaseHelper] Deleting DB at $path');
    await deleteDatabase(path);
    _database = null;
  }

  // Adicione estes métodos ao seu DatabaseHelper existente:

  // ============================================
  // MÉTODOS PARA TRANSAÇÕES (usar no ChatService)
  // ============================================

  /// Busca todas as transações (para análise da IA)
  Future<List<Map<String, Object?>>> getAllTransacoes() async {
    final db = await database;
    final res = await db.query('transacao', orderBy: 'data DESC');
    print('[DatabaseHelper] getAllTransacoes -> ${res.length} transações encontradas');
    return res;
  }

  /// Busca transações com informações de conta e categoria (JOIN)
  Future<List<Map<String, Object?>>> getTransacoesComDetalhes() async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT 
        t.*,
        c.nome as conta_nome,
        cat.nome as categoria_nome,
        cat.icone as categoria_icone,
        cat.cor as categoria_cor
      FROM transacao t
      LEFT JOIN conta c ON t.id_conta = c.id_conta
      LEFT JOIN categoria cat ON t.id_categoria = cat.id_categoria
      ORDER BY t.data DESC
    ''');
    print('[DatabaseHelper] getTransacoesComDetalhes -> ${res.length} transações');
    return res;
  }

  /// Busca transações por período
  Future<List<Map<String, Object?>>> getTransacoesPorPeriodo({
    required String dataInicio,
    required String dataFim,
  }) async {
    final db = await database;
    final res = await db.query(
      'transacao',
      where: 'data BETWEEN ? AND ?',
      whereArgs: [dataInicio, dataFim],
      orderBy: 'data DESC',
    );
    print('[DatabaseHelper] getTransacoesPorPeriodo -> ${res.length} transações');
    return res;
  }

  /// Busca transações por tipo (receita ou despesa)
  Future<List<Map<String, Object?>>> getTransacoesPorTipo(String tipo) async {
    final db = await database;
    final res = await db.query(
      'transacao',
      where: 'tipo = ?',
      whereArgs: [tipo],
      orderBy: 'data DESC',
    );
    print('[DatabaseHelper] getTransacoesPorTipo($tipo) -> ${res.length} transações');
    return res;
  }

  /// Calcula total de receitas
  Future<double> getTotalReceitas() async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT SUM(valor) as total 
      FROM transacao 
      WHERE tipo = 'receita'
    ''');
    final total = res.first['total'];
    return (total as num?)?.toDouble() ?? 0.0;
  }

  /// Calcula total de despesas
  Future<double> getTotalDespesas() async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT SUM(valor) as total 
      FROM transacao 
      WHERE tipo = 'despesa'
    ''');
    final total = res.first['total'];
    return (total as num?)?.toDouble() ?? 0.0;
  }

  /// Estatísticas gerais
  Future<Map<String, dynamic>> getEstatisticasGerais() async {
    final totalReceitas = await getTotalReceitas();
    final totalDespesas = await getTotalDespesas();
    final saldo = totalReceitas - totalDespesas;
    
    final db = await database;
    final countRes = await db.rawQuery('SELECT COUNT(*) as count FROM transacao');
    final count = countRes.first['count'] as int;

    return {
      'totalReceitas': totalReceitas,
      'totalDespesas': totalDespesas,
      'saldo': saldo,
      'totalTransacoes': count,
    };
  }

  // ============================================
  // MÉTODOS ÚTEIS PARA CATEGORIAS
  // ============================================

  /// Busca todas as categorias
  Future<List<Map<String, Object?>>> getAllCategorias() async {
    final db = await database;
    final res = await db.query('categoria');
    print('[DatabaseHelper] getAllCategorias -> ${res.length} categorias');
    return res;
  }

  /// Insere categoria
  Future<int> insertCategoria(Map<String, Object?> row) async {
    final db = await database;
    try {
      final id = await db.insert('categoria', row);
      print('[DatabaseHelper] insertCategoria id=$id');
      return id;
    } catch (e) {
      print('[DatabaseHelper] insertCategoria error: $e');
      rethrow;
    }
  }

  // ============================================
  // MÉTODOS ÚTEIS PARA TRANSAÇÕES
  // ============================================

  /// Insere transação
  Future<int> insertTransacao(Map<String, Object?> row) async {
    final db = await database;
    try {
      final id = await db.insert('transacao', row);
      print('[DatabaseHelper] insertTransacao id=$id');
      return id;
    } catch (e) {
      print('[DatabaseHelper] insertTransacao error: $e');
      rethrow;
    }
  }

  /// Atualiza transação
  Future<int> updateTransacao(int id, Map<String, Object?> row) async {
    final db = await database;
    try {
      final count = await db.update(
        'transacao',
        row,
        where: 'id_transacao = ?',
        whereArgs: [id],
      );
      print('[DatabaseHelper] updateTransacao id=$id count=$count');
      return count;
    } catch (e) {
      print('[DatabaseHelper] updateTransacao error: $e');
      rethrow;
    }
  }

  /// Deleta transação
  Future<int> deleteTransacao(int id) async {
    final db = await database;
    try {
      final count = await db.delete(
        'transacao',
        where: 'id_transacao = ?',
        whereArgs: [id],
      );
      print('[DatabaseHelper] deleteTransacao id=$id count=$count');
      return count;
    } catch (e) {
      print('[DatabaseHelper] deleteTransacao error: $e');
      rethrow;
    }
  }
}


