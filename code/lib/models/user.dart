class User {
  final int? id;
  final String nome;
  final String email;
  final String? dataCriacao;

  User({this.id, required this.nome, required this.email, this.dataCriacao});

  factory User.fromMap(Map<String, Object?> m) {
    return User(
      id: m['id_usuario'] as int?,
      nome: m['nome'] as String? ?? '',
      email: m['email'] as String? ?? '',
      dataCriacao: m['data_criacao']?.toString(),
    );
  }
}