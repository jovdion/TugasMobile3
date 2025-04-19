import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Location _location = Location();
  LatLng _current = LatLng(-7.797068, 110.370529);
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  void _initLocation() async {
    bool _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) _serviceEnabled = await _location.requestService();
    PermissionStatus _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
    }
    if (_permissionGranted == PermissionStatus.granted) {
      _location.onLocationChanged.listen((loc) {
        setState(() => _current = LatLng(loc.latitude!, loc.longitude!));
        _mapController?.animateCamera(CameraUpdate.newLatLng(_current));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tracking LBS')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _current, zoom: 15),
        markers: {Marker(markerId: MarkerId('current'), position: _current)},
        onMapCreated: (c) => _mapController = c,
      ),
    );
  }
}
