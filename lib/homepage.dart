import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  static const CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(23.727150967403755, 90.38139997468986), zoom: 14);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  @override
  void initState() {
    _marker.addAll(listOfMarker);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: MyHomePage._kGooglePlex,
        markers: Set.of(listOfMarker),
        onMapCreated: (controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: Container(
        alignment: Alignment.bottomLeft,
        margin: const EdgeInsets.only(left: 30, bottom: 20),
        child: FloatingActionButton(
            child: Icon(Icons.location_history),
            onPressed: () async {
              GoogleMapController controller = await _controller.future;
              controller.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(20.727150967403755, 70.38139997468986),
                    zoom: 14),
              ));
              setState(() {});
            }),
      ),
    );
  }
}
