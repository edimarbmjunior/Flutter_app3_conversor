import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const urlAPI =
    "http://data.fixer.io/api/latest?access_key=e4247c41c64d8bf8f17c5c9fb5bc9019";
const urlMoedaBase = "&base=";
const urlfinal = "&format=1";

void main() async {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white)
          ),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber)
          ),
          hintStyle: TextStyle(
              color: Colors.amber
          ),
        ),
      )));
  }

Future<Map> getData() async {
  http.Response response = await http.get(urlAPI + urlfinal);
  var jsonResposta = json.decode(response.body);
  // print(jsonResposta["rates"]["BRL"]); -> 6.28 Em relação ao Euro
  return jsonResposta;
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolarRecebido;
  double euroRecebido;
  double realRecebido;
  String _INFO = "";
  NumberFormat formatter = NumberFormat("00.00");

  void _realChanged(String textReal){
    atualizacaoTela("", 4);
    try{
      double real = double.parse(textReal);
      dolarController.text = formatter.format(real/dolarRecebido).toString();
      euroController.text = formatter.format(real/euroRecebido).toString();
    } catch(eXception) {
        atualizacaoTela("Não foi possível fazer a conversão!", 4);
    }
  }
  void _dolarChanged(String textDolar){
    atualizacaoTela("", 4);
    try{
      double dolar = double.parse(textDolar);
      realController.text = formatter.format(dolar * this.dolarRecebido).toString();
      euroController.text = formatter.format(dolar * this.dolarRecebido / euroRecebido).toString();
    } catch(eXception) {
      atualizacaoTela("Não foi possível fazer a conversão!", 4);
    }
  }
  void _euroChanged(String textEuro){
    atualizacaoTela("", 4);
    try{
      double euro = double.parse(textEuro);
      realController.text = formatter.format(euro * this.euroRecebido).toString();
      dolarController.text = formatter.format(euro * this.euroRecebido / dolarRecebido).toString();
    } catch(eXception) {
      atualizacaoTela("Não foi possível fazer a conversão!", 4);
    }
  }
  void atualizacaoTela(String text, int posicaoAtualizada){
    setState(() {
      switch(posicaoAtualizada){
        case 1:
          _INFO = "Pegou a informação!";
          break;
        case 2:
          _INFO = "Pegou a informação!";
          break;
        case 3:
          _INFO = "Pegou a informação!";
          break;
        case 4:
          _INFO = text;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder(
        // Aqui será para fazer uma tela de espera enquanto não houver resposta do "getData()"
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error ao carregar dados :(",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  realRecebido = 1.0;
                  euroRecebido = snapshot.data["rates"]["BRL"];
                  dolarRecebido =
                      snapshot.data["rates"]["BRL"] / snapshot.data["rates"]["USD"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        buildTextField("Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField("Dólares", "US\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField("Euros", "€", euroController, _euroChanged),
                        Divider(),
                        Text(
                          "$_INFO",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 25.0),
                        ),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController textEditingController, Function function) {
  return TextField(
    controller: textEditingController,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
        color: Colors.amber,
        fontSize: 25.0
    ),
    onSubmitted: function,
    // onChanged: function,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}