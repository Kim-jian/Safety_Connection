import 'package:flutter/material.dart';
import 'package:proto/HomeScreen.dart';
import 'ConnectionProvider.dart';
import 'SettingEnvironmentController.dart';

class JustWaitScreen extends StatelessWidget {
  ConnectionProvider connectionProvider = ConnectionProvider();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('차량 이동 중'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
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
          ],
        ),
      ),
    );
  }
}
