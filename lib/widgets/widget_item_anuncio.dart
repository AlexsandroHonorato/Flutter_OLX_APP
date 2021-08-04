import 'package:flutter/material.dart';
import 'package:olx_app/models/anuncio.dart';

class ItemAnuncio extends StatelessWidget {
  final Anuncio anuncio;
  final VoidCallback onTapItem;
  final VoidCallback onPressedRemover;
  const ItemAnuncio(
      {Key key, @required this.anuncio, this.onTapItem, this.onPressedRemover})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTapItem,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Image.network(
                  anuncio.fotos[0],
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        anuncio.titulo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("R\$ ${anuncio.preco}"),
                    ],
                  ),
                ),
              ),
              if (this.onPressedRemover != null)
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: this.onPressedRemover,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(10),
                      primary: Colors.red,
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
