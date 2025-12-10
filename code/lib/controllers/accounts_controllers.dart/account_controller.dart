import '/database/database_helper.dart';
import '../../models/account_model.dart';

// Controller responsável por gerenciar as operações relacionadas à conta
class AccountsController {
  // Singleton: garante que só exista uma instância do controller
  AccountsController._();
  static final AccountsController instance = AccountsController._();

  /*
  // (Comentado) Busca todas as contas do banco, independente do usuário
  Future<List<ContaModel>> getAllContas() async {
    final res = await DatabaseHelper().getAllContas();
    return res.map((row) {
      final data = <String, Object?>{};
      row.forEach((key, value) => data[key] = value);
      return ContaModel.fromMap(data);
    }).toList();
  }
  */

  // Busca todas as contas de um usuário específico pelo idUsuario
  Future<List<ContaModel>> getContasByUsuario(int idUsuario) async {
    final db = await DatabaseHelper().database;
    final res = await db.query(
      'conta',
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
    );
    // Converte cada linha do resultado em um objeto ContaModel
    return res.map((row) {
      final data = <String, Object?>{};
      row.forEach((key, value) => data[key] = value);
      return ContaModel.fromMap(data);
    }).toList();
  }

  // Valida os dados de uma conta antes de salvar
  Future<String?> validarConta({
    required String nome,
    required double saldoInicial,
  }) async {
    if (nome.isEmpty) return 'O nome não pode ser vazio.';
    if (saldoInicial < 0) return 'Saldo inicial não pode ser negativo.';
    return null; // Dados válidos
  }

  // Adiciona uma nova conta no banco de dados
  Future<int> addConta(ContaModel conta) async {
    final erro = await validarConta(nome: conta.nome, saldoInicial: conta.saldoInicial);
    if (erro != null) {
      throw Exception(erro); // Lança exceção se houver erro de validação
    }
    return await DatabaseHelper().insertConta(conta.toMap());
  }

  // Atualiza nome e tipo de uma conta existente
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

  // Remove uma conta do banco de dados pelo id
  Future<int> deleteConta(int idConta) async {
    final db = await DatabaseHelper().database;
    return await db.delete(
      'conta',
      where: 'id_conta = ?',
      whereArgs: [idConta],
    );
  }

  // Busca uma conta específica pelo id
  Future<ContaModel?> getContaById(int idConta) async {
    final db = await DatabaseHelper().database;
    final res = await db.query(
      'conta',
      where: 'id_conta = ?',
      whereArgs: [idConta],
    );
    if (res.isEmpty) return null; // Não encontrou a conta
    final data = <String, Object?>{};
    res.first.forEach((key, value) => data[key] = value);
    return ContaModel.fromMap(data);
  }

  // Atualiza apenas o saldo atual de uma conta
  Future<void> updateSaldoConta({required int idConta, required double novoSaldo}) async {
    final db = await DatabaseHelper().database;
    await db.update(
      'conta',
      {'saldo_atual': novoSaldo},
      where: 'id_conta = ?',
      whereArgs: [idConta],
    );
  }

  // Edita uma conta (nome e tipo) usando um objeto ContaModel já preenchido
  Future<void> editarConta(ContaModel contaEditada) async {
    await updateConta(
      idConta: contaEditada.idConta!,
      nome: contaEditada.nome,
      tipo: contaEditada.tipo,
    );
  }

  // Exclui uma conta usando apenas o id
  Future<void> excluirConta(int idConta) async {
    final db = await DatabaseHelper().database;
    await db.delete(
      'conta',
      where: 'id_conta = ?',
      whereArgs: [idConta],
    );
  }
}