import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsHome extends StatefulWidget {
  MapsHome({this.title});

  final String title;

  MapsHomeState createState() => MapsHomeState();
}

class MapsHomeState extends State<MapsHome>
    with AutomaticKeepAliveClientMixin<MapsHome> {
  Completer<GoogleMapController> _controller = Completer();
  final mark = Marker(
      position: LatLng(37.42796133580664, -122.085749655962),
      markerId: MarkerId('olaa'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
  final Set<Marker> markerSet = new Set();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  Future<void> goToPet() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    setState(() {
      markerSet.add(mark);
    });
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          textAlign: TextAlign.center,
        ),
      ),
      body: GoogleMap(
        markers: markerSet,
        initialCameraPosition: _kGooglePlex,
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

  @override
  bool get wantKeepAlive => true;
}
