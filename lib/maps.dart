import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapsHome extends StatefulWidget {
  MapsHome({this.title});

  final String title;

  MapsHomeState createState() => MapsHomeState();
}

class MapsHomeState extends State<MapsHome> {
  Completer<GoogleMapController> _controller = Completer();
  var mark = Marker(
      position: LatLng(37.42796133580664, -122.085749655962),
      markerId: MarkerId('Seu pet está aqui'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
  final Set<Marker> markerSet = new Set();
  String title = '<Meu Pet>';
  LocationData location;
  LatLng petLatLng;
  LatLng newPetPos;
  bool loading = false;
  bool btConnected = false;

  BluetoothDevice device;
  BluetoothCharacteristic readLatChar;
  BluetoothCharacteristic readLngChar;
  String deviceId = '';
  List<int> lat, lng;

  CameraPosition petPos = CameraPosition(
    target: LatLng(-19.885121, -44.418271),
    zoom: 15,
  );
  Location locationService = new Location();

  Future<void> goToPet() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(petPos));
  }

  //platform configuration
  initPlatformState() async {
    final GoogleMapController controller = await _controller.future;
    await locationService.changeSettings(
        accuracy: LocationAccuracy.HIGH, interval: 1000);
    bool serviceStatus = await locationService.serviceEnabled();
    if (serviceStatus) {
      bool permission = await locationService.requestPermission();
      if (permission) {
        location = await locationService.getLocation();
        setState(() {
          petPos = CameraPosition(
            target: LatLng(location.latitude, location.longitude),
            zoom: 20,
          );
        });
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            new CameraPosition(
                target: LatLng(location.latitude, location.longitude),
                zoom: 15),
          ),
        );
      }
    }
  }

  void sendLocation() async {
    locationService.onLocationChanged().listen((LocationData result) async {
      try {
        Firestore.instance
            .collection('device')
            .document('locations')
            .get()
            .then((DocumentSnapshot ds) {
          List<String> latlngAux = ds.data['location'].toString().split(",");
          newPetPos = new LatLng(
              double.parse(latlngAux.first), double.parse(latlngAux.last));
        });
        petPos = CameraPosition(
          target: newPetPos,
          zoom: 20,
        );
        setState(() {
          markerSet.add(Marker(
              position: newPetPos,
              markerId: MarkerId('your pet'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue)));
        });
      } //enviar para a placa
      catch (err) {
        locationService = null;
      }
    });
  }

 

  @override
  void initState() {
    super.initState();
    _read();
    initPlatformState();
    sendLocation();
  }

  @override
  void dispose() {
    locationService = null;
    super.dispose();
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title,
          textAlign: TextAlign.center,
        ),
      ),
      body: GoogleMap(
        markers: markerSet,
        initialCameraPosition: petPos,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: goToPet,
        label: Text('Ache seu bichinho!'),
        icon: Icon(Icons.pets),
      ),
    );
  }

  Future<String> loadBluetoothId() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'device_id';
    final String newId = prefs.getString(key) ?? '';
    return newId;
  }

  void _read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'saved_name';
    final String newString = prefs.getString(key) ?? '';
    if (newString != '')
      setState(() {
        title = newString;
      });
  }
}
