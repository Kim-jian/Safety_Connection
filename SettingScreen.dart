import 'package:flutter/material.dart';
import 'package:proto/SettingEnvironmentController.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('설정')),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('위치 정보 공유'),
            value: SettingEnvironmentController.instance.shareGPS,
            onChanged: (bool value) {
              setState(() {
                SettingEnvironmentController.instance.updateShareGPS(); // 위치 정보 공유 상태 갱신
              });
            },
          ),
        ],
      ),
    );
  }
}
