import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsHome extends StatefulWidget {
  MapsHome({this.title});

  final String title;

  MapsHomeState createState() => MapsHomeState();
}

class MapsHomeState extends State<MapsHome>
    with AutomaticKeepAliveClientMixin<MapsHome> {
  Completer<GoogleMapController> _controller = Completer();
  var mark = Marker(
      position: LatLng(37.42796133580664, -122.085749655962),
      markerId: MarkerId('Seu pet está aqui'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
  final Set<Marker> markerSet = new Set();
  String title = '<Meu Pet>';
  LocationData petLocation;
  LatLng petLatLng;
  CameraPosition petPos = CameraPosition(
    target: LatLng(-19.885121, -44.418271),
    zoom: 15,
  ); //receber da placa
  Location locationService = new Location();

  Future<void> goToPet() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(petPos));
  }

  //platform configuration
  initPlatformState() async {
    await locationService.changeSettings(
        accuracy: LocationAccuracy.HIGH, interval: 1000);
    bool serviceStatus = await locationService.serviceEnabled();
    if (serviceStatus) {
      bool permission = await locationService.requestPermission();
      if (permission) {
        petLocation = await locationService.getLocation();
        setState(() {
          petPos = CameraPosition(
            target: LatLng(petLocation.latitude, petLocation.longitude),
            zoom: 20,
          );
        });
      }
    }
  }

  void sendLocation() async {
    locationService.onLocationChanged().listen((LocationData result) async {
      petLatLng = LatLng(result.latitude, result.longitude);
      petPos = CameraPosition(
        target: petLatLng,
        zoom: 20,
      );
      setState(() {
        markerSet.add(Marker(
            position: petLatLng,
            markerId: MarkerId('hehe'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue)));
      });
      //enviar para a placa
    });
  }

  @override
  void initState() {
    super.initState();
    _read();
    initPlatformState();
    sendLocation();
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

  _read() async {
        final prefs = await SharedPreferences.getInstance();
        final key = 'saved_name';
        final String newString = prefs.getString(key) ?? '';
        if(newString != '')
        setState(() {
          title = prefs.getString(key);
        });
      }
  @override
  bool get wantKeepAlive => true;
}
