import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'SettingEnvironmentController.dart';
import 'ConnectionProvider.dart';
import 'HomeScreen.dart';

class CompanionWaitMapScreen extends StatefulWidget {
  @override
  _CompanionWaitMapScreenState createState() => _CompanionWaitMapScreenState();
}

class _CompanionWaitMapScreenState extends State<CompanionWaitMapScreen> {
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
          Positioned(
            top: 10,
            right: 10,
            child: ElevatedButton(
              onPressed: () {
                // AlertDialog를 표시합니다.
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('차량 이동 완료 확인'),
                      content: Text('차량 이동을 완료하셨습니까? 이동 완료 사실이 요청자에게 전송됩니다.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('예'),
                          onPressed: () async {
                            //여기서 차량 이동 완료 사실 전송
                            String userID = await connectionProvider.requestIDbyName(SettingEnvironmentController.instance.requestUser);
                            print("11111 $userID");
                            String? token = await connectionProvider.getCompanionToken(userID);
                            connectionProvider.postCompleteMessage(token!);
                            Navigator.of(context).pop(); // AlertDialog를 닫습니다.
                            Navigator.of(context).pop(); // map 닫기
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HomeScreen()),
                            ); // HomeScreen으로 이동합니다.
                          },
                        ),
                        TextButton(
                          child: Text('아니오'),
                          onPressed: () {
                            Navigator.of(context).pop(); // AlertDialog를 닫습니다.
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('차량 이동 완료'),
            ),
          ),
        ],
      ),
    );
  }
}
