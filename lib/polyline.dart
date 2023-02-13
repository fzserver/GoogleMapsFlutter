import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/TextFieldWithDropDown.dart';

class Poly extends StatefulWidget {
  @override
  _PolyState createState() => _PolyState();
}

class _PolyState extends State<Poly> {
  int _polylineCount = 1;
  final Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};

  final GoogleMapPolyline _googleMapPolyline = GoogleMapPolyline(
    apiKey: "AIzaSyDHCbgMAU-KzqFmI8LtrG4DWepIm7mAJJM",
  );

  final TextEditingController _fromController = TextEditingController(),
      _toController = TextEditingController();

  //Polyline patterns
  List<List<PatternItem>> patterns = <List<PatternItem>>[
    <PatternItem>[], //line
    <PatternItem>[PatternItem.dash(30.0), PatternItem.gap(20.0)], //dash
    <PatternItem>[PatternItem.dot, PatternItem.gap(10.0)], //dot
    <PatternItem>[
      //dash-dot
      PatternItem.dash(30.0),
      PatternItem.gap(20.0),
      PatternItem.dot,
      PatternItem.gap(20.0)
    ],
  ];

  List<LatLng>? _coordinates;
  static late CameraPosition _kLake;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final Set<Marker> _markers = {};

  final LatLng _mapInitLocation = const LatLng(23.5633973, 87.0907071);
  final LatLng _originLocation = const LatLng(23.5633973, 87.0907071);
  final LatLng _destinationLocation = const LatLng(23.5659506, 87.0863055);

  bool _loading = false;

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    // setMapPins();
    // setState(() {});
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  //Get polyline with Location (latitude and longitude)
  _getPolylinesWithLocation() async {
    _setLoadingMenu(true);
    _coordinates = await _googleMapPolyline.getCoordinatesWithLocation(
      origin: _originLocation,
      destination: _destinationLocation,
      mode: RouteMode.walking,
    );

    setMapPins();
    setState(() {
      _polylines.clear();
    });

    _goToTheLake();

    _addPolyline(_coordinates);
    _setLoadingMenu(false);
  }

  //Get polyline with Address
  _getPolylinesWithAddress() async {
    _setLoadingMenu(true);

    if (_fromController.text.isNotEmpty && _toController.text.isNotEmpty) {
      if (_fromController.text == 'Current Location') {
        Position position = await _determinePosition();
        _coordinates =
            await _googleMapPolyline.getPolylineCoordinatesWithAddress(
          origin: 'Delhi',
          destination: _toController.text,
          mode: RouteMode.driving,
        );

        _coordinates = await _googleMapPolyline.getCoordinatesWithLocation(
          origin: LatLng(position.latitude, position.longitude),
          destination: _coordinates![_coordinates!.length - 1],
          mode: RouteMode.walking,
        );
        _goToTheLake();
      } else {
        _coordinates =
            await _googleMapPolyline.getPolylineCoordinatesWithAddress(
          origin: _fromController.text,
          destination: _toController.text,
          mode: RouteMode.driving,
        );
        _goToTheLake();
      }
    } else {
      _coordinates = await _googleMapPolyline.getPolylineCoordinatesWithAddress(
        origin: '55 Kingston Ave, Brooklyn, NY 11213, USA',
        destination: '8007 Cypress Ave, Glendale, NY 11385, USA',
        mode: RouteMode.driving,
      );
    }
    setMapPins();
    setState(() {
      _polylines.clear();
    });

    _addPolyline(_coordinates);
    _setLoadingMenu(false);
  }

  _addPolyline(List<LatLng>? _coordinates) {
    PolylineId id = PolylineId("poly$_polylineCount");
    Polyline polyline = Polyline(
      polylineId: id,
      patterns: patterns[0],
      color: Colors.pink,
      points: _coordinates!,
      width: 10,
      onTap: () {},
    );

    setState(() {
      _polylines[id] = polyline;
      _polylineCount++;
    });
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  _setLoadingMenu(bool _status) {
    setState(() {
      _loading = _status;
    });
  }

  void setMapPins() {
    if (_coordinates!.isNotEmpty) {
      setState(() {
        // source pin
        _markers.add(
          Marker(
            markerId: const MarkerId('sourcePin'),
            position: _coordinates![0],
            icon: BitmapDescriptor.defaultMarkerWithHue(20.0),
          ),
        );
        // destination pin
        _markers.add(
          Marker(
            markerId: const MarkerId('destinationPin'),
            position: _coordinates![_coordinates!.length - 1],
            icon: BitmapDescriptor.defaultMarkerWithHue(10.0),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _kLake = CameraPosition(
      bearing: 30.0,
      tilt: 50.0,
      target: _coordinates?[0] ?? const LatLng(23.5659506, 87.0907071),
      zoom: 16.12,
    );

    return MaterialApp(
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Map Polyline'),
        //   backgroundColor: Colors.pink,
        // ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, cont) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextFieldWithDropDown(
                    controller: _fromController,
                    options: const ['Current Location'],
                    placeholder: 'From',
                  ),
                  textField(placeholder: 'To', controller: _toController),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 240,
                    child: GoogleMap(
                      myLocationEnabled: true,
                      compassEnabled: true,
                      onMapCreated: _onMapCreated,
                      markers: _markers,
                      polylines: Set<Polyline>.of(_polylines.values),
                      initialCameraPosition: CameraPosition(
                        bearing: 0.0,
                        tilt: 0.0,
                        target: _mapInitLocation,
                        zoom: 17.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: _getPolylinesWithLocation,
                            child: const Text('Polylines with Location'),
                          ),
                          ElevatedButton(
                            onPressed: _getPolylinesWithAddress,
                            child: const Text('Polylines with Address'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _loading
            ? Container(
                color: Colors.black.withOpacity(0.75),
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            : Container(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget textField({
    required placeholder,
    required TextEditingController controller,
  }) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: placeholder,
        ),
      ),
    );
  }
}
