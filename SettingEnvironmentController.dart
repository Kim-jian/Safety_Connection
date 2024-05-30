import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:proto/Crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'ConnectionProvider.dart';

class SettingEnvironmentController extends ChangeNotifier {
  static SettingEnvironmentController? _instance;

  SettingEnvironmentController._internal() {
    _companionList.clear();
    loadInitialSettings();
    _startLocationUpdates();
    _loginStatus = false;
  }

  static SettingEnvironmentController get instance {
    _instance ??= SettingEnvironmentController._internal();
    return _instance!;
  }

  ConnectionProvider connectionProvider = ConnectionProvider();
  final Map<String, String> _companionList = {'': ''};
  bool _shareGPS = true;
  Position? _currentPosition;
  Timer? _locationUpdateTimer;
  String _userID = "";
  String _connectedCompanion = "";
  bool _loginStatus = false;
  String _pushKey ="";
  bool _isPK = false;
  String _userName ="";
  String _refreshToken = "";
  String _accessToken = "";
  String _requestUser = "";
  bool _updatedListener = false;
  StreamSubscription<RemoteMessage>? _messageSubscription;

  List<MapEntry<String,String>> get companionList => _companionList.entries.toList();
  Map<String, String> get companionMap => _companionList;
  bool get shareGPS => _shareGPS;
  Position? get currentPosition => _currentPosition;
  String get userID => _userID;
  String get connectedCompanion => _connectedCompanion;
  bool get loginStatus => _loginStatus;
  String get pushKey => _pushKey;
  String get refreshToken => _refreshToken;
  String get accessToken => _accessToken;
  String get userName => _userName;
  String get requestUser => _requestUser;
  bool get updatedListner => _updatedListener;

  Future<void> saveSettings(String key, dynamic value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else {
      print("Invalid type");
    }
  }

  Future<void> loadMap() async {
    String comp_Info = await connectionProvider.getAllCompanions();
    if (comp_Info == "") {
      print("연락처 동기화 중 오류 발생.");
    } else {
      print(comp_Info);
      List<String> companions = comp_Info.split('Companion');

      for (String companion in companions) {
        if (companion.isNotEmpty) {
          final userNameRegex = RegExp(r"compUserName=\'([^\']+)\'");

          final userNameMatch = userNameRegex.firstMatch(companion);

          if (userNameMatch != null) {
            final String userId = userNameMatch.group(1)!;
            String userName = await connectionProvider.sendSearchRequest(userId);
            userName = userName.replaceAll("User Name: ", "");
            String trueUserName = decryptData(userName, aeskey);
            _companionList[trueUserName] = userId;
          }
        }
      }
      // Now _companionList contains the parsed data
      print(_companionList); // For debugging purposes
    }
  }

  void updateCompList(String name, String userid) {
    _companionList[name] = userid;
    notifyListeners();
  }


  void updateAccessToken(String newToken){
    _accessToken = newToken;
    notifyListeners();
  }

  void updateRequestUser(String newUser){
    _requestUser = newUser;
    print("request User : ${_requestUser}");
    saveSettings("requestUser", _requestUser);
    notifyListeners();
  }

  void updateListener(){
    _updatedListener = true;
    notifyListeners();
  }

  void deleteCompList(String name) {
    _companionList.remove(name);
    notifyListeners();
  }

  void updateShareGPS() {
    _shareGPS = !_shareGPS;
    saveSettings('shareGPS', _shareGPS);
    updateLocation();
    _startLocationUpdates();
    notifyListeners();
  }


  void updateConnectedCompanion(String newCompanion){
    _connectedCompanion = newCompanion;
    print("updated Connected Companion: ${newCompanion}");
    notifyListeners();
  }


  Future<void> updatePK(String newPK) async {
    _pushKey = newPK;
    _isPK = true;
    await saveSettings('pushKey', _pushKey);
    await saveSettings('isPK', _isPK);
    print("updated Push Key : $newPK");
    await connectionProvider.sendTokenToServer(_userID, _pushKey);
    notifyListeners();
  }


  Future<void> loadInitialSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _shareGPS = prefs.getBool('shareGPS') ?? _shareGPS;
    _loginStatus = prefs.getBool('loginStatus') ?? _loginStatus;
    _userID = prefs.getString('userID') ?? _userID;
    _pushKey = prefs.getString('pushKey') ?? _pushKey;
    _isPK = prefs.getBool('isPK') ?? _isPK;
    _userName = prefs.getString('userName') ?? _userName;
    _requestUser = prefs.getString('requestUser')??_requestUser;
    if(_userID != ""){
      await loadMap();
    }
    notifyListeners();
  }


  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue accessing the position
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, don't continue accessing the position
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    _currentPosition = await Geolocator.getCurrentPosition();
  }

  Future<void> updateLocation() async {
    await _getCurrentLocation();
    await connectionProvider.sendLocationToServer(); // 위치 정보 업데이트 후 서버로 전송
    notifyListeners();
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if(_loginStatus) {
        if (_shareGPS) {
          updateLocation();
          print("updated location complete. longitude : ${_currentPosition
              ?.longitude.toString()}, latitude : ${_currentPosition?.latitude
              .toString()}");
        }
      }
    });
  }

  void loginInfo(String userId,String userName){
    _userID = userId;
    _userName = userName;
    _loginStatus = true;
    loadMap();
    saveSettings('loginStatus',_loginStatus);
    saveSettings('userID',_userID);
    saveSettings('userName',_userName);
    print(_loginStatus);
    notifyListeners();
  }

  void logout(){
    _userID = "";
    _userName ="";
    _loginStatus = false;
    _connectedCompanion = "";
    _requestUser = "";
    _companionList.clear();
    saveSettings('loginStatus',_loginStatus);
    saveSettings('userID',_userID);
    saveSettings('userName',_userName);
    notifyListeners();
  }



  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }
}