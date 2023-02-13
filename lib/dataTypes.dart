import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationCoordinates {
  int id;
  LatLng latLong;
  String name;

  LocationCoordinates(
      {required this.name, required this.id, required this.latLong});
}
