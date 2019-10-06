import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WifiScreen extends StatefulWidget {
  WifiScreen({
    this.title,
  });

  final String title;

  WifiScreenState createState() => WifiScreenState();
}

class WifiScreenState extends State<WifiScreen> {
  //bluetooth
  bool btConnected = false;
  bool loading = false;
  BluetoothDevice device;
  BluetoothCharacteristic writeCredentialsChar;
  BluetoothCharacteristic readWifiConnectedChar;
  String deviceId = '';
  final String serviceId = '37f64eb3-c25f-449b-ba34-a5f5387fdb6d';
  final String writeCredentialsId = '560d029d-57a1-4ccc-8868-9e4b4ef41da6';
  final String readWifiConnectedId = '13b5c4de-89af-4231-8ec3-b9fe596c10ea';
  final int byteDisconnected = 68;
  final int byteConnected = 67;
  //wifi
  bool wifiConnected = false;
  String wifiSsid = '';
  String wifiPassword = '';

  bool editable = false;
  Latin1Codec latin = new Latin1Codec();

  void toggleEditable() {
    setState(() {
      editable = editable ? false : true;
    });
  }

  void findServices() async {
    if (device == null) return;
    print(device.name);
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((s) async {
      if (s.uuid.toString() == serviceId) {
        s.characteristics.forEach((c) async {
          String uid = c.uuid.toString();
          print(uid);
          if (uid == writeCredentialsId) {
            setState(() {
              writeCredentialsChar = c;
            });
          } else if (uid == readWifiConnectedId) {
            setState(() {
              readWifiConnectedChar = c;
            });
          }
          if (writeCredentialsChar != null && readWifiConnectedChar != null) {
            setState(() {
              btConnected = true;
              loading = false;
            });
          }
        });
      }
    });
  }

  void findDevice() async {
    if (loading) return;
    setState(() {
      loading = true;
    });
    if (!btConnected) {
      deviceId = await loadBluetoothId();
      if (deviceId == '') return;
      var connected = await FlutterBlue.instance.connectedDevices;
      device = connected.firstWhere((e) {
        print(e.id.toString());
        return (e.id.toString() == deviceId);
      }, orElse: () {
        return (null);
      });
      if (device == null) {
        FlutterBlue.instance
            .scan(scanMode: ScanMode.balanced, timeout: Duration(seconds: 10))
            .listen((scanResult) async {
          if (scanResult.device.id.toString() == deviceId) {
            device = scanResult.device;
            await device.connect();
            findServices();
          }
        });
      } else {
        findServices();
        return;
      }
      print("nao foi possivel achar o dispositivo");
    }
  }

  @override
  void initState() {
    super.initState();
    findDevice();
  }

  void disconnect() async {
    if (loading) {
      await FlutterBlue.instance.stopScan();
    }
    if (device != null) {
      print('desconectou');
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: loading
              ? <Widget>[
                  Center(
                    child: SizedBox(
                      child: SpinKitFoldingCube(
                        color: Theme.of(context).buttonColor,
                        size: 30.0,
                      ),
                      height: 41,
                      width: 41,
                    ),
                  ),
                ]
              : <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 200,
                        height: 35,
                        child: TextField(
                          onChanged: (text) {
                            setState(() {
                              wifiSsid = text;
                            });
                          },
                          enabled: editable,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(gapPadding: 6.0),
                            focusColor: Colors.green,
                            labelText: 'SSID',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(editable ? Icons.cancel : Icons.edit),
                        onPressed: toggleEditable,
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 200,
                        height: 35,
                        child: TextField(
                          onChanged: (text) {
                            setState(() {
                              wifiPassword = text;
                            });
                          },
                          enabled: editable,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(gapPadding: 6.0),
                            focusColor: Colors.green,
                            labelText: 'Password',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(editable ? Icons.cancel : Icons.edit),
                        onPressed: toggleEditable,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: (wifiPassword != '' && wifiSsid != '')
                        ? () async {
                            await saveWifiCredentials();
                            await sendCredentials();
                            toggleEditable();
                          }
                        : () {},
                    color: editable ? Colors.blue : Colors.grey,
                  ),
                ],
        ),
      ),
    );
  }

  Future<void> sendCredentials() async {
    await writeCredentialsChar.write((latin.encode('S$wifiSsid')));
    Timer(Duration(milliseconds: 300), () async {
      writeCredentialsChar.write(latin.encode('P$wifiPassword'));
    });
  }

  Future<String> loadBluetoothId() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'device_id';
    final String newId = prefs.getString(key) ?? '';
    return newId;
  }

  Future<void> saveWifiCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final ssidKey = 'wifi_ssid';
    final passwordKey = 'wifi_password';
    print(wifiPassword);
    print(wifiSsid);
    if (wifiSsid != '') prefs.setString(ssidKey, wifiSsid);
    if (wifiPassword != '') prefs.setString(passwordKey, wifiPassword);
  }

  Future<void> loadWifiCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final ssidKey = 'wifi_ssid';
    final passwordKey = 'wifi_password';
    wifiSsid = prefs.getString(ssidKey) ?? '';
    wifiPassword = prefs.getString(passwordKey) ?? '';
  }
}
