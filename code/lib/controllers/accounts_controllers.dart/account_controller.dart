import '/database/database_helper.dart';
import '../../models/account_model.dart';

class AccountsController {
  AccountsController._();
  static final AccountsController instance = AccountsController._();

  Future<List<ContaModel>> getAllContas() async {
    final res = await DatabaseHelper().getAllContas();
    return res.map((row) {
      final data = <String, Object?>{};
      row.forEach((key, value) => data[key] = value);
      return ContaModel.fromMap(data);
    }).toList();
  }

  Future<List<ContaModel>> getContasByUsuario(int idUsuario) async {
    final db = await DatabaseHelper().database;
    final res = await db.query(
      'conta',
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
    );
    return res.map((row) {
      final data = <String, Object?>{};
      row.forEach((key, value) => data[key] = value);
      return ContaModel.fromMap(data);
    }).toList();
  }

  Future<String?> validarConta({
    required String nome,
    required double saldoInicial,
  }) async {
    if (nome.isEmpty) return 'O nome não pode ser vazio.';
    if (saldoInicial < 0) return 'Saldo inicial não pode ser negativo.';
    return null;
  }

  Future<int> addConta(ContaModel conta) async {
    final erro = await validarConta(nome: conta.nome, saldoInicial: conta.saldoInicial);
    if (erro != null) {
      throw Exception(erro);
    }
    return await DatabaseHelper().insertConta(conta.toMap());
  }

  Future<int> updateConta({
    required int idConta,
    required String nome,
    required String tipo,
  }) async {
    final db = await DatabaseHelper().database;
    return await db.update(
      'conta',
      {'nome': nome, 'tipo': tipo},
      where: 'id_conta = ?',
      whereArgs: [idConta],
    );
  }

  Future<int> deleteConta(int idConta) async {
    final db = await DatabaseHelper().database;
    return await db.delete(
      'conta',
      where: 'id_conta = ?',
      whereArgs: [idConta],
    );
  }

  Future<ContaModel?> getContaById(int idConta) async {
    final db = await DatabaseHelper().database;
    final res = await db.query(
      'conta',
      where: 'id_conta = ?',
      whereArgs: [idConta],
    );
    if (res.isEmpty) return null;
    final data = <String, Object?>{};
    res.first.forEach((key, value) => data[key] = value);
    return ContaModel.fromMap(data);
  }

  Future<void> updateSaldoConta({required int idConta, required double novoSaldo}) async {
    final db = await DatabaseHelper().database;
    await db.update(
      'conta',
      {'saldo_atual': novoSaldo},
      where: 'id_conta = ?',
      whereArgs: [idConta],
    );
  }
}