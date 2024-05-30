import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'SettingEnvironmentController.dart';

class LoginInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingController = Provider.of<SettingEnvironmentController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('로그인 정보'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'User Name:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              settingController.userName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),  // 여기에 간격 추가
            Text(
              'User ID:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              settingController.userID,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

          ],
        ),
      ),
    );
  }
}
