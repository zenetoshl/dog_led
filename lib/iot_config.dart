import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IotScreen extends StatefulWidget {
  IotScreen({
    this.title,
  });

  final String title;

  IotScreenState createState() => IotScreenState();
}

class IotScreenState extends State<IotScreen> {
  List _distances = ["100m", "200m", "500m", "1km", "2km"];
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentDistance;
  int distance;
  String email = '';
  String address = '';
  String pais = '';
  String estado = '';
  String cidade = '';
  String bairro = '';
  String rua = '';
  int numero;

  Geolocator geolocator = Geolocator();
  Position userLocation;
  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    _currentDistance = _dropDownMenuItems[0].value;
    loadConfig();
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in _distances) {
      items.add(new DropdownMenuItem(value: city, child: new Text(city)));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: new Container(
          margin: new EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Seu E-mail:'),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, labelText: 'E-mail'),
                onChanged: (String t) {
                  setState(() {
                    email = t;
                  });
                },
              ),
              Divider(
                color: Colors.grey,
                indent: 30,
                endIndent: 30,
                thickness: 1,
              ),
              Text('Endereço:'),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, labelText: 'País'),
                onChanged: (String t) {
                  setState(() {
                    pais = t;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, labelText: 'Estado'),
                onChanged: (String t) {
                  setState(() {
                    estado = t;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, labelText: 'Cidade'),
                onChanged: (String t) {
                  setState(() {
                    cidade = t;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, labelText: 'Bairro'),
                onChanged: (String t) {
                  setState(() {
                    bairro = t;
                  });
                },
              ),
              TextField(
                decoration:
                    InputDecoration(border: InputBorder.none, labelText: 'Rua'),
                onChanged: (String t) {
                  setState(() {
                    rua = t;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, labelText: 'Número'),
                onChanged: (String n) {
                  setState(() {
                    numero = int.parse(n);
                  });
                },
                keyboardType: TextInputType.number,
              ),
              Divider(
                color: Colors.grey,
                indent: 30,
                endIndent: 30,
                thickness: 1,
              ),
              Text('Distância permitida:'),
              DropdownButton(
                value: _currentDistance,
                items: _dropDownMenuItems,
                onChanged: changedDropDownItem,
              ),
              Center(
                child: FlatButton(
                  child: Text('Enviar'),
                  onPressed: (email != '' &&
                          pais != '' &&
                          estado != '' &&
                          cidade != '' &&
                          bairro != '' &&
                          rua != '' &&
                          numero != null)
                      ? sendInfos
                      : null,
                ),
              ),
            ],
          )),
        ));
  }

  void sendInfos() async {
    address = '$rua $numero, $bairro, $cidade, $estado, $pais';
    distance = _currentDistance == '100m'
        ? 100
        : _currentDistance == '200m'
            ? 200
            : _currentDistance == '500m'
                ? 500
                : _currentDistance == '1km' ? 1000 : 2000;
    List<Placemark> placemark = await geolocator.placemarkFromAddress(address);
    Position center = placemark[0].position;

    print(center.toString());
    await Firestore.instance.collection('device').document('config').setData({
      'distance': distance,
      'center': '${center.latitude} , ${center.longitude}',
      'email': email,
    });
    Navigator.pop(context);
  }

  void changedDropDownItem(String selectedDistance) {
    setState(() {
      _currentDistance = selectedDistance;
    });
  }

  Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final addressKey = 'address_key';
    final distanceKey = 'distance_key';
    print(distance);
    print(address);
    if (address != '') prefs.setString(addressKey, address);
    if (distance != null) prefs.setInt(distanceKey, distance);
  }

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final addressKey = 'wifi_ssid';
    final distanceKey = 'wifi_password';
    address = prefs.getString(addressKey) ?? '';
    distance = prefs.getInt(distanceKey) ?? '';
  }
}
