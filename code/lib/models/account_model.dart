class ContaModel {
  final int? idConta;
  final String nome;
  final String tipo;
  final double saldoInicial;
  final double saldoAtual;
  final int idUsuario;

  ContaModel({
    this.idConta,
    required this.nome,
    required this.tipo,
    required this.saldoInicial,
    required this.saldoAtual,
    required this.idUsuario,
  });

  Map<String, Object?> toMap() {
    return {
      if (idConta != null) 'id_conta': idConta,
      'nome': nome,
      'tipo': tipo,
      'saldo_inicial': saldoInicial,
      'saldo_atual': saldoAtual,
      'id_usuario': idUsuario,
    };
  }

  factory ContaModel.fromMap(Map<String, Object?> map) {
    return ContaModel(
      idConta: map['id_conta'] as int?,
      nome: map['nome'] as String? ?? '',
      tipo: map['tipo'] as String? ?? '',
      saldoInicial: (map['saldo_inicial'] as num?)?.toDouble() ?? 0.0,
      saldoAtual: (map['saldo_atual'] as num?)?.toDouble() ?? 0.0,
      idUsuario: map['id_usuario'] as int? ?? 0,
    );
  }
}