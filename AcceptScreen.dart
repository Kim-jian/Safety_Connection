import 'dart:io';

import 'package:flutter/material.dart';
import 'package:proto/ForCompWaitMapScreen.dart';
import 'JustWaitScreen.dart';
import 'ConnectionProvider.dart';
import 'SettingEnvironmentController.dart';

class AcceptScreen extends StatelessWidget {
  ConnectionProvider connectionProvider = ConnectionProvider();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('동행 요청'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '동행 요청이 도착했습니다.',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    // 수락 버튼 동작 추가
                    String appID = await connectionProvider.requestIDbyName(SettingEnvironmentController.instance.connectedCompanion);
                    String? token = await connectionProvider.getCompanionToken(
                        appID
                    );
                    connectionProvider.answerRequest(token!, '수락');
                    if(SettingEnvironmentController.instance.shareGPS){
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ForCompWaitMapScreen()),
                      );
                    }else{
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => JustWaitScreen()),
                      );
                    }
                  },
                  child: Text('수락'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 거절 버튼 동작 추가
                    String appID = await connectionProvider.requestIDbyName(SettingEnvironmentController.instance.connectedCompanion);
                    String? token = await connectionProvider.getCompanionToken(
                        appID
                    );
                    print("거절 전송하는 user :${SettingEnvironmentController.instance.connectedCompanion}");
                    String? complete = await connectionProvider.answerRequest(token!, '거절');
                    if(complete == "Success"){
                      exit(0);
                    }
                    else{
                      print("error occur while send deny msg.");
                    }
                  },
                  child: Text('거절'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}