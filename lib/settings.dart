import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsHome extends StatefulWidget {
  SettingsHome({this.title});

  final String title;

  SettingsHomeState createState() => SettingsHomeState();
}

class SettingsHomeState extends State<SettingsHome> {
  String newName = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Perfil'),
            onTap: () {/*ir para a pagina do perfil*/},
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: Text('Conexão Bluetooth'),
            onTap: () {/*ir para a pagina de conexão bluetooth*/},
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: Text('Google IoT'),
            onTap: () {/*ir para a pagina de configuração do google IoT*/},
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

/*
Center(
  child: Column(
    children: <Widget>[
      SizedBox(
        height: 100,
      ),
      Row(
        children: <Widget>[
          SizedBox(width: 20,),
          SizedBox(
            width: 200,
            height: 35,
            child: TextField(
              onChanged: (text) {
                setState(() {
                  newName = text;
                });
              },
              enabled: editable,
              decoration: InputDecoration(
                border: OutlineInputBorder(gapPadding: 6.0),
                focusColor: Colors.green,
                labelText: 'Novo Nome',
              ),
            ),
          ),
          IconButton(
            icon: Icon(editable ? Icons.save : Icons.edit),
            onPressed: () {
              if(editable)
                _save();
              setState(() {
                editable = editable ? false : true;
              });
            },
          ),
        ],
      ),
      FlatButton(
        child: Text('Conectar via Bluetooth'),
        onPressed: () {},
      ),
    ],
  ),
),
*/

/*
 _save() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'saved_name';
  final value = newName ?? null;
  if (value != null) prefs.setString(key, value);
}
*/
