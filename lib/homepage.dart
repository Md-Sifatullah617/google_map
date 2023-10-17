import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController txtController = TextEditingController();
  List placesList = [];
  var uuid = const Uuid();
  String _sessionToken = "1234567890";
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

  void onChange() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }

    getSuggestion(txtController.text);
  }

  getSuggestion(String input) async {
    String googlePlacesapikey = "AIzaSyDQ2c_pOSOFYSjxGMwkFvCVWKjYOM9siow";
    String baseUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String request =
        "$baseUrl?input=$input&key=$googlePlacesapikey&sessiontoken=$_sessionToken";
    var response = await http.get(Uri.parse(request));
    print(response.body.toString());
    if (response.statusCode == 200) {
      setState(() {
        placesList = jsonDecode(response.body.toString())['predictions'];
      });
    } else {
      throw Exception("Failed to load data");
    }
  }

  @override
  void initState() {
    loadLocation();
    txtController.addListener(() {
      onChange();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            markers: Set.of(_marker),
            onMapCreated: (controller) {
              _controller.complete(controller);
            },
          ),
          Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: h * 0.06,
                width: w,
                margin: EdgeInsets.all(
                  h * 0.01,
                ),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: TextFormField(
                  controller: txtController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Enter your location",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                  ),
                  onFieldSubmitted: (value) {},
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: placesList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        tileColor: Colors.white,
                        title: Text(placesList[index]['description']),
                      );
                    }),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: Container(
        alignment: Alignment.bottomLeft,
        margin: const EdgeInsets.only(left: 30, bottom: 20),
        child: FloatingActionButton(
            child: const Icon(Icons.location_history),
            onPressed: () {
              loadLocation();
            }),
      ),
    );
  }
}
