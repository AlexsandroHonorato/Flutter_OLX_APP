import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx_app/models/anuncio.dart';
import 'package:olx_app/widgets/widget_item_anuncio.dart';

class MeusAnuncios extends StatefulWidget {
  MeusAnuncios({Key key}) : super(key: key);

  @override
  _MeusAnunciosState createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {
  String idUsuarioLogado = '';

  final _controller = StreamController<QuerySnapshot>.broadcast();

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncio() async {
    await _recuperaUsuarioLogado();
    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_anuncios")
        .doc(idUsuarioLogado)
        .collection("anuncios")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _recuperaUsuarioLogado() async {
    //Salvar entidade anuncio no Firestore
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = await auth.currentUser;

    idUsuarioLogado = user.uid;
  }

  _removerAnuncio(String idAnuncio) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("meus_anuncios")
        .doc(idUsuarioLogado)
        .collection("anuncios")
        .doc(idAnuncio)
        .delete()
        .then((_) {
      db.collection("anuncios").doc(idAnuncio).delete();
    });
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerAnuncio();
  }

  @override
  Widget build(BuildContext context) {
    var carregandoDados = Column(
      children: [
        Text("Carregando anúncio......"),
        CircularProgressIndicator(),
      ],
    );
    return Scaffold(
        appBar: AppBar(
          title: Text('Meus Anúncios'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          icon: Icon(Icons.add),
          label: Text("Adicionar"),
          onPressed: () {
            Navigator.pushNamed(context, '/novo-anuncio');
          },
        ),
        body: StreamBuilder(
          stream: _controller.stream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return carregandoDados;
                break;
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasError) return Text("Erro ao carregar os dados");

                QuerySnapshot querySnapshot = snapshot.data;

                return ListView.builder(
                    itemCount: querySnapshot.docs.length,
                    itemBuilder: (_, index) {
                      List<DocumentSnapshot> anuncios =
                          querySnapshot.docs.toList();

                      DocumentSnapshot documentSnapshot = anuncios[index];
                      Anuncio anuncio =
                          Anuncio.fromDocumentSnapshot(documentSnapshot);

                      return ItemAnuncio(
                        anuncio: anuncio,
                        onPressedRemover: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Confirmar"),
                                  content: Text(
                                      "Deseja realmente excluir o anúnicio?"),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Cancelar"),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.grey,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _removerAnuncio(anuncio.id);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Remover"),
                                      style: ElevatedButton.styleFrom(
                                          primary: Colors.red),
                                    ),
                                  ],
                                );
                              });
                        },
                      );
                    });
            }
            return Container();
          },
        ));
  }
}
