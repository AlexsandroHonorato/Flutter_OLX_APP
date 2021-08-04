import 'dart:convert';

class Usuario {
  String idUsuario;
  String nome;
  String email;
  String senha;

  Usuario({
    this.idUsuario,
    this.nome,
    this.email,
    this.senha,
  });

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'nome': nome,
      'email': email,
      'senha': senha,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: map['idUsuario'],
      nome: map['nome'],
      email: map['email'],
      senha: map['senha'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Usuario.fromJson(String source) =>
      Usuario.fromMap(json.decode(source));
}
