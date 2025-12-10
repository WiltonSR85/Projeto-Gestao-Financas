class CategoriaModel {
  final int? idCategoria;
  final String nome;
  final String tipo;
  final int idUsuario;
  final String? icone;
  final String? cor;

  CategoriaModel({
    this.idCategoria,
    required this.nome,
    required this.tipo,
    required this.idUsuario,
    this.icone,
    this.cor,
  });

  Map<String, Object?> toMap() {
    return {
      if (idCategoria != null) 'id_categoria': idCategoria,
      'nome': nome,
      'tipo': tipo,
      'id_usuario': idUsuario,
      'icone': icone,
      'cor': cor,
    };
  }

  factory CategoriaModel.fromMap(Map<String, Object?> map) {
    return CategoriaModel(
      idCategoria: map['id_categoria'] as int?,
      nome: map['nome'] as String? ?? '',
      tipo: map['tipo'] as String? ?? '',
      idUsuario: map['id_usuario'] as int? ?? 0,
      icone: map['icone'] as String?,
      cor: map['cor'] as String?,
    );
  }
}