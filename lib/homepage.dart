import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CameraPosition _kGooglePlex = const CameraPosition(
      target: LatLng(23.727150967403755, 90.38139997468986), zoom: 14);
  final Completer<GoogleMapController> _controller = Completer();

  final List<Marker> _marker = [];
  List<Marker> listOfMarker = [
    const Marker(
        markerId: MarkerId("1"),
        position: LatLng(23.727150967403755, 90.38139997468986),
        infoWindow: InfoWindow(title: "My Position")),
    const Marker(
        markerId: MarkerId("2"),
        position: LatLng(20.727150967403755, 70.38139997468986),
        infoWindow: InfoWindow(title: "wohooo!!!"))
  ];
  loadLocation() {
    getCurrentLocation().then((value) async {
      print("my current location: \n${value.latitude} ${value.longitude}");
      _marker.add(Marker(
          markerId: const MarkerId("3"),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: const InfoWindow(title: "Sifat's current location")));

      CameraPosition cmpstn = CameraPosition(
          zoom: 14, target: LatLng(value.latitude, value.longitude));
      GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cmpstn));
      setState(() {});
    });
  }

  Future getCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("Error: $error");
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    loadLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        markers: Set.of(_marker),
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: Container(
        alignment: Alignment.bottomLeft,
        margin: const EdgeInsets.only(left: 30, bottom: 20),
        child: FloatingActionButton(
            child: const Icon(Icons.location_history),
            onPressed: () {
              // GoogleMapController controller = await _controller.future;
              // controller.animateCamera(CameraUpdate.newCameraPosition(
              //   const CameraPosition(
              //       target: LatLng(20.727150967403755, 90.381399977), zoom: 14),
              // ));
              // setState(() {});
            }),
      ),
    );
  }
}
