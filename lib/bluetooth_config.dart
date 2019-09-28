import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class BluetoothScreen extends StatefulWidget {
  BluetoothScreen({
    this.title,
    BluetoothDevice device,
    BluetoothCharacteristic write,
    BluetoothCharacteristic read,
  });

  final String title;
  BluetoothDevice device;
  BluetoothCharacteristic write;
  BluetoothCharacteristic read;

  BluetoothScreenState createState() => BluetoothScreenState();
}

class BluetoothScreenState extends State<BluetoothScreen> {
  bool loading = false;

  void initScan() async {
    if (loading) return;
    loading = true;
    FlutterBlue.instance
        .startScan(scanMode: ScanMode.balanced, timeout: Duration(seconds: 10));
    Timer(Duration(seconds: 10), () {
      setState(() {
        loading = false;
      });
    });
  }

  void saveBluetoothId(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'device_id';
    final value = device.id.toString();
    if (value != null) prefs.setString(key, value);
  }

  @override
  void initState() {
    super.initState();
    initScan();
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
          children: <Widget>[
            StreamBuilder<List<ScanResult>>(
              stream: FlutterBlue.instance.scanResults,
              initialData: [],
              builder: (c, snapshot) => Column(
                children: snapshot.data.map((r) {
                  return ListTile(
                    title: Text(r.device.name),
                    subtitle: Text(r.device.id.toString()),
                    onTap: () {
                      saveBluetoothId(r.device);
                    },
                  );
                }).toList(),
              ),
            ),
            loading
                ? SpinKitFoldingCube(
                    color: Colors.lightBlue,
                    size: 30.0,
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
