import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:proto/WatingScreen.dart';
import 'ConnectionProvider.dart';
import 'package:geolocator/geolocator.dart';
import 'SettingEnvironmentController.dart';
import 'SetCompleteTime.dart';

class CompanionSelectScreen extends StatefulWidget {
  @override
  _CompanionSelectScreenState createState() => _CompanionSelectScreenState();
}

class _CompanionSelectScreenState extends State<CompanionSelectScreen> {
  final ConnectionProvider connectionProvider = ConnectionProvider();
  List<Map<String, dynamic>> companionLocationList = [];
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if(SettingEnvironmentController.instance.shareGPS) {
      await _getCurrentLocation();
      await _fetchCompanionsLocations();
      _sortCompanionsByDistance();
      // _fcmToken = await _firebaseMessaging.getToken();
      setState(() {});
    }
    else{
      await _fetchCompanionsLocations();
      _sortCompanionsByDistance();
      // _fcmToken = await _firebaseMessaging.getToken();
      setState(() {});
    }
  }

  Future<void> _getCurrentLocation() async {
    currentPosition = SettingEnvironmentController.instance.currentPosition;
  }

  Future<void> _fetchCompanionsLocations() async {
    companionLocationList = await connectionProvider.fetchCompanionsLocations();
  }

  void _sortCompanionsByDistance() {
    if (currentPosition != null) {
      companionLocationList.sort((a, b) {
        final positionA = a['Position'] as Position;
        final positionB = b['Position'] as Position;
        final distanceA = _calculateDistance(currentPosition!, positionA);
        final distanceB = _calculateDistance(currentPosition!, positionB);
        return distanceA.compareTo(distanceB);
      });
    }
  }

  double _calculateDistance(Position start, Position end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  double _calculateWalkingTime(double distanceMeters) {
    const double walkingSpeedMetersPerSecond = 4 * 1000 / 3600; // 4 km/h in meters per second
    return distanceMeters / walkingSpeedMetersPerSecond / 60; // return time in minutes
  }

  void _onCompanionTap(Map<String, dynamic> companion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('동행자 선택'),
          content: Text('${companion['UserName']}을(를) 선택하시겠습니까? 동행 요청이 전송됩니다.'),
          actions: <Widget>[
            TextButton(
              child: Text('예'),
              onPressed: () async {
                if (companion['UserId'] == null) {
                  print(SettingEnvironmentController.instance.companionMap[companion['UserName']]);
                }
                String? token = await connectionProvider.getCompanionToken(
                  SettingEnvironmentController.instance.companionMap[companion['UserName']]
                );
                if (token != null) {
                  connectionProvider.postMessage(token);
                } else {
                  print('Failed to retrieve FCM token.');
                }
                SettingEnvironmentController.instance.updateConnectedCompanion(SettingEnvironmentController.instance.companionMap[companion['UserName']]!);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  WaitingScreen()),
                );
              },
            ),
            TextButton(
              child: Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Companion Select Screen')),
      body:
      Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: companionLocationList.length,
              itemBuilder: (context, index) {
                final companion = companionLocationList[index];
                if(!SettingEnvironmentController.instance.shareGPS){
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      title: Text(
                        '${companion['UserName']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('위치 정보 공유 기능이 비활성화 되어있습니다.'),
                      onTap: () => _onCompanionTap(companion),
                    ),
                  );
                }
                else {
                  final position = companion['Position'] as Position;
                  final distance = _calculateDistance(currentPosition!, position).toInt();
                  final walkingTime = _calculateWalkingTime(_calculateDistance(currentPosition!, position)).toInt(); // calculate walking time in minutes
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      title: Text(
                        '${companion['UserName']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('거리: ${distance
                          .toString()} 미터,\n예상 소요 시간: ${walkingTime
                          .toString()}분'),
                      onTap: () => _onCompanionTap(companion),
                    ),
                  );
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('동행자 미선택'),
                      content: Text('동행자를 선택하지 않으시겠습니까?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('예'),
                          onPressed: () {
                            SettingEnvironmentController.instance.updateConnectedCompanion("");
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SetCompleteTime()),
                            );
                          },
                        ),
                        TextButton(
                          child: Text('아니오'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 대화 상자를 닫습니다.
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('동행자 선택하지 않기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}