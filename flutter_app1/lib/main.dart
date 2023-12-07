import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
void main() {
  runApp( const TelaPrincipal() );
}


class Contato {
  String nome = "";
  String telefone = "";
  String email = "";
}


class Contador extends StatefulWidget {
  const Contador({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ContadorState();
  }
}

class _ContadorState extends State<Contador> {

  int contador = 0;

  @override
  Widget build(BuildContext buildContext) {
    return Column(
        children: [
          Text("Contador: $contador"),
          TextButton(
              onPressed: (){
                setState(() {
                  contador += 1;
                });
              },
              child: const Text("Incrementar")
          ),
          TextButton(
              onPressed: (){
                setState(() {
                  contador -= 1;
                });
              },
              child: const Text("Decrementar")
          )
        ]
    );
  }
}



class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TelaPrincipal();
  }
}


class _TelaPrincipal extends State<TelaPrincipal> {

  List<Contato> contatos = [];
  TextEditingController nomeController = TextEditingController();
  TextEditingController telefoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  void salvar() async {
    print("Botão Salvar acionado");
    var client = http.Client();
    try {
      var response = await client.post(
          Uri.https('fds-senac-mobile-default-rtdb.firebaseio.com', 'contatos.json'),
          body: {
            "nome": nomeController.text,
            "telefone": telefoneController.text,
            "email": emailController.text
          }
      );
      print(response.body);
    } finally {
      client.close();
    }
  }

  void lerDados() async {
    print("Botão lerDados acionado");
    var client = http.Client();
    try {
      var response = await client.get(
        Uri.https('fds-senac-mobile-default-rtdb.firebaseio.com', 'contatos.json'),
      );
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      // print("Body: ${response.body}");
      print("Body ***: ${decodedResponse.keys}");
      contatos.clear();
      for(var key in decodedResponse.keys) {
        print("Lendo a Key: $key");
        var item = decodedResponse[key];
        print("Lendo o Item: $item");

        var contato = Contato(item["nome"], item["telefone"], item["email"]);
        print("Decodificando o contato: $contato");
        contatos.add(contato);
      }
    } finally {
      client.close();
    }
  }

  Widget listagem() {
    return Expanded(
      child: ListView(
        children: contatos.map( (item) {
          return Column(children: [
            Text("Nome: ${item.nome}"),
            Text("Telefone: ${item.telefone}"),
            Text("Email: ${item.email}")
          ]);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Agenda de Contatos",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(title: const Text("Agenda de Contatos")),
          body: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Nome Completo: "),
                  ),
                  controller: nomeController,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.blue),
                        left: BorderSide(color: Colors.red),
                        right: BorderSide(),
                        bottom: BorderSide(),
                      ),
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Telefone: "),
                      ),
                      controller: telefoneController,
                    ),
                  ),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Email: "),
                  ),
                  controller: emailController,
                ),
                FloatingActionButton(
                    onPressed: (){

                      print("Botão Add Apertado");
                      Contato c = Contato();
                      c.nome = nomeController.text;
                      c.telefone = telefoneController.text;
                      c.email = emailController.text;
                      setState(() {
                        contatos.add(c);
                      });
                      salvar();
                      print("Tamanho da lista: ${contatos.length}");
                    },
                    child: const Text("Add")
                ),
                listagem()
              ]
          ),
        )
    );
  }
}
