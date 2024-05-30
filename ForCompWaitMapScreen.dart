import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'SettingEnvironmentController.dart';
import 'ConnectionProvider.dart';

class ForCompWaitMapScreen extends StatefulWidget {
  @override
  _CompanionWaitMapScreenState createState() => _CompanionWaitMapScreenState();
}

class _CompanionWaitMapScreenState extends State<ForCompWaitMapScreen> {
  GoogleMapController? _controller;
  LatLng? _initialPosition;
  final Set<Marker> _markers = {};
  Timer? _timer;
  ConnectionProvider connectionProvider = ConnectionProvider();

  @override
  void initState() {
    super.initState();
    _initializeLocations();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocations() async {
    await _getUserLocation();
    await _getCompanionLocation();
  }

  Future<void> _getUserLocation() async {
    final position = SettingEnvironmentController.instance.currentPosition;
    if (position != null) {
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _updateMarker(_initialPosition!, '내 위치', BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue));
      });
    }
  }

  Future<void> _getCompanionLocation() async {
    String companionName = SettingEnvironmentController.instance.connectedCompanion;
    if (companionName.isNotEmpty) {
      LatLng? companionPosition = await connectionProvider.getCompanionLocationByName(companionName);;
      if (companionPosition != null) {
        setState(() {
          _updateMarker(companionPosition, '동행자 위치', BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
        });
      }
    }
  }

  void _startLocationUpdates() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) async {
      await _initializeLocations();
    });
  }

  void _updateMarker(LatLng position, String markerId, BitmapDescriptor icon) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == markerId);
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: markerId),
          icon: icon,
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Companion Wait Map'),
      ),
      body: Stack(
        children: [
          _initialPosition == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition!,
              zoom: 14.0,
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            myLocationEnabled: false,  // 내 위치 표시를 비활성화
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('내 위치', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      SizedBox(width: 8),
                      Text('동행자 위치', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
