import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WidgetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool autofocus;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final int maxLines;
  final Function(String) validador;
  final Function(String) onSaved;

  const WidgetTextField(
      {Key key,
      @required this.controller,
      @required this.hintText,
      this.obscureText = false,
      this.autofocus = false,
      this.keyboardType = TextInputType.text,
      this.inputFormatters,
      this.maxLines = 1,
      this.validador,
      this.onSaved})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: this.controller,
      obscureText: this.obscureText,
      autofocus: this.autofocus,
      keyboardType: this.keyboardType,
      inputFormatters: this.inputFormatters,
      validator: this.validador,
      maxLines: this.maxLines,
      onSaved: this.onSaved,
      style: TextStyle(
        fontSize: 20,
      ),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          )),
    );
  }
}
