import '/database/database_helper.dart';
import '../../models/category_model.dart';

class CategoriaController {
  CategoriaController._();
  static final CategoriaController instance = CategoriaController._();

  Future<List<CategoriaModel>> getCategoriasByUsuario(int idUsuario) async {
    final db = await DatabaseHelper().database;

    final res = await db.query(
      'categoria',
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'nome ASC',
    );

    return res.map((row) => CategoriaModel.fromMap(row)).toList();
  }

  Future<List<CategoriaModel>> getCategoriasByTipo(int idUsuario, String tipo) async {
    final db = await DatabaseHelper().database;

    final res = await db.query(
      'categoria',
      where: 'id_usuario = ? AND tipo = ?',
      whereArgs: [idUsuario, tipo],
      orderBy: 'nome ASC',
    );

    return res.map((row) => CategoriaModel.fromMap(row)).toList();
  }

  Future<Map<String, int>> getCountByTipo(int idUsuario) async {
    final categorias = await getCategoriasByUsuario(idUsuario);
    
    int todas = categorias.length;
    int despesas = categorias.where((c) => c.tipo == 'Despesa').length;
    int receitas = categorias.where((c) => c.tipo == 'Receita').length;

    return {
      'todas': todas,
      'despesas': despesas,
      'receitas': receitas,
    };
  }

  Future<String?> validarCategoria({
    required String nome,
    required String tipo,
  }) async {
    if (nome.isEmpty) return 'O nome não pode ser vazio.';
    if (tipo.isEmpty) return 'O tipo da categoria não pode ser vazio.';
    if (tipo != 'Despesa' && tipo != 'Receita') {
      return 'O tipo deve ser Despesa ou Receita.';
    }
    return null;
  }

  Future<int> addCategoria(CategoriaModel categoria) async {
    final erro = await validarCategoria(
      nome: categoria.nome,
      tipo: categoria.tipo,
    );

    if (erro != null) throw Exception(erro);

    final db = await DatabaseHelper().database;
    return await db.insert('categoria', categoria.toMap());
  }

  Future<int> updateCategoria(CategoriaModel categoria) async {
    final erro = await validarCategoria(
      nome: categoria.nome,
      tipo: categoria.tipo,
    );

    if (erro != null) throw Exception(erro);

    final db = await DatabaseHelper().database;

    return await db.update(
      'categoria',
      categoria.toMap(),
      where: 'id_categoria = ?',
      whereArgs: [categoria.idCategoria],
    );
  }

  Future<int> deleteCategoria(int idCategoria) async {
    final db = await DatabaseHelper().database;

    return await db.delete(
      'categoria',
      where: 'id_categoria = ?',
      whereArgs: [idCategoria],
    );
  }

  Future<CategoriaModel?> getCategoriaById(int idCategoria) async {
    final db = await DatabaseHelper().database;

    final res = await db.query(
      'categoria',
      where: 'id_categoria = ?',
      whereArgs: [idCategoria],
    );

    if (res.isEmpty) return null;

    return CategoriaModel.fromMap(res.first);
  }
}