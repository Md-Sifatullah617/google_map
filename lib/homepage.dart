import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController txtController = TextEditingController();
  final CustomInfoWindowController customInfoCtrl =
      CustomInfoWindowController();
  Set<Polygon> _polygon = HashSet<Polygon>();
  Set<Polyline> _polyline = {};

  List placesList = [];
  List markerIcon = [
    'assets/car.png',
    "assets/delivery-bike.png",
    'assets/flat.png',
    'assets/hook.png',
    'assets/motorbike.png',
    'assets/sport-car.png'
  ];
  List<LatLng> latlong = [
    const LatLng(37.4219983, -122.084),
    const LatLng(38.4219993, -122.094),
    const LatLng(37.4219103, -120.104),
    const LatLng(40.4219150, -122.114),
    const LatLng(42.4219180, -122.124),
    const LatLng(37.4219120, -123.134),
  ];

  var uuid = const Uuid();
  String _sessionToken = "1234567890";
  final CameraPosition _kGooglePlex = const CameraPosition(
      target: LatLng(23.727150967403755, 90.38139997468986), zoom: 14);
  final Completer<GoogleMapController> _controller = Completer();
  Uint8List? markerImage;
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
          markerId: const MarkerId("cl"),
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

  Future getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  loadCustomMarker() async {
    for (int i = 0; i < markerIcon.length; i++) {
      final Uint8List mrkIcon = await getBytesFromAsset(markerIcon[i], 100);
      _marker.add(Marker(
        icon: BitmapDescriptor.fromBytes(mrkIcon),
        markerId: MarkerId(i.toString()),
        position: latlong[i],
        // infoWindow: InfoWindow(title: "position $i"),
        onTap: () {
          customInfoCtrl.addInfoWindow!(
              Container(
                height: 100,
                width: 200,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Expanded(child: Image(image: AssetImage(markerIcon[i]))),
                    const Text("Hi!")
                  ],
                ),
              ),
              latlong[i]);
        },
      ));
      _polyline.add(Polyline(
        polylineId: PolylineId(i.toString()),
        points: latlong,
        color: Colors.yellow,
        width: 2,
      ));
      setState(() {});
    }
  }

  @override
  void initState() {
    loadLocation();
    txtController.addListener(() {
      onChange();
    });
    loadCustomMarker();
    _polygon.add(Polygon(
        polygonId: const PolygonId('1'),
        points: latlong,
        strokeWidth: 2,
        fillColor: Colors.red.withOpacity(0.2)));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
        actions: [
          PopupMenuButton(
              icon: const Icon(Icons.more_horiz),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      _controller.future.then((value) {
                        DefaultAssetBundle.of(context)
                            .loadString("assets/maptheme/silver.json")
                            .then((string) {
                          value.setMapStyle(string);
                        });
                      });
                    },
                    child: const Text("Silveer"),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      _controller.future.then((value) {
                        DefaultAssetBundle.of(context)
                            .loadString("assets/maptheme/retro.json")
                            .then((string) {
                          value.setMapStyle(string);
                        });
                      });
                    },
                    child: const Text("Retro"),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      _controller.future.then((value) {
                        DefaultAssetBundle.of(context)
                            .loadString("assets/maptheme/dark.json")
                            .then((string) {
                          value.setMapStyle(string);
                        });
                      });
                    },
                    child: const Text("Dark"),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      _controller.future.then((value) {
                        DefaultAssetBundle.of(context)
                            .loadString("assets/maptheme/night.json")
                            .then((string) {
                          value.setMapStyle(string);
                        });
                      });
                    },
                    child: const Text("Night"),
                  )
                ];
              })
        ],
      ),
      body: Stack(
        children: [
          Container(
            child: GoogleMap(
              initialCameraPosition: _kGooglePlex,
              markers: Set.of(_marker),
              // polygons: _polygon,
              polylines: _polyline,
              onTap: (argument) {
                customInfoCtrl.hideInfoWindow!();
              },
              onCameraMove: (position) {
                customInfoCtrl.onCameraMove!();
              },
              onMapCreated: (controller) {
                _controller.complete(controller);
                customInfoCtrl.googleMapController = controller;
              },
            ),
          ),
          CustomInfoWindow(controller: customInfoCtrl)
          // Column(
          //   children: [
          //     Container(
          //       alignment: Alignment.center,
          //       height: h * 0.06,
          //       width: w,
          //       margin: EdgeInsets.all(
          //         h * 0.01,
          //       ),
          //       decoration: const BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.all(Radius.circular(20))),
          //       child: TextFormField(
          //         controller: txtController,
          //         style: const TextStyle(
          //           color: Colors.black,
          //           fontSize: 16,
          //           decoration: TextDecoration.none,
          //         ),
          //         decoration: const InputDecoration(
          //           hintText: "Enter your location",
          //           hintStyle: TextStyle(
          //             color: Colors.grey,
          //             fontSize: 16,
          //           ),
          //           border: InputBorder.none,
          //           prefixIcon: Icon(
          //             Icons.search,
          //             color: Colors.grey,
          //           ),
          //         ),
          //         onFieldSubmitted: (value) {},
          //       ),
          //     ),
          //     Expanded(
          //       child: ListView.builder(
          //           itemCount: placesList.length,
          //           itemBuilder: (context, index) {
          //             return Card(
          //               child: ListTile(
          //                 onTap: () async {
          //                   txtController.text =
          //                       placesList[index]['description'];
          //                   print(placesList[index]['description']);
          //                   List locations = await locationFromAddress(
          //                       placesList[index]['description']);
          //                   print(
          //                       "location: ${locations.last.latitude} ${locations.last.longitude}");
          //                   if (txtController.text.toString() ==
          //                       placesList[index]['description']) {
          //                     placesList.clear();
          //                     setState(() {});
          //                   }
          //                 },
          //                 title: Text(placesList[index]['description']),
          //               ),
          //             );
          //           }),
          //     )
          //   ],
          // ),
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
