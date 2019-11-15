import 'package:dog_led/iot_config.dart';
import 'package:flutter/material.dart';
import 'profile.dart';
import 'bluetooth_config.dart';
import 'wifi_config.dart';

class SettingsHome extends StatefulWidget {
  SettingsHome({
    this.title,
  });
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
                    builder: (context) => ProfileScreen(title: 'Perfil')),
              );
            },
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            title: Text('Conexão Bluetooth'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => BluetoothScreen(
                          title: 'Conecte-se a um dispositivo',
                        )),
              );
            },
            trailing: Icon(Icons.chevron_right),
          ),
          
          ListTile(
            title: Text('Cerca digital'),
            onTap: () {Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => IotScreen(
                          title: 'Crie uma nova cerca',
                        )),
              );},
            trailing: Icon(Icons.chevron_right),
          ),
          
          /*ListTile(
            title: Text('WiFi'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => WifiScreen(
                          title: 'Conecte-se a um dispositivo',
                        )),
              );
            },
            trailing: Icon(Icons.chevron_right),
          ),*/
        ],
      ),
    );
  }
}
