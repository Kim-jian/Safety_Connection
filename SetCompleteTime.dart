import 'package:flutter/material.dart';
import 'package:proto/CompanionSelectScreen.dart';
import 'package:proto/CompanionWaitMapScreen.dart';
import 'package:proto/SettingEnvironmentController.dart';
import 'package:proto/main.dart';
import 'ConnectionProvider.dart';

import 'JustWaitScreen.dart';

class SetCompleteTime extends StatefulWidget {
  @override
  _SetCompleteTimeState createState() => _SetCompleteTimeState();
}

class _SetCompleteTimeState extends State<SetCompleteTime> {
  CompanionSelectScreen companionSelectScreen = new CompanionSelectScreen();
  int? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selectedTime == null)
              Column(
                children: [
                  Text('차량 이동까지 걸리는 예상 소요시간을 설정하세요',
                    style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('(설정된 예상 소요시간을 요청자에게 전송합니다.)'),
                  SizedBox(height: 100,),
                  ElevatedButton(
                    onPressed: () {
                      _showTimeInputDialog(context); // 다이얼로그 표시 함수 호출
                    },
                    child: Text('설정하기'),
                  ),
                ],
              ),
            if (selectedTime != null)
              Column(
                children: [
                  Text(
                    '설정된 시간: $selectedTime 분',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedTime = null;
                      });
                    },
                    child: Text('재설정'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      // 설정된 시간을 전송하는 로직 추가(pushkey이용)
                      String userID = await connectionProvider.requestIDbyName(SettingEnvironmentController.instance.requestUser);
                      print("11111 $userID");
                      String? token = await connectionProvider.getCompanionToken(userID);
                      connectionProvider.postCompleteTime(token!, selectedTime!);

                      //이후 동행자 위치 지도 표시로 이동.
                      if(SettingEnvironmentController.instance.shareGPS){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CompanionWaitMapScreen()),
                        );
                      }
                      else{
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => JustWaitScreen()),
                        );
                      }

                    },
                    child: Text('전송하기'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // 다이얼로그 표시 함수
  void _showTimeInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int maxMinutes = 20; // 최대 입력 가능한 시간 (분)
        TextEditingController _controller = TextEditingController();

        return AlertDialog(
          title: Text('시간 입력 (최대 $maxMinutes 분)'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '시간(분)',
            ),
            maxLength: 2, // 두 자리 숫자까지만 입력 가능
            buildCounter: (BuildContext context, { int? currentLength, int? maxLength, bool? isFocused }) => null,
            onChanged: (value) {
              if (int.tryParse(value) != null) {
                int minutes = int.parse(value);
                if (minutes > maxMinutes) {
                  _controller.text = maxMinutes.toString();
                }
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 입력한 값을 사용하는 로직 구현
                String inputValue = _controller.text;
                int minutes = int.parse(inputValue);
                setState(() {
                  selectedTime = minutes;
                });
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('확인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }
}
