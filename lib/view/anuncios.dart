import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx_app/models/anuncio.dart';
import 'package:olx_app/utils/categorias.dart';
import 'package:olx_app/widgets/widget_item_anuncio.dart';

class Anuncios extends StatefulWidget {
  Anuncios({Key key}) : super(key: key);

  @override
  _AnunciosState createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  List<String> itensMenu = [];
  List<DropdownMenuItem<String>> _listaItensDropEstados = [];
  List<DropdownMenuItem<String>> _listaItensDropCategorias = [];
  String _itemSelecionadoEstado = "Região";
  String _itemSelecionadoCategoria = "Categoria";
  final _controler = StreamController<QuerySnapshot>.broadcast();

  _ecolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case 'Meus anúcios':
        Navigator.pushNamed(context, '/meus-anuncios');
        break;

      case 'Entrar / Cadastrar':
        Navigator.pushNamed(context, '/login');
        break;

      case 'Deslogar':
        _deslogarUsurio();
        break;
    }
  }

  _deslogarUsurio() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();

    Navigator.pushNamed(context, '/login');
  }

  Future _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;

    if (usuarioLogado == null) {
      itensMenu = ['Entrar / Cadastrar'];
    } else {
      itensMenu = ['Meus anúcios', 'Deslogar'];
    }
  }

  _carregarItensDropdown() {
    //Categorias
    _listaItensDropCategorias = Configuracoes.getCategorias();
    //Estados
    _listaItensDropEstados = Configuracoes.getEstados();
  }

  Future<Stream<QuerySnapshot>> _filtrarAnuncios() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Query query = db.collection("anuncios");

    if (_itemSelecionadoEstado != "Região") {
      query = query.where("estado", isEqualTo: _itemSelecionadoEstado);
    }
    if (_itemSelecionadoCategoria != "Categoria") {
      query = query.where("categoria", isEqualTo: _itemSelecionadoCategoria);
    }

    Stream<QuerySnapshot> stream = query.snapshots();
    stream.listen((dados) {
      _controler.add(dados);
    });
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncio() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db.collection("anuncios").snapshots();

    stream.listen((dados) {
      _controler.add(dados);
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropdown();
    _verificarUsuarioLogado();
    _adicionarListenerAnuncio();
  }

  @override
  Widget build(BuildContext context) {
    var carregandoDados = Center(
      child: Column(
        children: [
          Text("Carregando anúncios...."),
          CircularProgressIndicator(),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('OLX'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _ecolhaMenuItem,
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Center(
                      child: DropdownButton(
                        iconEnabledColor: Color(0xff9c27b0),
                        value: _itemSelecionadoEstado,
                        onChanged: (estados) {
                          setState(() {
                            _itemSelecionadoEstado = estados;
                            _filtrarAnuncios();
                          });
                        },
                        items: _listaItensDropEstados,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey[200],
                  width: 2,
                  height: 40,
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Center(
                      child: DropdownButton(
                        iconEnabledColor: Color(0xff9c27b0),
                        value: _itemSelecionadoCategoria,
                        onChanged: (categoria) {
                          setState(() {
                            _itemSelecionadoCategoria = categoria;
                            _filtrarAnuncios();
                          });
                        },
                        items: _listaItensDropCategorias,
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            StreamBuilder(
                stream: _controler.stream,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return carregandoDados;
                      break;
                    case ConnectionState.active:
                    case ConnectionState.done:
                      QuerySnapshot querySnapshot = snapshot.data;

                      if (querySnapshot.docs.length == 0) {
                        return Container(
                          padding: EdgeInsets.all(25),
                          child: Text(
                            "Nenhum anúncio! :(",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return Expanded(
                        child: ListView.builder(
                          itemCount: querySnapshot.docs.length,
                          itemBuilder: (_, index) {
                            List<DocumentSnapshot> anuncios =
                                querySnapshot.docs.toList();
                            DocumentSnapshot documentSnapshot = anuncios[index];
                            Anuncio anuncio =
                                Anuncio.fromDocumentSnapshot(documentSnapshot);
                            return ItemAnuncio(
                              anuncio: anuncio,
                              onTapItem: () {
                                Navigator.pushNamed(context, "/detalhe-anuncio",
                                    arguments: anuncio);
                              },
                            );
                          },
                        ),
                      );
                  }
                  return Container();
                }),
          ],
        ),
      ),
    );
  }
}
