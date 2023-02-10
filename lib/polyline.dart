import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Poly extends StatefulWidget {
  @override
  _PolyState createState() => _PolyState();
}

class _PolyState extends State<Poly> {
  int _polylineCount = 1;
  Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};

  GoogleMapPolyline _googleMapPolyline = GoogleMapPolyline(
    apiKey: "AIzaSyDHCbgMAU-KzqFmI8LtrG4DWepIm7mAJJM",
  );

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

  LatLng _mapInitLocation = LatLng(23.5633973, 87.0907071);

  LatLng _originLocation = LatLng(23.5633973, 87.0907071);
  LatLng _destinationLocation = LatLng(23.5659506, 87.0863055);

  bool _loading = false;

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    // setMapPins();
    // setState(() {});
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Set<Marker> _markers = {};

  //Get polyline with Location (latitude and longitude)
  _getPolylinesWithLocation() async {
    _setLoadingMenu(true);
    List<LatLng>? _coordinates =
        await _googleMapPolyline.getCoordinatesWithLocation(
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

  static const CameraPosition _kLake = CameraPosition(
    bearing: 30.0,
    tilt: 50.0,
    target: LatLng(23.5659506, 87.0907071),
    zoom: 16.12,
  );

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  //Get polyline with Address
  _getPolylinesWithAddress() async {
    _setLoadingMenu(true);
    List<LatLng>? _coordinates =
        await _googleMapPolyline.getPolylineCoordinatesWithAddress(
      origin: '55 Kingston Ave, Brooklyn, NY 11213, USA',
      destination: '8007 Cypress Ave, Glendale, NY 11385, USA',
      mode: RouteMode.driving,
    );

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

  _setLoadingMenu(bool _status) {
    setState(() {
      _loading = _status;
    });
  }

  void setMapPins() {
    setState(() {
      // source pin
      _markers.add(
        Marker(
          markerId: const MarkerId('sourcePin'),
          position: LatLng(23.5633973, 87.0907071),
          icon: BitmapDescriptor.defaultMarkerWithHue(20.0),
        ),
      );
      // destination pin
      _markers.add(
        Marker(
          markerId: const MarkerId('destinationPin'),
          position: LatLng(23.5659506, 87.0863055),
          icon: BitmapDescriptor.defaultMarkerWithHue(10.0),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Map Polyline'),
          backgroundColor: Colors.pink,
        ),
        body: Container(
          child: LayoutBuilder(
            builder: (context, cont) {
              return Column(
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 175,
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
                            child: Text('Polylines with Location'),
                          ),
                          ElevatedButton(
                            onPressed: _getPolylinesWithAddress,
                            child: Text('Polylines with Address'),
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
                child: Center(
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
}
