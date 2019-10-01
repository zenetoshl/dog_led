import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class BluetoothScreen extends StatefulWidget {
  BluetoothScreen({
    this.title,
  });

  final String title;

  BluetoothScreenState createState() => BluetoothScreenState();
}

class BluetoothScreenState extends State<BluetoothScreen> {
  bool loading = false;
  String id = '';

  void initScan() async {
    if (loading) return;
    setState(() {
      loading = true;
    });
    FlutterBlue.instance
        .startScan(scanMode: ScanMode.balanced, timeout: Duration(seconds: 10));
    Timer(Duration(seconds: 10), () {
      setState(() {
        loading = false;
      });
    });
  }

  Future<void> saveBluetoothId(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'device_id';
    final value = device.id.toString();
    if (value != null) prefs.setString(key, value);
  }

  Future<String> loadBluetoothId() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'device_id';
    final String newId = prefs.getString(key) ?? '';
    return newId;
  }

  void scan() async {
    id = await loadBluetoothId();
    initScan();
  }

  @override
  void initState() {
    super.initState();
    scan();
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
                    title: Text(
                      r.device.name,
                      style: TextStyle(
                        color: (id == r.device.id.toString())
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                    subtitle: Text(r.device.id.toString()),
                    onTap: () async {
                      await saveBluetoothId(r.device);
                      id = await loadBluetoothId();
                      setState(() {
                        id = id;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            loading
                ? Center(
                    child: SizedBox(
                      child: SpinKitFoldingCube(
                        color: Theme.of(context).buttonColor,
                        size: 30.0,
                      ),
                      height: 41,
                      width: 41,
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
