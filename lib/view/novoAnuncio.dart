import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olx_app/models/anuncio.dart';
import 'package:olx_app/utils/categorias.dart';
import 'package:olx_app/widgets/widget_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx_app/widgets/widget_textfield.dart';
import 'package:validadores/Validador.dart';

class NovoAnuncio extends StatefulWidget {
  @override
  _NovoAnuncioState createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {
  List<File> _listaImagens = [];
  final _formKey = GlobalKey<FormState>();
  List<DropdownMenuItem<String>> _listaItensDropEstados = [];
  List<DropdownMenuItem<String>> _listaItensDropCategorias = [];
  TextEditingController _controllerTitulo = TextEditingController();
  TextEditingController _controllerpreco = TextEditingController();
  TextEditingController _controllerTelefone = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();
  Anuncio _anuncio = Anuncio();
  BuildContext _dialogContext;

  _selecionarImagemGaleria() async {
    File imagemSelecionada;
    final picker = ImagePicker();

    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    imagemSelecionada = File(pickedFile.path);

    if (imagemSelecionada != null) {
      setState(() {
        _listaImagens.add(imagemSelecionada);
      });
    }
  }

  _carregarItensDropdown() {
    //Categorias
    _listaItensDropCategorias = Configuracoes.getCategorias();
    //Estados
    _listaItensDropEstados = Configuracoes.getEstados();
  }

  _salvarAnuncio() async {
    _abrirDialog(_dialogContext);

    //Upload imagens no Storage
    await _uploadImagens();

    //Salvar anuncio no Firestore
    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser;
    String idUsuarioLogado = usuarioLogado.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("meus_anuncios")
        .doc(idUsuarioLogado)
        .collection("anuncios")
        .doc(_anuncio.id)
        .set(_anuncio.toMap())
        .then((_) {
      //salvar an??ncio p??blico
      db
          .collection("anuncios")
          .doc(_anuncio.id)
          .set(_anuncio.toMap())
          .then((_) {
        db
            .collection("anuncios")
            .doc(_anuncio.id)
            .set(_anuncio.toMap())
            .then((_) {
          Navigator.pop(_dialogContext);
          Navigator.pop(context);
        });
      });
    });
  }

  Future _uploadImagens() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();

    for (var imagem in _listaImagens) {
      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      Reference arquivo =
          pastaRaiz.child("meus_anuncios").child(_anuncio.id).child(nomeImagem);

      UploadTask uploadTask = arquivo.putFile(imagem);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

      String url = await taskSnapshot.ref.getDownloadURL();
      _anuncio.fotos.add(url);
    }
  }

  _abrirDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 20,
                ),
                Text("Salvando an??ncio...."),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropdown();
    _anuncio = Anuncio.gerarId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Novo an??ncio"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                FormField<List>(
                  initialValue: _listaImagens,
                  validator: (imagens) {
                    if (imagens.length == 0) {
                      return "Necess??rio selecionar uma imagem!";
                    }
                    return null;
                  },
                  builder: (state) {
                    return Column(
                      children: <Widget>[
                        Container(
                          height: 100,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _listaImagens.length + 1, //3
                              itemBuilder: (context, indice) {
                                if (indice == _listaImagens.length) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        _selecionarImagemGaleria();
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey[400],
                                        radius: 50,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.add_a_photo,
                                              size: 40,
                                              color: Colors.grey[100],
                                            ),
                                            Text(
                                              "Adicionar",
                                              style: TextStyle(
                                                  color: Colors.grey[100]),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                if (_listaImagens.length > 0) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.file(
                                                    _listaImagens[indice]),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _listaImagens
                                                          .removeAt(indice);
                                                      Navigator.of(context)
                                                          .pop();
                                                    });
                                                  },
                                                  child: Text(
                                                    'Excluir',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundImage: FileImage(
                                          _listaImagens[indice],
                                        ),
                                        child: Container(
                                          color: Color.fromRGBO(
                                              255, 255, 225, 0.4),
                                          alignment: Alignment.center,
                                          child: Icon(Icons.delete,
                                              color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Container();
                              }),
                        ),
                        if (state.hasError)
                          Container(
                            child: Text(
                              "[${state.errorText}]",
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          )
                      ],
                    );
                  },
                ),
                Row(
                  children: [
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.all(8),
                      child: DropdownButtonFormField(
                        hint: Text('Estados'),
                        onSaved: (estado) {
                          _anuncio.estado = estado;
                        },
                        onChanged: (value) {},
                        style: TextStyle(color: Colors.black, fontSize: 20),
                        items: _listaItensDropEstados,
                        validator: (value) {
                          return Validador()
                              .add(Validar.OBRIGATORIO,
                                  msg: 'Campo Obrigat??rio')
                              .valido(value);
                        },
                      ),
                    )),
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.all(8),
                      child: DropdownButtonFormField(
                        hint: Text('Categorias'),
                        onSaved: (categoria) {
                          _anuncio.categoria = categoria;
                        },
                        onChanged: (value) {},
                        style: TextStyle(color: Colors.black, fontSize: 20),
                        items: _listaItensDropCategorias,
                        validator: (value) {
                          return Validador()
                              .add(Validar.OBRIGATORIO,
                                  msg: 'Campo Obrigat??rio')
                              .valido(value);
                        },
                      ),
                    )),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: WidgetTextField(
                    hintText: 'Titulo',
                    onSaved: (titulo) {
                      _anuncio.titulo = titulo;
                    },
                    controller: _controllerTitulo,
                    validador: (value) {
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: 'Campo Obrigat??rio')
                          .valido(value);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: WidgetTextField(
                    hintText: 'Pre??o',
                    onSaved: (preco) {
                      _anuncio.preco = preco;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      RealInputFormatter(centavos: true),
                    ],
                    controller: _controllerpreco,
                    validador: (value) {
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: 'Campo Obrigat??rio')
                          .valido(value);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: WidgetTextField(
                    hintText: 'Telefone',
                    onSaved: (telefone) {
                      _anuncio.telefone = telefone;
                    },
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter(),
                    ],
                    controller: _controllerTelefone,
                    validador: (value) {
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: 'Campo Obrigat??rio')
                          .valido(value);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: WidgetTextField(
                    hintText: 'Descri????o (at?? 200 caracteres)',
                    onSaved: (decricao) {
                      _anuncio.descricao = decricao;
                    },
                    maxLines: null,
                    controller: _controllerDescricao,
                    validador: (value) {
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: 'Campo Obrigat??rio')
                          .maxLength(200, msg: 'M??ximo de 200 caracteres')
                          .valido(value);
                    },
                  ),
                ),
                ButtonCustom(
                  texto: "Cadastrar an??ncio",
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      _dialogContext = context;
                      _salvarAnuncio();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
