import 'package:flutter/material.dart';
import 'package:olx_app/models/usuario.dart';
import 'package:olx_app/widgets/widget_button.dart';
import 'package:olx_app/widgets/widget_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _cadastrar = false;
  String _mesagemErro = '';
  String _textoBotao = 'Entrar';

  TextEditingController _controllerEmail =
      TextEditingController(text: 'alexsandrohonorato@gmail.com');
  TextEditingController _controllerSenha =
      TextEditingController(text: '1234567');

  _cadastraUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  _logarUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth
        .signInWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  _validarCampos() {
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if (email.isNotEmpty && email.contains('@')) {
      if (senha.isNotEmpty && senha.length > 6) {
        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        if (_cadastrar) {
          _cadastraUsuario(usuario);
        } else {
          _logarUsuario(usuario);
        }
      } else {
        setState(() {
          _mesagemErro = 'Preencha a senha! digite mais de 6 caracteres';
        });
      }
    } else {
      setState(() {
        _mesagemErro = 'Preencha o E-mail válido';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(0xff9c27b0),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "images/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                WidgetTextField(
                  controller: _controllerEmail,
                  hintText: 'E-mail',
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: 10,
                ),
                WidgetTextField(
                  controller: _controllerSenha,
                  hintText: 'Senha',
                  obscureText: true,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Logar'),
                    Switch(
                        value: _cadastrar,
                        onChanged: (bool value) {
                          setState(() {
                            _cadastrar = value;
                            _textoBotao = 'Entrar';

                            if (_cadastrar) {
                              _textoBotao = 'Cadastrar';
                            }
                          });
                        }),
                    Text('Cadastrar'),
                  ],
                ),
                ButtonCustom(
                  texto: _textoBotao,
                  onPressed: () {
                    _validarCampos();
                  },
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/");
                    },
                    child: Text("Ir para anúncios")),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    _mesagemErro,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
