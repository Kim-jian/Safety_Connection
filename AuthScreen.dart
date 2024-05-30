import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'ConnectionProvider.dart';
import 'SettingEnvironmentController.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  ConnectionProvider connectionProvider = ConnectionProvider();
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("확인"),
          content: Text("차량 이동 요청이 전송됩니다."),
          actions: <Widget>[
            TextButton(
              child: Text("확인"),
              onPressed: () async {
                Navigator.of(context).pop(); // 대화상자 닫기
                //차량 이동 요청 전송
                String? token = await connectionProvider.getCompanionToken(
                    SettingEnvironmentController.instance.requestUser
                );
                if(token != null){
                  connectionProvider.postRequestMsg(token!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                      settings: RouteSettings(arguments: "요청이 완료되었습니다."),
                    ),
                  );
                }else{
                  print("token 검색 오류 발생.");
                }
              },
            ),
            TextButton(
              child: Text("취소"),
              onPressed: () {
                Navigator.of(context).pop(); // 대화상자 닫기
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
      appBar: AppBar(
        title: Text("개인 인증"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: _showConfirmationDialog,
              child: Column(
                mainAxisSize: MainAxisSize.min, // 내부 컨텐츠 크기에 맞춤
                children: <Widget>[
                  Icon(Icons.fingerprint, size: 100), // 아이콘 크기 조정
                  Text('지문 인식으로 인증'), // 텍스트
                ],
              ),
            ),
            SizedBox(height: 80),
            ElevatedButton(
              onPressed: () {
                // 다른 인증 방식
                print("다른 인증 방식 선택");
              },
              child: Text('다른 방식으로 인증'),
            ),
          ],
        ),
      ),
    );
  }
}
