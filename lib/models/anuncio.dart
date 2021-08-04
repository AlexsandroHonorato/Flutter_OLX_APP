import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Anuncio {
  String id;
  String estado;
  String categoria;
  String titulo;
  String preco;
  String telefone;
  String descricao;
  List<String> fotos;

  Anuncio({
    this.id,
    this.estado,
    this.categoria,
    this.titulo,
    this.preco,
    this.telefone,
    this.descricao,
    this.fotos,
  });

  Anuncio.gerarId() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference anuncios = db.collection("meus_anuncios");
    this.id = anuncios.doc().id;
    this.fotos = [];
  }

  Anuncio.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    this.id = documentSnapshot.id;
    this.estado = documentSnapshot["estado"];
    this.categoria = documentSnapshot["categoria"];
    this.titulo = documentSnapshot["titulo"];
    this.preco = documentSnapshot["preco"];
    this.telefone = documentSnapshot["telefone"];
    this.descricao = documentSnapshot["descricao"];
    this.fotos = List<String>.from(documentSnapshot["fotos"]);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'estado': estado,
      'categoria': categoria,
      'titulo': titulo,
      'preco': preco,
      'telefone': telefone,
      'descricao': descricao,
      'fotos': fotos,
    };
  }

  factory Anuncio.fromMap(Map<String, dynamic> map) {
    return Anuncio(
      id: map['id'],
      estado: map['estado'],
      categoria: map['categoria'],
      titulo: map['titulo'],
      preco: map['preco'],
      telefone: map['telefone'],
      descricao: map['descricao'],
      fotos: List<String>.from(map['fotos']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Anuncio.fromJson(String source) =>
      Anuncio.fromMap(json.decode(source));
}
