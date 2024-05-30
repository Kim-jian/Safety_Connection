import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'Crypto.dart';
import 'SettingEnvironmentController.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ConnectionProvider {

  final String nowIP = ""; //이 값 수정해서 연결 위치 바꿀 수 있음.

// 응답 문자열을 파싱하여 필요한 정보 추출
  Map<String, String> parseResponse(String response) {
    Map<String, String> data = {};
    List<String> parts = response.split(', ');

    for (String part in parts) {
      List<String> keyValue = part.split(': ');
      if (keyValue.length == 2) {
        String key = keyValue[0].trim();
        String value = keyValue[1].trim();
        value = decryptData(value, aeskey);
        data[key] = value;
      }
    }

    return data;
  }

  Future<String> getAllCompanions() async{
    String userId = encryptData(SettingEnvironmentController.instance.userID, aeskey);
    final String url = 'http://${nowIP}:8080/users/${userId}/allcompanions';
    try{
      print("Sending request to $url");
      final response = await http.get(Uri.parse(url));
      print("Received response: ${response.statusCode}");
      if(response.statusCode == 200){
        print("Request successful, response: ${response.body}");
        return decryptData(response.body, aeskey);
      }else{
        print("Request failed with status: ${response.statusCode}");
        return "";
      }
    }catch(e){
      print("Exception during fetch: $e");
      return "";
    }
  }

  Future<String> sendCompanionAddRequest(var companionId) async{
    String encryptedCompId = encryptData(companionId, aeskey);
    String userId = encryptData(SettingEnvironmentController.instance.userID, aeskey);

    final String url = 'http://${nowIP}:8080/users/${userId}/${encryptedCompId}/compadd';
    try{
      print("Sending request to $url");
      final response = await http.post(Uri.parse(url));
      print("Received response: ${response.statusCode}");
      if(response.statusCode == 200){
        print("Request successful, response: ${response.body}");
        return response.body;
      }else{
        print("Request failed with status: ${response.statusCode}");
        return "error";
      }
    }catch(e){
      print("Exception during fetch: $e");
      return "error";
    }
  }


  Future<bool> compDeleteRequest(var companionId) async{
    String encryptedCompId = encryptData(companionId, aeskey);
    String userId = encryptData(SettingEnvironmentController.instance.userID, aeskey);

    final String url = 'http://${nowIP}:8080/users/${userId}/${encryptedCompId}/compdel';
    try{
      print("Sending request to $url");
      final response = await http.delete(Uri.parse(url));
      print("Received response: ${response.statusCode}");
      if(response.statusCode == 200){
        print("Request successful, response: ${response.body}");
        return true;
      }else{
        print("Request failed with status: ${response.statusCode}");
        return false;
      }
    }catch(e){
      print("Exception during fetch: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCompanionsLocations() async {
    List<MapEntry<String, String>> companionList = SettingEnvironmentController.instance.companionList;
    List<Map<String, dynamic>> locations = [];

    for (int i = 0; i < companionList.length; i++) {
      final String userId = companionList[i].value;
      final String encrytionUserId = encryptData(userId, aeskey);
      final String url = 'http://${nowIP}:8080/users/${encrytionUserId}/location';
      try {
        print("Sending request to $url");
        final response = await http.get(Uri.parse(url));
        print("Received response: ${response.statusCode}");

        if (response.statusCode == 200) {
          // 응답이 성공적인 경우 위치 정보를 파싱하여 리스트에 추가
          print("Request successful, response: ${response.body}");
          Map<String, String> parsedData = parseResponse(response.body);

          if (parsedData.containsKey('Longitude') && parsedData.containsKey('Latitude')) {
            Position position = Position(
              latitude: double.parse(parsedData['Latitude']!),
              longitude: double.parse(parsedData['Longitude']!),
              accuracy: 0.0, // 기본값 설정
              altitude: 0.0, // 기본값 설정
              altitudeAccuracy: 0.0, // 기본값 설정
              heading: 0.0, // 기본값 설정
              headingAccuracy: 0.0, // 기본값 설정
              speed: 0.0, // 기본값 설정
              speedAccuracy: 0.0, // 기본값 설정
              timestamp: DateTime.now(), // 현재 시간
            );
            locations.add({
              'UserName': parsedData['UserName'],
              'Position': position
            });
          }
        } else {
          print("Request failed with status: ${response.statusCode}");
        }
      } catch (e) {
        print("Exception during fetch: $e");
      }
    }

    return locations;
  }

  Future<String> sendSearchRequest(var userid) async {
    final String encrytionUserId = encryptData(userid, aeskey);
    final String url = 'http://${nowIP}:8080/users/${encrytionUserId}';
    try {
      print("Sending request to $url");
      final response = await http.get(Uri.parse(url));
      print("Received response: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Request successful, response: ${response.body}");
        return response.body;
      } else {
        print("Request failed with status: ${response.statusCode}");
        return "error";
      }
    } catch (e) {
      print("Exception during fetch: $e");
      return "error";
    }
  }

  Future<void> sendLocationToServer() async {
    if (SettingEnvironmentController.instance.currentPosition != null) {
      final encryptedLongitude = encryptData(SettingEnvironmentController.instance.currentPosition!.longitude.toString(), aeskey);
      final encryptedLatitude = encryptData(SettingEnvironmentController.instance.currentPosition!.latitude.toString(), aeskey);
      final encryptedUserId = encryptData(SettingEnvironmentController.instance.userID, aeskey);
      final response = await http.post(
        Uri.parse('http://${nowIP}:8080/users/${encryptedUserId}/${encryptedLatitude}/${encryptedLongitude}'), // 서버 엔드포인트 URL
      );
      if (response.statusCode == 200) {
        print('Location sent to server successfully');
      } else {
        print('Failed to send location to server');
      }
    }
  }

  Future<bool> sendBoolSearchRequest(var userid) async {
    final String encryptedId = encryptData(userid, aeskey);
    final String url = 'http://${nowIP}:8080/users/${encryptedId}';
    try {
      print("Sending request to $url");
      final response = await http.get(Uri.parse(url));
      print("Received response: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Request successful, response: ${response.body}");
        return true;
      } else {
        print("Request failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception during fetch: $e");
      return false;
    }
  }

  Future<LatLng> getCompanionLocationByName(var userName) async {
    final String encryptedName = encryptData(userName, aeskey);
    final String url = 'http://${nowIP}:8080/users/${encryptedName}/compaloc';
    try {
      print("Sending request to $url");
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print("Request successful, response: ${response.body}");
        // 응답 문자열을 파싱하여 경도와 위도를 추출합니다.
        final body = response.body;
        final longitudeStartIndex = body.indexOf("Longitude: ") + "Longitude: ".length;
        final longitudeEndIndex = body.indexOf(", Latitude:");
        final latitudeStartIndex = longitudeEndIndex + ", Latitude: ".length;

        final encryptedLongitude = body.substring(longitudeStartIndex, longitudeEndIndex);
        final encryptedLatitude = body.substring(latitudeStartIndex);

        // 경도와 위도를 복호화합니다.
        final double longitude = double.parse(decryptData(encryptedLongitude, aeskey));
        final double latitude = double.parse(decryptData(encryptedLatitude, aeskey));

        // LatLng 객체를 생성합니다.
        return LatLng(latitude, longitude);
      } else {
        print("Request failed with status: ${response.statusCode}");
        throw Exception("Failed to load companion location");
      }
    } catch (e) {
      print("Exception during fetch: $e");
      throw Exception("Failed to load companion location");
    }
  }

  Future<bool> sendSignupRequest(var userId,var name, var phoneNumber, var email, var password) async {
    final String encryptedId = encryptData(userId, aeskey);
    final String encryptedEmail = encryptData(email, aeskey);
    final String encryptedName = encryptData(name, aeskey);
    final String encryptedPhoneNumber = encryptData(phoneNumber, aeskey);
    final String encryptedPassword = encryptData(password, aeskey);

    final String url = 'http://${nowIP}:8080/users/${encryptedId}/${encryptedName}/${encryptedPhoneNumber}/${encryptedEmail}/${encryptedPassword}';
    try {
      print("Sending request to $url");
      final response = await http.post(Uri.parse(url));
      print("Received response: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Request successful, response: ${response.body}");
        return true;
      } else {
        print("Request failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception during fetch: $e");
      return false;
    }
  }


  Future<String> getUserIdByUsernameAndPassword(String username, String password) async {
    final String encryptedUsername = encryptData(username, aeskey);
    final String encryptedPassword = encryptData(password, aeskey);
    final String url = 'http://${nowIP}:8080/users/${encryptedUsername}/${encryptedPassword}';

    try {
      print("Sending request to $url");
      final response = await http.get(Uri.parse(url));
      print("Received response: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Request successful, response: ${response.body}");
        // 서버 응답이 ID인 경우 그대로 반환
        return response.body;
      } else {
        print("Request failed with status: ${response.statusCode}");
        return "error";
      }
    } catch (e) {
      print("Exception during fetch: $e");
      return "error";
    }
  }

  Future<void> sendTokenToServer(var userId, String token) async {
    final String encryptedUserId = encryptData(userId, aeskey);
    final String encryptedToken = encryptData(token, aeskey);
    final String url = 'http://${nowIP}:8080/users/${encryptedUserId}/${encryptedToken}/updateToken';

    try {
      final response = await http.post(
          Uri.parse(url), body:{
        'userId': encryptedUserId, 'token': encryptedToken,
      }
      );
      print("Received response: ${response.statusCode}");

      if (response.statusCode == 200) {
        print('Token sent to server successfully, token : ${response.body}');
      } else {
        print('Failed to send token to server');
      }
    } catch (e) {
      print("Exception during fetch: $e");
    }
  }

  Future<String?> getCompanionToken(var companionId) async {
    final String encryptedCompanionId = encryptData(companionId, aeskey);
    final String url = 'http://${nowIP}:8080/users/${encryptedCompanionId}/sendNotification';

    try {
      final response = await http.post(Uri.parse(url));
      print("Received response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final String token = response.body;
        print('Token sent to companion successfully: $token');
        return token;
      } else {
        print('Failed to send companion to server');
      }
    } catch (e) {
      print("Exception during fetch: $e");
    }
    return null;
  }

  Future<String> requestIDbyName(String userName) async{
    final String encryptedUserName = encryptData(userName, aeskey);
    final String url = 'http://${nowIP}:8080/users/${encryptedUserName}/namereq';
    try {
      final response = await http.get(Uri.parse(url));
      print("Received response: ${response.statusCode}");

      if (response.statusCode == 200) {
        String ID = decryptData(response.body,aeskey);
        print("returned : $ID");
        return ID;
      } else {
        print('Failed to send companion to server');
      }
    } catch (e) {
      print("Exception during fetch: $e");
    }
    return "";
  }

  Future<String> refreshToken() async {
    const String tokenEndpoint = '';
    final Map<String, String> body = {
      'grant_type': 'refresh_token',
      'refresh_token': SettingEnvironmentController.instance.refreshToken,
      'client_id': '',
      'client_secret': '',
    };
    try {
      // HTTP POST 요청 실행
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {'content-Type': 'application/x-www-form-urlencoded',
          'User-Agent': 'google-oauth-playground'},
        body: body,
      );
      // 응답이 성공적인지 확인
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 액세스 토큰 반환
        print("Success : ${data['access_token']}");
        return data['access_token'];
      } else {
        // 실패한 경우 오류 메시지를 로그하고 예외를 발생
        print('Failed to refresh token: ${response.body}');
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      // 네트워크 오류 등의 이유로 예외 처리
      print('Error refreshing token: $e');
      throw Exception('Error occurred while refreshing token');
    }
  }


  Future<String?> postMessage(String fcmToken) async {
    print("postMsg 실행");
    fcmToken = decryptData(fcmToken, aeskey);
    String userName = SettingEnvironmentController.instance.userName;
    try {
      String _accessToken = SettingEnvironmentController.instance.accessToken;
      http.Response _response = await http.post(
          Uri.parse(
            "",
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
          body: json.encode({
            "message": {
              "token": fcmToken,

              "notification": {
                "title": "$userName님의 동행 요청",
                "body": "$userName님의 동행자가 되어주세요!",
              },
              "data": {
                "click_action": "$userName",
              },
              "android": {
                "priority" : "high",
                "notification": {
                  "click_action": "FLUTTER_NOTIFICATION_CLICK",
                }
              },
              "apns": {
                "payload": {
                  "aps": {
                    "category": "Message Category",
                    "content-available": 1
                  }
                }
              }
            }
          }));
      if (_response.statusCode == 200) {
        print("Send request Success.");
        return null;
      } else if(_response.statusCode == 401) {
        SettingEnvironmentController.instance.updateAccessToken(await refreshToken());
        fcmToken = encryptData(fcmToken, aeskey);
        postMessage(fcmToken);
      }
    } on HttpException catch (error) {
      return error.message;
    }
  }
  Future<String?> answerRequest(String fcmToken, String answer) async {
    print("answerMsg 실행");
    fcmToken = decryptData(fcmToken, aeskey);
    try {
      String _accessToken = SettingEnvironmentController.instance.accessToken;
      http.Response _response = await http.post(
          Uri.parse(
            "",
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
          body: json.encode({
            "message": {
              "token": fcmToken,

              "notification": {
                "title": "동행 요청이 ${answer}되었습니다.",
                "body": "예상 소요 시간을 설정해주세요!",
              },
              "data": {
                "click_action": "$answer",
              },
              "android": {
                "priority" : "high",
                "notification": {
                  "click_action": "FLUTTER_NOTIFICATION_CLICK",
                }
              },
              "apns": {
                "payload": {
                  "aps": {
                    "category": "Message Category",
                    "content-available": 1
                  }
                }
              }
            }
          }));
      if (_response.statusCode == 200) {
        print("Send request Success.");
        return "Success";
      } else if(_response.statusCode == 401) {
        SettingEnvironmentController.instance.updateAccessToken(await refreshToken());
        fcmToken = encryptData(fcmToken, aeskey);
        return answerRequest(fcmToken,answer);
      }
    } on HttpException catch (error) {
      return error.message;
    }
  }



  Future<String?> postCompleteMessage(String fcmToken) async {
    print("postCompleteMsg 실행");
    fcmToken = decryptData(fcmToken, aeskey);
    String userName = SettingEnvironmentController.instance.userName;
    try {
      String _accessToken = SettingEnvironmentController.instance.accessToken;
      http.Response _response = await http.post(
          Uri.parse(
            "",
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
          body: json.encode({
            "message": {
              "token": fcmToken,

              "notification": {
                "title": "차량 이동 완료",
                "body": "차량 이동이 완료되었어요!",
              },
              "data": {
                "click_action": "finished",
              },
              "android": {
                "priority" : "high",
                "notification": {
                  "click_action": "FLUTTER_NOTIFICATION_CLICK",
                }
              },
              "apns": {
                "payload": {
                  "aps": {
                    "category": "Message Category",
                    "content-available": 1
                  }
                }
              }
            }
          }));
      if (_response.statusCode == 200) {
        print("Send request Success.");
        return null;
      } else if(_response.statusCode == 401) {
        SettingEnvironmentController.instance.updateAccessToken(await refreshToken());
        fcmToken = encryptData(fcmToken, aeskey);
        postCompleteMessage(fcmToken);
      }
    } on HttpException catch (error) {
      return error.message;
    }
  }

  Future<String?> postRequestMsg(String fcmToken) async {
    print("postRequestMsg 실행");
    fcmToken = decryptData(fcmToken, aeskey);
    String userName = SettingEnvironmentController.instance.userName;
    try {
      String _accessToken = SettingEnvironmentController.instance.accessToken;
      http.Response _response = await http.post(
          Uri.parse(
            "",
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
          body: json.encode({
            "message": {
              "token": fcmToken,

              "notification": {
                "title": "차량 이동 요청",
                "body": "차량 이동 요청이 도착했어요!",
              },
              "data": {
                "click_action": "req$userName",
              },
              "android": {
                "priority" : "high",
                "notification": {
                  "click_action": "FLUTTER_NOTIFICATION_CLICK",
                }
              },
              "apns": {
                "payload": {
                  "aps": {
                    "category": "Message Category",
                    "content-available": 1
                  }
                }
              }
            }
          }));
      if (_response.statusCode == 200) {
        print("Send request Success.");
        return null;
      } else if(_response.statusCode == 401) {
        SettingEnvironmentController.instance.updateAccessToken(await refreshToken());
        fcmToken = encryptData(fcmToken, aeskey);
        postRequestMsg(fcmToken);
      }
    } on HttpException catch (error) {
      return error.message;
    }
  }

  Future<String?> postCompleteTime(String fcmToken, int time) async {
    print("postCompleteTime 실행");
    fcmToken = decryptData(fcmToken, aeskey);
    try {
      String _accessToken = SettingEnvironmentController.instance.accessToken;
      http.Response _response = await http.post(
          Uri.parse(
            "",
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
          body: json.encode({
            "message": {
              "token": fcmToken,

              "notification": {
                "title": "예상 소요 시간",
                "body": "차량 이동 완료까지 걸리는 예상 시간은 $time분입니다.",
              },
              "data": {
                "click_action": "ctime$time",
              },
              "android": {
                "priority" : "high",
                "notification": {
                  "click_action": "FLUTTER_NOTIFICATION_CLICK",
                }
              },
              "apns": {
                "payload": {
                  "aps": {
                    "category": "Message Category",
                    "content-available": 1
                  }
                }
              }
            }
          }));
      if (_response.statusCode == 200) {
        print("Send request Success.");
        return null;
      } else if(_response.statusCode == 401) {
        SettingEnvironmentController.instance.updateAccessToken(await refreshToken());
        fcmToken = encryptData(fcmToken, aeskey);
        postCompleteTime(fcmToken, time);
      }
    } on HttpException catch (error) {
      return error.message;
    }
  }
}