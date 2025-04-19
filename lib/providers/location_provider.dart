import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider extends ChangeNotifier {
  final Location _location = Location();
  LatLng _current = LatLng(-7.797068, 110.370529);
  
  LatLng get current => _current;

  LocationProvider() {
    _init();
  }

  Future<void> _init() async {
    if (!await _location.serviceEnabled()) {
      await _location.requestService();
    }
    if (await _location.hasPermission() == PermissionStatus.denied) {
      await _location.requestPermission();
    }
    _location.onLocationChanged.listen((loc) {
      if (loc.latitude != null && loc.longitude != null) {
        _current = LatLng(loc.latitude!, loc.longitude!);
        notifyListeners();
      }
    });
  }
}
