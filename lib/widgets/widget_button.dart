import 'package:flutter/material.dart';

class ButtonCustom extends StatelessWidget {
  final String texto;
  final Color corTexto;
  final VoidCallback onPressed;

  const ButtonCustom(
      {Key key,
      @required this.texto,
      this.corTexto = Colors.white,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: this.onPressed,
      child: Text(
        this.texto,
        style: TextStyle(
          color: corTexto,
          fontSize: 20,
        ),
      ),
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          primary: Color(0xff9c27b0),
          padding: EdgeInsets.fromLTRB(31, 16, 31, 16)),
    );
  }
}
