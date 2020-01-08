import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todo/models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To do APP',
      debugShowCheckedModeBanner: false, //para tirar a marca escrito debug
      theme: ThemeData(primarySwatch: Colors.pink),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var itens = new List<Item>();

  HomePage() {
    itens = [];
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl =
      TextEditingController(); //controlador do texto, para controlar o textfield

  void add() {
    if (newTaskCtrl.text.isEmpty) return;
    setState(() {
      widget.itens.add(Item(
        title: newTaskCtrl.text,
        done: false,
      ));
      newTaskCtrl.clear();
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.itens.removeAt(index);
      save();
    });
  }

  Future load() async {
    // assincrona porque não recupera as informações em tempo real
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded
          .map((x) => Item.fromJson(x))
          .toList(); //map percorre os itens, essa linha é como um forit
      setState(() {
        widget.itens = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.itens));
  }

  _HomePageState() {
    //toda vez que inicializar a aplicação vai chamar o load, usa aqui para não ficar dando load toda vez que da um bild
    load();
  }

  @override
  Widget build(BuildContext context) {
    // não vai fazer as coisas aqui pq toda vez q chamar perco tudo
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          //campo de texto
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            labelText: "Nova Tarefa",
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.itens.length,
        itemBuilder: (BuildContext ctxt, int index) {
          final item = widget.itens[index];
          return Dismissible(
              child: CheckboxListTile(
                title: Text(item.title),
                value: item.done,
                onChanged: (value) {
                  setState(() {
                    // atualiza os itens mudados na tela
                    item.done = value;
                    save();
                  });
                },
              ),
              key: Key(item.title),
              background: Container(
                color: Colors.pink[100],
              ),
              onDismissed: (direction) {
                remove(index);
                save();
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
