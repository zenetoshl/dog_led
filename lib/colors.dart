import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LedColors { red, green, blue }

class ColorsHome extends StatefulWidget {
  ColorsHome({
    this.title,
  });

  final String title;

  ColorsHomeState createState() => ColorsHomeState();
}

class ColorsHomeState extends State<ColorsHome>
    with AutomaticKeepAliveClientMixin<ColorsHome> {
  LedColors color = LedColors.red; //receber da placa
  bool isOn = false; //tambem receber da placa
  bool connected = false; //se está conectado com a placa, default será false
  bool loading = false;
  String deviceId = '';
  final String serviceId = "37f64eb3-c25f-449b-ba34-a5f5387fdb6d";
  final String readCharId = "560d029d-57a1-4ccc-8868-9e4b4ef41da6";
  final String writeCharId = "db433ed3-1e84-49d9-b287-487440e7137c";
  BluetoothCharacteristic readChar;
  BluetoothCharacteristic writeChar;

  void findChar() async {
    if (loading) return;
    setState(() {
      loading = true;
    });
    if (!connected) {
      deviceId = await loadBluetoothId();
      if (deviceId == '') return;
      FlutterBlue.instance
          .scan(scanMode: ScanMode.balanced, timeout: Duration(seconds: 10))
          .listen((scanResult) async {
        BluetoothDevice device = scanResult.device;
        print(device.name);
        if (device.id.toString() == deviceId) {
          await device.connect();
          List<BluetoothService> services = await device.discoverServices();
          services.forEach((s) async {
            if (s.uuid.toString() == serviceId) {
              s.characteristics.forEach((c) async {
                String uid = c.uuid.toString();
                if (uid == writeCharId) {
                  setState(() {
                    writeChar = c;
                  });
                } else if (uid == readCharId) {
                  setState(() {
                    readChar = c;
                  });
                }
                if (writeChar != null && readChar != null) {
                  setState(() {
                    connected = true;
                    loading = false;
                  });
                }
              });
            }
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    findChar();
    Timer(Duration(seconds: 10), () {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: connected
              ? <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    '   Ligar Led',
                    style: Theme.of(context).textTheme.title,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    title: Text(isOn ? 'Ligado!' : 'Desligado!'),
                    leading: new Switch(
                      activeColor: Colors.teal,
                      value: isOn,
                      onChanged: (bool value) {
                        setState(() {
                          isOn = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(
                    color: Colors.grey,
                    indent: 30,
                    endIndent: 30,
                    thickness: 1,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    '   Cores',
                    style: Theme.of(context).textTheme.title,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    title: Text(
                      'Vermelho',
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                    leading: new Radio(
                      activeColor: Colors.red,
                      value: LedColors.red,
                      groupValue: color,
                      onChanged: (LedColors value) {
                        readChar.write([
                          34
                        ]); // teste, favor tirar no futuro, acelera o led no codigo antigo da placa
                        //mandar para a placa
                        setState(() {
                          color = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Verde',
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                    leading: new Radio(
                      activeColor: Colors.green,
                      value: LedColors.green,
                      groupValue: color,
                      onChanged: (LedColors value) {
                        //mandar para a placa
                        setState(() {
                          color = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Azul',
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                    leading: new Radio(
                      activeColor: Colors.blue,
                      value: LedColors.blue,
                      groupValue: color,
                      onChanged: (LedColors value) {
                        readChar.write([
                          35
                        ]); // teste, favor tirar no futuro, acelera o led no codigo antigo da placa
                        //mandar para a placa
                        setState(() {
                          color = value;
                        });
                      },
                    ),
                  ),
                ]
              : <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 200,
                      ),
                      loading
                          ? Center(
                              child: SizedBox(
                                child: SpinKitFoldingCube(
                                  color: Theme.of(context).buttonColor,
                                  size: 40.0,
                                ),
                                height: 54,
                                width: 54,
                              ),
                            )
                          : Center(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    'Falha de conexão!',
                                    style: Theme.of(context).textTheme.display2,
                                  ),
                                  Text(
                                    'Placa não conectada.',
                                    style: Theme.of(context).textTheme.display1,
                                  ),
                                ],
                              ),
                            ),
                    ],
                  )
                ],
        ),
      ),
    );
  }

  Future<String> loadBluetoothId() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'device_id';
    final String newId = prefs.getString(key) ?? '';
    return newId;
  }

  @override
  bool get wantKeepAlive => true;
}
