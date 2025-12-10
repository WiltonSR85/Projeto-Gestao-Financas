class TransactionModel {
  final int? idTransacao;
  final String tipo;
  final double valor;
  final String data;
  final String descricao;
  final bool recorrente;
  final int idConta;
  final int idCategoria;

  TransactionModel({
    this.idTransacao,
    required this.tipo,
    required this.valor,
    required this.data,
    required this.descricao,
    required this.recorrente,
    required this.idConta,
    required this.idCategoria,
  });

  Map<String, Object?> toMap() {
    return {
      if (idTransacao != null) 'id_transacao': idTransacao,
      'tipo': tipo,
      'valor': valor,
      'data': data,
      'descricao': descricao,
      'recorrente': recorrente ? 1 : 0,
      'id_conta': idConta,
      'id_categoria': idCategoria,
    };
  }

  factory TransactionModel.fromMap(Map<String, Object?> map) {
    return TransactionModel(
      idTransacao: map['id_transacao'] as int?,
      tipo: map['tipo'] as String? ?? '',
      valor: (map['valor'] as num?)?.toDouble() ?? 0.0,
      data: map['data'] as String? ?? '',
      descricao: map['descricao'] as String? ?? '',
      recorrente: (map['recorrente'] as int? ?? 0) == 1,
      idConta: map['id_conta'] as int? ?? 0,
      idCategoria: map['id_categoria'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_transacao': idTransacao,
      'tipo': tipo,
      'valor': valor,
      'data': data,
      'descricao': descricao,
      'recorrente': recorrente,
      'id_conta': idConta,
      'id_categoria': idCategoria,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      idTransacao: json['id_transacao'] as int?,
      tipo: json['tipo'] as String? ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      data: json['data'] as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
      recorrente: json['recorrente'] as bool? ?? false,
      idConta: json['id_conta'] as int? ?? 0,
      idCategoria: json['id_categoria'] as int? ?? 0,
    );
  }
}