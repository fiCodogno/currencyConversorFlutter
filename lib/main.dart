import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=c7e4f6a2";

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const Home(),
    title: "Conversor de Moedas",
    color: const Color.fromARGB(255, 207, 103, 18),
    theme: ThemeData(
        hintColor: const Color.fromARGB(255, 207, 103, 18),
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 207, 103, 18))),
          hintStyle: TextStyle(color: Color.fromARGB(255, 207, 103, 18)),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  late double dolar;
  late double euro;

  final TextEditingController realController = TextEditingController();
  final TextEditingController dolarController = TextEditingController();
  final TextEditingController euroController = TextEditingController();

  void _clearCurrenciesTextsFields(){
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

  void _realChanged(String valorText) {
    if(valorText.isEmpty){
      _clearCurrenciesTextsFields();
      return;
    }
    double valorReal = double.parse(valorText);
    dolarController.text = (valorReal/dolar).toStringAsFixed(2);
    euroController.text = (valorReal/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String valorText) {
    if(valorText.isEmpty){
      _clearCurrenciesTextsFields();
      return;
    }
    double valorDolar = double.parse(valorText);
    realController.text = (valorDolar * this.dolar).toStringAsFixed(2);
    euroController.text = (valorDolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String valorText) {
    if(valorText.isEmpty){
      _clearCurrenciesTextsFields();
      return;
    }
    double valorEuro = double.parse(valorText);
    dolarController.text = (valorEuro * this.euro / dolar).toStringAsFixed(2);
    realController.text = (valorEuro * this.euro).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Conversor de Moedas",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color.fromARGB(255, 207, 103, 18),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(color: Color.fromARGB(255, 207, 103, 18), fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              );

            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao carregar os dados!",
                    style:
                        TextStyle(color: Color.fromARGB(255, 207, 103, 18), fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on_outlined,
                        color: Color.fromARGB(255, 207, 103, 18),
                        size: 150,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      buildCurrencyTextField("BRL", "R\$", realController, _realChanged),
                      const SizedBox(
                        height: 20,
                      ),
                      buildCurrencyTextField("USD", "US\$", dolarController, _dolarChanged),
                      const SizedBox(
                        height: 20,
                      ),
                      buildCurrencyTextField("EUR", "€", euroController, _euroChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildCurrencyTextField(String label, String prefix,
    TextEditingController controller, Function(String) convert) {
  return TextField(
    onChanged: convert,
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    cursorColor: const Color.fromARGB(255, 207, 103, 18),
    decoration: InputDecoration(
        prefixText: "$prefix  ",
        labelText: label,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 207, 103, 18), fontSize: 25),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 207, 103, 18), width: 2))),
    style: const TextStyle(color: Color.fromARGB(255, 207, 103, 18), fontSize: 25),
  );
}
