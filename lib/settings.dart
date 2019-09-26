import 'package:flutter/material.dart';
import 'profile.dart';

class SettingsHome extends StatefulWidget {
  SettingsHome({this.title});

  final String title;

  SettingsHomeState createState() => SettingsHomeState();
}

class SettingsHomeState extends State<SettingsHome> {
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
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => ProfileScreen(title:'Perfil')),
              );
            },
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

