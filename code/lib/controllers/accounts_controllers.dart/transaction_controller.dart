import 'package:flutter/foundation.dart';
import '../../models/transaction_model.dart';
import '../../database/database_helper.dart';
import '../../models/account_model.dart';
import 'account_controller.dart';

class TransactionController with ChangeNotifier {
  final List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  Future<void> addTransaction(TransactionModel tx) async {
    final db = await DatabaseHelper().database;
    await db.insert('transacao', tx.toMap());
    _transactions.add(tx);
    notifyListeners();
  }

  Future<void> removeTransaction(int idTransacao) async {
    final db = await DatabaseHelper().database;
    await db.delete('transacao', where: 'id_transacao = ?', whereArgs: [idTransacao]);
    _transactions.removeWhere((t) => t.idTransacao == idTransacao);
    notifyListeners();
  }

  Future<List<TransactionModel>> fetchTransactionsByConta(int contaId) async {
    final db = await DatabaseHelper().database;
    final res = await db.query('transacao', where: 'id_conta = ?', whereArgs: [contaId]);
    return res.map((row) {
      final data = <String, Object?>{};
      row.forEach((key, value) => data[key] = value);
      return TransactionModel.fromMap(data);
    }).toList();
  }

  double get totalAmount =>
      _transactions.fold(0.0, (sum, t) => sum + t.valor);

  Future<void> addTransactionAndUpdateAccount(TransactionModel tx) async {
    final db = await DatabaseHelper().database;

    // Busca a conta vinculada
    final conta = await AccountsController.instance.getContaById(tx.idConta);
    if (conta == null) throw Exception('Conta não encontrada');

    // Se for despesa, verifica se há saldo suficiente
    if (tx.tipo == 'despesa' && tx.valor > conta.saldoAtual) {
      throw Exception('Saldo insuficiente para esta despesa!');
    }

    // Atualiza o saldo
    final novoSaldo = tx.tipo == 'receita'
        ? conta.saldoAtual + tx.valor
        : conta.saldoAtual - tx.valor;

    // Atualiza a conta no banco
    await AccountsController.instance.updateSaldoConta(
      idConta: conta.idConta!,
      novoSaldo: novoSaldo,
    );

    // Salva a transação
    await db.insert('transacao', tx.toMap());
  }

  Map<String, double> calcularReceitasDespesas(List<TransactionModel> transacoes) {
    double receitas = 0;
    double despesas = 0;
    for (var tx in transacoes) {
      if (tx.tipo == 'receita') {
        receitas += tx.valor;
      } else {
        despesas += tx.valor;
      }
    }
    return {'receitas': receitas, 'despesas': despesas};
  }

  List<DateTime> gerarDiasDasTransacoes(List<TransactionModel> transacoes) {
    final datas = transacoes
        .map((tx) => DateTime.parse(tx.data.split('/').reversed.join('-')))
        .toList()
      ..sort();
    if (datas.isEmpty) return [DateTime.now()];
    return List<DateTime>.generate(
      datas.last.difference(datas.first).inDays + 1,
      (i) => datas.first.add(Duration(days: i)),
    );
  }

  List<double> gerarSaldosPorDia(List<TransactionModel> transacoes, ContaModel conta, List<DateTime> dias) {
    double saldo = conta.saldoInicial;
    final saldos = <double>[];
    for (final dia in dias) {
      final txsDoDia = transacoes.where((tx) {
        final txDate = DateTime.parse(tx.data.split('/').reversed.join('-'));
        return txDate.year == dia.year && txDate.month == dia.month && txDate.day == dia.day;
      });
      for (var tx in txsDoDia) {
        saldo += tx.tipo == 'receita' ? tx.valor : -tx.valor;
      }
      saldos.add(saldo);
    }
    return saldos;
  }
}